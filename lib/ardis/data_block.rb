module Ardis
  class DataBlock
    attr_reader :name, :type
    def initialize (name, type)
      @name, @type = name, type
    end

    def << (instruction)
      @instructions ||= []
      @instr_indices ||= {}
      instruction.label = @name if @instructions.empty?
      @instr_indices[instruction] = @instructions.size
      @instructions << instruction
    end

    def append_reloc (reloc)
      @curr_instruction.reloc = reloc
    end

    # 'from' is the jmp or call instruction and 'to' is the instruction we are
    # jmping/calling to; sets and returns a unique relative label for the 'to'
    # instruction
    def create_label (from, to)
      @jump_map ||= {}
      @jump_map[to] ||= []
      @jump_map[to] << from
      return to.label if to.label

      @label_counter ||= 0
      @label_counter += 1
      to.label = ".L#@name$#@label_counter"
    end

    def create_jump_table_label
      @jmptbl_counter ||= 0
      @jmptbl_counter += 1
      ".L#{@name}_jmptbl$#@jmptbl_counter"
    end

    def each_instruction
      @instructions.each { |i| yield i }
    end

    def prev_instruction (instruction)
      return nil if @instructions.nil? || @instr_indices.nil?
      idx = @instr_indices[instruction]
      return nil if idx.nil? || idx == 0
      @instructions[idx - 1]
    end

    def find_jmp (instruction)
      @jump_map[instruction] || []
    end
  end
end
