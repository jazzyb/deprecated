require 'ardis/elf_file'
require 'ardis/printer'
require 'ardis/section'
require 'tempfile'

module Ardis
  class Disassembler
    def initialize (filename)
      @elf = ElfFile.new filename
      @elf.readelf_symbols { |line| process_symbols line }
      @elf.readelf_section_headers { |line| process_sections line }
      @elf.objdump { |line| process_assembly line }
      @elf.resolve_instructions
    end

    def disassemble (iobuf)
      p = Printer.new iobuf
      p.print @elf
    end

    private

    SYMTAB_RE = %r{\A\s+(?<num>\d+):\s+
                        (?<value>[0-9a-f]+)\s+
                        (?<size>\d+)\s+
                        (?<type>\w+)\s+
                        (?<bind>\w+)\s+
                        (?<vis>\w+)\s+
                        (?<ndx>UND|ABS|\d+)\s+
                        (?<name>.*)\Z
    }x

    def process_symbols (string)
      @func_type ||= {}
      if (md = SYMTAB_RE.match string)
        if md[:type] == "FUNC"
          @func_type[md[:name]] = md[:bind] == "GLOBAL" ? :global : :local
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

    def process_sections (string)
      @section_names ||= []
      @flags ||= {}
      if (md = SECTION_HDR_RE.match string)
        @section_names << md[:name]
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

    def process_assembly (string)
      if (md = SECTION_RE.match string)
        @elf.append_section md[:name], @flags[md[:name]]
      elsif (md = DATA_BLOCK_RE.match string)
        @elf.append_data_block md[:name], @func_type[md[:name]]
      elsif (md = INSTRUCTION_RE.match string)
        @elf.append_instruction md[:addr], md[:bytes], md[:cmd]
      elsif (md = RELOC_RE.match string)
        if @section_names.include? md[:symbol]
          reloc = Section.origin_label md[:symbol]
        else
          reloc = md[:symbol]
        end
        @elf.append_reloc reloc
      end
    end
  end
end
