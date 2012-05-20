module SWFBoat::AS3
  class ABCFile
    def initialize (abcfile)
      @bytes = abcfile.split('')
      @minor_version = @bytes.shift(2).join.unpack('S')[0]
      @major_version = @bytes.shift(2).join.unpack('S')[0]
    end
  end
end
