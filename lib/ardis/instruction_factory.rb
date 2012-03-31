require 'ardis/command/call'
require 'ardis/command/jmp'
require 'ardis/command/lea'
require 'ardis/command/mov'
require 'ardis/instruction'

module Ardis
  class InstructionFactory
    def self.create (*args)
      cmd = args[-1]
      case cmd
      when /\Acall/
        Command::Call.new(*args)
      when /\Aj/
        Command::Jmp.new(*args)
      when /\Alea/
        Command::Lea.new(*args)
      when /\Amov/
        Command::Mov.new(*args)
      else
        Instruction.new(*args)
      end
    end
  end
end
