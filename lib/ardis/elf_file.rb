require 'ardis/section'
require 'ardis/data_block'
require 'ardis/instruction_factory'

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
      @curr_section = Section.new(name, flags)
      @sections ||= []
      @sections << @curr_section
      @section_names ||= {}
      @section_names[@curr_section.name] = @curr_section
    end

    def append_data_block (name, type)
      @curr_section << DataBlock.new(name, type)
    end

    def append_instruction (addr, bytes, cmd)
      @curr_section << InstructionFactory.create(addr, bytes, cmd)
    end

    def append_reloc (reloc)
      @curr_section << reloc
    end

    def each_section
      @sections.each { |s| yield s }
    end

    def section (name)
      @section_names[name]
    end

    # this method goes through all the executable instructions and updates the
    # 'cmd' strings to point to relative symbols rather than absolute
    # addresses;
    # for example:  "jmp fe4" will become "jmp .Lnew_label" and the label
    # '.Lnew_label' will be placed at what was the address of fe4
    def resolve_instructions
      resolve_last = []
      each_section do |sec|
        next unless sec.executable?
        sec.each_block do |blk|
          blk.each_instruction do |i|
            if i.resolve_after?
              resolve_last << [sec, blk, i]
              next
            end
            i.resolve self, sec, blk
          end
        end
      end
      resolve_last.each { |sec, blk, i| i.resolve self, sec, blk }
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
