require 'ardis/instruction'

module Ardis
  module Command
    class Call < Instruction
      CALL_RE = /\A(?<call>call\s+)(?<addr>[0-9a-f]+)/

      def resolve
        if (md = CALL_RE.match @cmd)
          if @reloc
            @cmd = md[:call] + @reloc
          else
            i = @section.get_instruction md[:addr]
            if i.nil?
              warn "unknown address in call command '#@addr: #@cmd'"
              return
            end
            @cmd = md[:call] + i.get_label
          end
        else
          warn "unrecognized call command '#@addr: #@cmd'"
        end
      end
    end
  end
end
