require 'ardis/instruction'

module Ardis
  module Command
    class Rep < Instruction
      ILLEGAL_INSTRUCTION_RE = /\Arep\w+\s+ret/

      # The instruction "repz ret" is an illegal instruction.  See this
      # article for more info:
      # http://mikedimmick.blogspot.com/2008/03/what-heck-does-ret-mean.html
      # 
      # The short solution is that "ret 0" is now prefered over the illegal
      # instruction.
      def resolve (elf, section, block)
        @cmd = "ret $0" if ILLEGAL_INSTRUCTION_RE =~ @cmd
      end
    end
  end
end
