module Ardis
  class Printer
    def initialize (iobuf=$stdout)
      @iobuf = iobuf
    end

    def print (sections)
      sections.each { |s| print_section s }
    end

    private

    def print_section (sec)
      @iobuf.puts ".section #{sec.name}"
      sec.each_block { |b| print_data_block sec, b }
      @iobuf.puts ""
    end

    def print_data_block (sec, block)
      @iobuf.puts ".globl\t#{block.name}" if block.type == :global
      @iobuf.puts "#{block.name}:" unless block.name == sec.name
      block.each_instruction { |i| print_instruction sec, block, i }
      @iobuf.puts ""
    end

    def print_instruction (sec, block, instruction)
      if sec.executable?
        @iobuf.puts "\t#{instruction.cmd}"
      else
        @iobuf.print "\t.byte #{instruction.bytes[0]}"
        instruction.bytes[1..-1].each do |byte|
          @iobuf.print ", 0x#{byte}"
        end
        @iobuf.puts ""
      end
    end
  end
end
