require 'swf_boat/as3/abc_file'

module SWFBoat::Tag
  class DoABC
    attr_reader :name
    def initialize (data)
      @flags = data[0..3].unpack('B*')[0]
      @name, @raw_data = data[4..-1].split("\0", 2)
    end

    def decompile
      @abcfile = SWFBoat::AS3::ABCFile.new(@raw_data)
    end
  end
end
