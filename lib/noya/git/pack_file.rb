require 'noya/git/bitfield_reader'
require 'noya/git/object'
require 'noya/git/offset_delta'
require 'zlib'

module Noya::Git
  class PackFile
    def self.foreach (repo_dir)
      path = repo_dir + '/.git/objects/pack/'
      Dir[path + '*.pack'].each do |pack|
        idx = pack.split('.')[0...-1].join('.') + '.idx'
        PackFile.new(idx, pack).each_object { |o| yield o }
      end
    end

    def initialize (idx, pack)
      read_index_file idx
      # FIXME need to handle reading packfile if there is no index
      read_pack_file pack
    end

    def each_object
      @objects.sort { |a, b| a.sha <=> b.sha }.each { |o| yield o }
    end

    IDX_HDR = "\xfftOc\x00\x00\x00\x02"
    def read_index_file (idx)
      File.open(idx, 'rb') do |f|
        raise "incorrect header for index file '#{idx}'" if f.read(8) != IDX_HDR

        @fanouts = f.read(4 * 255).unpack('N*')
        @size = f.read(4).unpack('N')[0]
        @shas = f.read(20 * @size).unpack('H40' * @size)
        @crcs = f.read(4 * @size).unpack('H8' * @size)
        @offsets = f.read(4 * @size).unpack('N*')
        # TODO: ignoring the rest of the index file for now
      end
    end

    def read_pack_file (pack)
      File.open(pack, 'rb') do |f|
        header = f.read(4)
        version, entries = f.read(8).unpack('N2')
        if header != 'PACK' || version != 2 || entries != @size
          raise "incorrect header for pack file '#{pack}'"
        end

        @objects = []
        # objsz is the size of the data in the pack file that is represented by
        # the given SHA
        sort_objects_from_index(f.size - 20).each do |sha, offset, objsz|
          @objects << extract_object_from_pack_file(sha, offset, f.read(objsz))
        end
      end
    end

    # return an array whose items are tuples of
    # [SHA-1, object_offset, object_size] sorted by object_offset
    # length is file size minus SHA-1 trailer -- the last bookend
    def sort_objects_from_index (length)
      offsets = @offsets.sort
      bookends = offsets[1..-1] + [length]
      sha_map = Hash[*@offsets.zip(@shas).flatten] # { offset => sha }
      offsets.zip(bookends).map { |o, b| [sha_map[o], o, b - o] }
    end

    include BitFieldReader # for read_bitfield()

    # extract an object from the given slice of pack file data
    def extract_object_from_pack_file (sha, offset, packdata)
      bytes = packdata.split('').reverse
      more, type, total = read_bitfield(bytes.pop, true)
      while more
        more, bits = read_bitfield(bytes.pop)
        total = bits + total
      end
      size = total.to_i(2)
      create_object(sha, type, size, offset, bytes)
    end

    def create_object (sha, type, size, offset, bytes)
      case type
      when 'blob', 'commit', 'tree'
        Object.new(Zlib::Inflate.inflate(bytes.reverse.join),
                   :sha => sha,
                   :type => type,
                   :size => size,
                   :offset => offset)
      when 'ofs-delta'
        create_delta_offset(sha, type, size, offset, bytes)
      else
        raise "cannot handle type '#{type}'"
      end
    end

    def create_delta_offset (sha, type, size, offset, bytes)
      more, rel_ofs = read_bitfield(bytes.pop)
      while more
        # must add 1 to most recent bits for some reason
        rel_ofs = (rel_ofs.to_i(2) + 1).to_s 2
        more, bits = read_bitfield(bytes.pop)
        rel_ofs += bits
      end
      OffsetDelta.new(:sha => sha,
                      :type => type,
                      :size => size,
                      :offset => offset,
                      :base_offset => offset - rel_ofs.to_i(2),
                      :delta => Zlib::Inflate.inflate(bytes.reverse.join))
    end
  end
end
