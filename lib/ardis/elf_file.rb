require 'ardis/section'

module Ardis
  class ElfFile
    def initialize (filename)
      @filename = filename
    end

    def readelf_symbols
      run_cmd("readelf -s") { |line| yield line }
    end

    def readelf_section_headers
      run_cmd("readelf -S") { |line| yield line }
    end

    def objdump
      run_cmd("objdump -Drz") { |line| yield line }
    end

    def append_section (name, flags)
      @curr_section = Section.new(self, name, flags)
      @sections ||= []
      @sections << @curr_section
      @section_names ||= {}
      @section_names[@curr_section.name] = @curr_section
    end

    def append_data_block (name, type)
      @curr_section.append_data_block name, type
    end

    def append_instruction (addr, bytes, cmd)
      @curr_section.append_instruction addr, bytes, cmd
    end

    def append_reloc (symbol)
      @curr_section.append_reloc symbol
    end

    def each_section
      @sections.each { |s| yield s }
    end

    def section (name)
      @section_names[name]
    end

    private

    def run_cmd (cmd)
      tmp = Tempfile.new @filename
      system("#{cmd} #@filename > #{tmp.path}")
      raise "error running command '#{cmd} #@filename'" unless $?.success?
      tmp.each { |line| yield line.rstrip }
      tmp.close!
    end
  end
end
