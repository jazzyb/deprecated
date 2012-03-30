module Ardis
  class DataBlock
    attr_reader :name, :type
    def initialize (section, name, type)
      @section, @name, @type = section, name, type
    end

    def << (instruction)
      @instructions ||= []
      @instructions << instruction
    end

    def each_instruction
      @instructions.each { |i| yield i }
    end
  end
end
