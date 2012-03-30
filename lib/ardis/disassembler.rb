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

    def readelf (filename)
      tmp = Tempfile.new(filename)
      system("readelf -s #{filename} > #{tmp.path}")
      tmp.each { |line| process_sym line.rstrip }
      tmp.close!
    end

    def objdump (filename)
      tmp = Tempfile.new(filename)
      system("objdump -Drz #{filename} > #{tmp.path}")
      tmp.each { |line| process_asm line.rstrip }
      tmp.close!
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
          if md[:bind] == "GLOBAL"
            @functions[md[:name]] = :global
          else
            @functions[md[:name]] = :local
          end
        end
      end
    end

    SECTION_RE = /\ADisassembly of section (?<name>.*):\Z/
    DATA_BLOCK_RE = /\A[0-9a-f]+\s+<(?<name>.*)>:\Z/
    INSTRUCTION_RE = %r{\A\s+(?<addr>[0-9a-f]+):\s+
                             (?<bytes>([0-9a-f]{2}\s)+([0-9a-f]{2})?)\s*
                             (?<cmd>.*)\Z
    }x

    def process_asm (string)
      @sections ||= []
      if (md = SECTION_RE.match string)
        @sections << Section.new(md[:name])
      elsif (md = DATA_BLOCK_RE.match string)
        @sections[-1].append_data_block md[:name], @functions[md[:name]]
      elsif (md = INSTRUCTION_RE.match string)
        @sections[-1].append_instruction md[:addr], md[:bytes], md[:cmd]
      end
    end
  end
end
