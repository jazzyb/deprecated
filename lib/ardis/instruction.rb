module Ardis
  class Instruction
    attr_accessor :reloc, :label
    attr_reader :addr, :bytes, :cmd
    def initialize (addr, bytes, cmd)
      @addr, @bytes, @cmd = addr, bytes.split, cmd
    end

    # any instructions that need to be resolved somehow before they are
    # printed need to extend this class and overwirte this method
    def resolve (elf, section, block)
      warn "instruction '#@addr: #@cmd' has unhandled reloc" if @reloc
    end

    # if the resolution of a particular instruction needs to occur after other
    # instructions have themselves been resolved, then this method should be
    # overwritten
    def resolve_after?
      false
    end

    # this method missing allows us to easily check the type of the
    # instruction, e.g. is_call?, is_movl?, is_jbe?
    def method_missing (func, *args, &block)
      instruction_re = /\Ais_(?<cmd>.*)\?\Z/
      if (md = instruction_re.match func)
        @cmd.index(md[:cmd]) == 0
      else
        raise NoMethodError, "undefined method `#{func}' for #{self.to_s}:#{self.class}"
      end
    end
  end
end
