require 'ardis/printer'
require 'ardis/section'
require 'tempfile'

module Ardis
  class Disassembler
    def initialize (filename)
      readelf filename
      objdump filename
    end

    def disassemble (iobuf)
      p = Printer.new iobuf
      p.print @sections
    end

    private

    def run_cmd (cmd, filename)
      tmp = Tempfile.new filename
      system("#{cmd} #{filename} > #{tmp.path}")
      tmp.each { |line| yield line.rstrip }
      tmp.close!
    end

    def readelf (filename)
      readelf_symbols filename
      readelf_section_headers filename
    end

    def readelf_symbols (filename)
      run_cmd("readelf -s", filename) { |line| process_sym line }
    end

    def readelf_section_headers (filename)
      run_cmd("readelf -S", filename) { |line| process_flags line }
    end

    def objdump (filename)
      run_cmd("objdump -Drz", filename) { |line| process_asm line }
    end

    SYMTAB_RE = %r{\A\s+(?<num>\d+):\s+
                        (?<value>[0-9a-f]+)\s+
                        (?<size>\d+)\s+
                        (?<type>\w+)\s+
                        (?<bind>\w+)\s+
                        (?<vis>\w+)\s+
                        (?<ndx>UND|ABS|\d+)\s+
                        (?<name>.*)\Z
    }x

    def process_sym (string)
      @functions ||= {}
      if (md = SYMTAB_RE.match string)
        if md[:type] == "FUNC"
          @functions[md[:name]] = md[:bind] == "GLOBAL" ? :global : :local
        end
      end
    end

    SECTION_HDR_RE = %r{\A\s+\[\s*
                        (?<nr>\d+)\]\s+
                        (?<name>[.\-\w]+)\s+
                        (?<type>\w+)\s+
                        (?<addr>[0-9a-f]+)\s+
                        (?<off>[0-9a-f]+)\s+
                        (?<size>[0-9a-f]+)\s+
                        (?<es>[0-9a-f]{2})\s+
                        (?<flags>[WAXMSILGTExOop]*)\s+
                        (?<lk>\d+)\s+
                        (?<inf>\d+)\s+
                        (?<al>\d+)\Z
    }x

    def process_flags (string)
      @flags ||= {}
      if (md = SECTION_HDR_RE.match string)
        if (md[:flags].include? 'X')
          @flags[md[:name]] ||= []
          @flags[md[:name]] << :executable
        end
      end
    end

    SECTION_RE = /\ADisassembly of section (?<name>.*):\Z/
    DATA_BLOCK_RE = /\A[0-9a-f]+\s+<(?<name>.*)>:\Z/
    INSTRUCTION_RE = %r{\A\s+(?<addr>[0-9a-f]+):\s+
                             (?<bytes>([0-9a-f]{2}\s)+([0-9a-f]{2})?)\s*
                             (?<cmd>.*)\Z
    }x
    RELOC_RE = /(?<type>R_386_PC32|R_386_32)\s+(?<symbol>.*)\Z/

    def process_asm (string)
      if (md = SECTION_RE.match string)
        @curr_section = Section.new(md[:name], @flags[md[:name]])
        @sections ||= []
        @sections << @curr_section
      elsif (md = DATA_BLOCK_RE.match string)
        @curr_section.append_data_block md[:name], @functions[md[:name]]
      elsif (md = INSTRUCTION_RE.match string)
        @curr_section.append_instruction md[:addr], md[:bytes], md[:cmd]
      elsif (md = RELOC_RE.match string)
        @curr_section.append_reloc md[:symbol]
      end
    end
  end
end
