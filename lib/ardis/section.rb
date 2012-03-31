require 'ardis/data_block'
require 'ardis/instruction'

module Ardis
  class Section
    attr_accessor :name, :flags
    def initialize (name, flags)
      @name, @flags = name, flags
    end

    def append_data_block (name, type)
      @curr_block = DataBlock.new(self, name, type)
      @blocks ||= []
      @blocks << @curr_block
    end

    def append_instruction (addr, bytes, cmd)
      @curr_block << Instruction.new(self, addr, bytes, cmd)
    end

    def append_reloc (reloc)
      @curr_block.append_reloc reloc
    end

    def each_block
      @blocks.each { |b| yield b }
    end

    def executable?
      @flags && @flags.include?(:executable)
    end
  end
end
