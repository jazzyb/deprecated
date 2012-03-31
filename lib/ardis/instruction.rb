module Ardis
  class Instruction
    attr_accessor :reloc
    attr_reader :bytes, :cmd
    def initialize (section, addr, bytes, cmd)
      @section, @addr, @bytes, @cmd = section, addr, bytes.split, cmd
    end
  end
end
