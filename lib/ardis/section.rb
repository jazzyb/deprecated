require 'ardis/data_block'
require 'ardis/instruction_factory'

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
      i = InstructionFactory.create self, @curr_block, addr, bytes, cmd
      @instr_addrs ||= {}
      @instr_addrs[addr] = i
      @curr_block << i
    end

    def append_reloc (reloc)
      @curr_block.append_reloc reloc
    end

    def each_block
      @blocks.each { |b| yield b }
    end

    def each_instruction
      @blocks.each do |block|
        block.each_instruction { |i| yield i }
      end
    end

    def executable?
      @flags && @flags.include?(:executable)
    end

    def get_instruction (addr)
      @instr_addrs[addr]
    end
  end
end
