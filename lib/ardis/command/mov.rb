require 'ardis/instruction'

module Ardis
  module Command
    class Mov < Instruction
      MOV_RELOC_RE = %r{\A(?<mov>mov\w*\s+\$?)
                          (?<offset>0x[0-9a-f]+)
                          (?<rest>.*)\Z
      }x

      def resolve
        return unless @reloc
        if (md = MOV_RELOC_RE.match @cmd)
          @cmd = md[:mov] + "(#@reloc+#{md[:offset]})" + md[:rest]
        else
          warn "unhandled mov reloc '#@addr: #@cmd'"
        end
      end
    end
  end
end
