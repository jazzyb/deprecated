module Ardis
  class Instruction
    attr_accessor :reloc, :label
    attr_reader :bytes, :cmd
    def initialize (section, block, addr, bytes, cmd)
      @section, @block, @addr, @cmd = section, block, addr, cmd
      @bytes = bytes.split
    end

    # get_label (as opposed to just 'label') generates a new label from block
    # if none exists
    def get_label
      @label ||= @block.generate_label
    end

    # any instructions that need to be resolved somehow before they are
    # printed need to extend this class and overwirte this method
    def resolve
      warn "instruction '#@addr: #@cmd' has unhandled reloc" if @reloc
    end
  end
end
