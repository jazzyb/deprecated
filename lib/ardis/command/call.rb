require 'ardis/instruction'

module Ardis
  module Command
    class Call < Instruction
      CALL_RE = /\A(?<call>call\s+)(?<addr>[0-9a-f]+)/

      def resolve (elf, section, block)
        if (md = CALL_RE.match @cmd)
          if @reloc
            @cmd = md[:call] + @reloc
          else
            blk, instr = section.find_address md[:addr]
            if blk.nil? || instr.nil?
              warn "unknown address in call command '#@addr: #@cmd'"
              return
            end
            @cmd = md[:call] + blk.create_label(self, instr)
          end
        else
          warn "unrecognized call command '#@addr: #@cmd'"
        end
      end
    end
  end
end
