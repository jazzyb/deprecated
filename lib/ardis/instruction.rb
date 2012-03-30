module Ardis
  class Instruction
    attr_reader :cmd
    def initialize (section, addr, bytes, cmd)
      @section, @addr, @bytes, @cmd = section, addr, bytes, cmd
    end
  end
end
