require 'ardis/instruction'

module Ardis
  module Command
    class Call < Instruction
      CALL_RE = /\Acall\s+[0-9a-f]+/

      def resolve
        unless @reloc
          warn "call command '#@addr: #@cmd' does not have reloc"
          return
        end

        if (md = CALL_RE.match @cmd)
          @cmd = "call\t#@reloc"
        else
          warn "unrecognized call command '#@addr: #@cmd'"
        end
      end
    end
  end
end
