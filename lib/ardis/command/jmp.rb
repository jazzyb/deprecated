require 'ardis/instruction'

module Ardis
  module Command
    class Jmp < Instruction
      NEAR_JUMP_RE = /\A(?<jmp>j\w+)\s+(?<addr>[0-9a-f]+)/

      def resolve
        if (md = NEAR_JUMP_RE.match @cmd)
          resolve_near_jump md[:jmp], md[:addr]
        else
          warn "unrecognized jmp command '#@addr: #@cmd'"
        end
      end

      private

      def resolve_near_jump (jmp, addr)
        if @reloc
          @cmd = "#{jmp}\t#@reloc"
        else
          i = @section.get_instruction addr
          if i.nil?
            warn "unknown address in jmp command '#{addr}: #{cmd}'"
            return
          end
          @cmd = "#{jmp}\t#{i.get_label}"
        end
      end
    end
  end
end
