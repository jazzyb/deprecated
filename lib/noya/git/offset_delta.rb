require 'noya/git/bitfield_reader'
require 'noya/git/object'

module Noya::Git
  class OffsetDelta < Object
    def initialize (hash={})
      super(nil, hash)
      @base_offset = hash[:base_offset]
      @delta = hash[:delta]
    end

    include BitFieldReader # for read_bitfield()

    # sha_obj_map is a hash of { sha => object } and ofs_obj_map is a hash of
    # { pack_file_offset => object }
    def patch_delta (sha_obj_map, ofs_obj_map)
      return unless @contents.nil?
      base = ofs_obj_map[@base_offset]
      base.patch_delta(sha_obj_map, ofs_obj_map) if base.delta?
      @type = base.type

      bytes = @delta.split('').reverse
      base_size = calc_size(bytes)
      raise "base size is incorrect for #@sha" if base_size != base.size
      @size = calc_size(bytes)

      @contents = ''
      until bytes.empty?
        cmd = bytes.pop
        cmd_flag, rest = read_bitfield(cmd)
        if cmd_flag
          flags = rest.split('').map { |b| b == '1' }
          read_from_base(flags, bytes, base)
        elsif cmd.ord != 0
          read_from_delta(cmd.ord, bytes)
        else # cmd == 0
          raise "unexpected delta opcode 0"
        end
      end
    end

    def calc_size (bytes)
      more, total = read_bitfield(bytes.pop)
      while more
        more, bits = read_bitfield(bytes.pop)
        total = bits + total
      end
      total.to_i 2
    end

    def read_from_base (flags, bytes, base)
      start = get_copy_offset(flags, bytes)
      finish = start + get_copy_size(flags, bytes)
      @contents += base.contents[start...finish]
    end

    def get_copy_offset (flags, bytes)
      convert_to_number(4, flags, bytes)
    end

    def get_copy_size (flags, bytes)
      cp_size = convert_to_number(3, flags, bytes)
      cp_size == 0 ? 0x10000 : cp_size
    end

    # converts 'count' bytes to an integer based on the algorithm in
    # patch-delta.c in the git source code; 'flags' is a list of boolean values
    # that define whether or not a given byte should be added to the return
    # value; see git_repo/patch-delta.c
    def convert_to_number (count, flags, bytes)
      ret = ''
      count.times do
        if flags.pop
          ret = bytes.pop.unpack('B*')[0] + ret
        else
          ret = ('0' * 8) + ret
        end
      end
      ret.to_i 2
    end

    def read_from_delta (amount, delta)
      @contents += delta.pop(amount).reverse.join
    end
  end
end
