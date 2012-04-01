require 'ardis/instruction'

module Ardis
  module Command
    class Lea < Instruction
      BAD_REG_RE = /,%eiz,1/

      def resolve (elf, section, block)
        @cmd.gsub! BAD_REG_RE, ''
      end
    end
  end
end
