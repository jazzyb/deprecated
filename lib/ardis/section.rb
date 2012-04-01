require 'ardis/data_block'
require 'ardis/instruction_factory'

module Ardis
  class Section
    attr_accessor :name, :flags
    def initialize (name, flags)
      @name, @flags = name, flags
    end

    def append_data_block (name, type)
      @curr_block = DataBlock.new(name, type)
      @blocks ||= []
      @blocks << @curr_block
    end

    def append_instruction (addr, bytes, cmd)
      i = InstructionFactory.create addr, bytes, cmd
      @instr_addrs ||= {}
      @curr_block << i
      @instr_addrs[addr] = [@curr_block, i]
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

    def get_instruction (addr)
      @instr_addrs[addr]
    end
  end
end
