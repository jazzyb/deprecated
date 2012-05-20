require 'swf_boat/tag/factory'
require 'swf_boat/tag/file_attributes'
require 'zlib'

module SWFBoat
  class FlashFile
    def initialize (name)
      @name = name
    end

    attr_reader :file_attrs, :tags
    def read
      File.open(@name) do |f|
        read_header f
        @file_attrs, @tags = read_tags
      end
    end

    private

    def read_header (file)
      hdr = file.read(8)
      if not ['FWS', 'CWS'].include? hdr[0..2]
        raise "'#@name' is not a SWF file"
      end

      @compressed = (hdr[0] == 'C')
      @version = hdr[3].ord
      @length = hdr[4..7].unpack('V')[0]
      @data = @compressed ? Zlib::Inflate.inflate(file.read) : file.read
      @data = @data.split('')
      @frame_size = read_frame_size()
      @data.shift 1 # ignore first byte of frame_rate
      @frame_rate = (@data.shift(1)[0] + "\x00").unpack('S')[0]
      @frame_count = @data.shift(2).join.unpack('S')[0]
    end

    def read_frame_size
      bits = @data.shift.unpack('B*')[0]
      nbits = bits[0..4].to_i(2)
      rbytes = ((4 * nbits) + (4 * nbits % 8)) / 8
      @data.shift(rbytes)
    end

    def read_tags
      tags = []
      while @data.size != 0
        codenlen = @data.shift(2).reverse.join.unpack('B*')[0]
        code = codenlen[0..9].to_i(2)
        length = codenlen[10..-1].to_i(2)
        if length == 63 # check for long record header
          length = @data.shift(4).join.unpack('i')[0]
        end
        tags << Tag::Factory.create(code, @data.shift(length).join)
      end

      if tags[0].is_a? Tag::FileAttributes
        [tags[0], tags[1..-1]]
      else
        [nil, tags]
      end
    end
  end
end
