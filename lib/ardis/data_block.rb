module Ardis
  class DataBlock
    attr_reader :name, :type
    def initialize (name, type)
      @name, @type = name, type
    end

    def << (instruction)
      @curr_instruction = instruction
      @instructions ||= []
      @curr_instruction.label = @name if @instructions.empty?
      @instructions << @curr_instruction
    end

    def append_reloc (reloc)
      @curr_instruction.reloc = reloc
    end

    def create_label (instruction)
      return instruction.label if instruction.label
      @label_counter ||= 0
      @label_counter += 1
      instruction.label = ".L#@name$#@label_counter"
    end

    def each_instruction
      @instructions.each { |i| yield i }
    end
  end
end
