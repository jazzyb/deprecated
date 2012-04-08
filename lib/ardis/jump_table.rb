module Ardis
  class JumpTable
    # text_section is the section that is referencing the jump table
    # data_section is the section that holds the jump table
    # block is the block that is referencing the jump table
    # jmp_instr is the instruction referencing the jump table
    # offset is the offset into jmptbl_section where the jump table is
    # tblsz is the number of addresses being referenced in the jump table
    attr_reader :name, :data_section, :text_section
    def initialize (text_section, data_section, block, jmp_instr, offset, tblsz)
      @text_section, @data_section = text_section, data_section
      @name = block.create_jump_table_label
      @jmps = []
      tblsz.times do |idx|
        hex_addr = data_section.get_long(4 * idx + offset)
        blk, instr = text_section.find_address(hex_addr)
        @jmps << blk.create_label(jmp_instr, instr)
      end
    end

    # yields the string label for each jump
    def each_jump
      @jmps.each { |j| yield j }
    end
  end
end
