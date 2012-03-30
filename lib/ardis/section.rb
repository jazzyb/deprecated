require 'ardis/data_block'
require 'ardis/instruction'

module Ardis
  class Section
    attr_accessor :name
    def initialize (name)
      @name = name
    end

    def append_data_block (name, type)
      @blocks ||= []
      @blocks << DataBlock.new(self, name, type)
    end

    def append_instruction (addr, bytes, cmd)
      @blocks[-1] << Instruction.new(self, addr, bytes, cmd)
    end

    def each_block
      @blocks.each { |b| yield b }
    end
  end
end
