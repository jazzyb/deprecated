require 'ardis/instruction'

module Ardis
  module Command
    class Jmp < Instruction
      NEAR_JUMP_RE = /\A(?<jmp>j\w+\s+)(?<addr>[0-9a-f]+)/
      JUMP_TABLE_RE = %r{\A(?<jmp>j\w+\s+\*)
                           (?<offset>0x[0-9a-f]+)
                           (?<rest>.*)\Z
      }x

      def resolve
        if (md = NEAR_JUMP_RE.match @cmd)
          resolve_near_jump md[:jmp], md[:addr]
        elsif (md = JUMP_TABLE_RE.match @cmd)
          resolve_jump_table md[:jmp], md[:offset], md[:rest]
        else
          warn "unrecognized jmp command '#@addr: #@cmd'"
        end
      end

      def requires_later_resolution?
        JUMP_TABLE_RE =~ @cmd
      end

      private

      def resolve_near_jump (jmp, addr)
        if @reloc
          @cmd = "#{jmp}#@reloc"
        else
          i = @section.get_instruction addr
          if i.nil?
            warn "unknown address in jmp command '#{addr}: #{cmd}'"
            return
          end
          @cmd = "#{jmp}\t#{i.get_label}"
        end
      end

      def resolve_jump_table (jmp, offset, rest)
        unless @reloc
          warn "no reloc exists for jmp command '#@addr: #@cmd'"
        end
      end
    end
  end
end
