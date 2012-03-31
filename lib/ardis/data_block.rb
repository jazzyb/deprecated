module Ardis
  class DataBlock
    attr_reader :name, :type
    def initialize (section, name, type)
      @section, @name, @type = section, name, type
    end

    def << (instruction)
      @curr_instruction = instruction
      @instructions ||= []
      @instructions << @curr_instruction
    end

    def append_reloc (reloc)
      @curr_instruction.reloc = reloc
    end

    def each_instruction
      @instructions.each { |i| yield i }
    end
  end
end
