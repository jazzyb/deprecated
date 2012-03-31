require 'ardis/instruction'

module Ardis
  module Command
    class Mov < Instruction
      MOV_RELOC_RE = /\A(?<mov>mov\w*\s+\$)(?<zero>0x0),(?<rest>.*)\Z/

      def resolve
        return unless @reloc
        if (md = MOV_RELOC_RE.match @cmd)
          @cmd = md[:mov] + "#@reloc," + md[:rest]
        else
          warn "unhandled mov reloc '#@addr: #@cmd'"
        end
      end
    end
  end
end
