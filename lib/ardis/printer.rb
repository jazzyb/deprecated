require 'ardis/section'

module Ardis
  class Printer
    def initialize (iobuf=$stdout)
      @iobuf = iobuf
    end

    def print (elf_file)
      elf_file.each_section { |s| print_section s unless blacklisted? s.name }
    end

    private

    def blacklisted? (sec_name)
      [".comment", ".eh_frame"].include? sec_name
    end

    # is 'name' only composed of GAS-legal characters?
    def is_valid_name? (name)
      /[-]/ !~ name
    end

    def print_section (sec)
      @iobuf.puts ".section #{sec.name}"
      @iobuf.puts Section.origin_label(sec.name) + ":"
      sec.each_block { |b| print_data_block sec, b }
      @iobuf.puts ""
    end

    def print_data_block (sec, block)
      @iobuf.puts ".globl\t#{block.name}" if block.type == :global
      if block.name != sec.name
        if is_valid_name? block.name
          @iobuf.puts "#{block.name}:"
        else
          warn "ignoring invalid data block name '#{block.name}'"
        end
      end
      block.each_instruction { |i| print_instruction sec, block, i }
      @iobuf.puts ""
    end

    def print_instruction (sec, block, instruction)
      if instruction.label && instruction.label != block.name
        @iobuf.puts "#{instruction.label}:"
      end

      if sec.executable?
        @iobuf.puts "\t#{instruction.cmd}"
        print_jump_table(instruction.jmptbl) unless instruction.jmptbl.nil?
      else
        @iobuf.print "\t.byte 0x#{instruction.bytes[0]}"
        instruction.bytes[1..-1].each do |byte|
          @iobuf.print ", 0x#{byte}"
        end
        @iobuf.puts ""
      end
    end

    def print_jump_table (jmptbl)
      @iobuf.puts "\t.section #{jmptbl.data_section.name}"
      @iobuf.puts "\t.align 4"
      @iobuf.puts "#{jmptbl.name}:"
      jmptbl.each_jump { |jmp| @iobuf.puts "\t.long #{jmp}" }
      @iobuf.puts "\t.section #{jmptbl.text_section.name}"
    end
  end
end
