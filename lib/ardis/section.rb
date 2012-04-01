require 'ardis/data_block'
require 'ardis/instruction'

module Ardis
  class Section
    attr_accessor :name, :flags
    def initialize (name, flags)
      @name, @flags = name, flags
    end

    def << (item)
      if item.is_a? DataBlock
        append_data_block item
      elsif item.is_a? Instruction
        append_instruction item
      elsif item.is_a? String
        append_reloc item
      else
        raise "unknown item appended to section #@name: '#{item}'"
      end
    end

    def each_block
      @blocks.each { |b| yield b }
    end

    def executable?
      @flags && @flags.include?(:executable)
    end

    # returns the block and instruction (in that order) for the given address
    def find_address (addr)
      @instr_addrs[addr]
    end

    private

    def append_data_block (block)
      @curr_block = block
      @blocks ||= []
      @blocks << @curr_block
    end

    def append_instruction (instruction)
      @curr_instruction = instruction
      @curr_block << @curr_instruction
      @instr_addrs ||= {}
      @instr_addrs[@curr_instruction.addr] = [@curr_block, @curr_instruction]
    end

    def append_reloc (reloc)
      @curr_instruction.reloc = reloc
    end
  end
end
