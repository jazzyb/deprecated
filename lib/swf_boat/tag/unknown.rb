module SWFBoat::Tag
  class Unknown
    attr_reader :code, :data
    def initialize (code, data)
      @code = code
      @data = data
    end

    def length
      @data.length
    end
    alias :size :length
  end
end
