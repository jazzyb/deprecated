require 'ardis/instruction'

module Ardis
  module Command
    class Jmp < Instruction
      NEAR_JUMP_RE = /\A(?<jmp>j\w+\s+)(?<addr>[0-9a-f]+)/
      JUMP_TABLE_RE = %r{\A(?<jmp>j\w+\s+\*)
                           (?<offset>0x[0-9a-f]+)
                           (?<rest>.*)\Z
      }x

      def resolve (elf, section, block)
        if (md = NEAR_JUMP_RE.match @cmd)
          resolve_near_jump section, md[:jmp], md[:addr]
        elsif (md = JUMP_TABLE_RE.match @cmd)
          resolve_jump_table md[:jmp], md[:offset], md[:rest], elf, section,
            block
        else
          warn "unrecognized jmp command '#@addr: #@cmd'"
        end
      end

      def resolve_after?
        JUMP_TABLE_RE =~ @cmd
      end

      private

      def resolve_near_jump (section, jmp, addr)
        if @reloc
          @cmd = jmp + @reloc
        else
          blk, instr = section.find_address addr
          if blk.nil? || instr.nil?
            warn "unknown address in jmp command '#{addr}: #{cmd}'"
            return
          end
          @cmd = jmp + blk.create_label(self, instr)
        end
      end

      def resolve_jump_table (jmp, offset, rest, elf, section, block)
        unless @reloc
          warn "no reloc exists for jmp command '#@addr: #@cmd'"
          return
        end
        tblsz = find_table_size block
        label = elf.section(Section.name @reloc)
        if label.nil?
          warn "jmp reloc '#@reloc' is not a section '#@addr: #@cmd'"
          return
        end

        # TODO: create a jump table class or something that the printer can
        # output when it gets to this jmp
        puts ".section #{label.name}"
        puts ".align 4"
        puts ".L<new_jump_table_label>:"
        tblsz.times do |idx|
          long = label.get_long(4 * idx + offset.to_i(16))
          puts ".long #{long}"
        end
        puts ".text"
      end

      # find the cmp instruction and return the size that refers to the jump
      # table in question
      def find_table_size (block)
        cmp_re = /\Acmp\w*\s+\$(?<size>0x[0-9a-f]+),/
        jmps = []
        prev = self
        loop do
          if prev
            if prev.is_ja?
              possible_cmp = block.prev_instruction prev
              if possible_cmp.is_cmp? && (md = cmp_re.match possible_cmp.cmd)
                #puts "Found cmp for jmp tbl '#@addr: #@cmd':"
                #puts "    #{possible_cmp.addr}: #{possible_cmp.cmd}"
                return md[:size].to_i(16) + 1
              end

            elsif prev.label
              jmps += block.find_jmp prev
            end
            prev = block.prev_instruction prev
          end

          count = jmps.size
          count.times do
            i = jmps.pop
            if i.is_jbe?
              possible_cmp = block.prev_instruction i
              if possible_cmp.is_cmp? && (md = cmp_re.match possible_cmp.cmd)
                #puts "Found cmp for jmp tbl '#@addr: #@cmd':"
                #puts "    #{possible_cmp.addr}: #{possible_cmp.cmd}"
                return md[:size].to_i(16) + 1
              end
            end

            if i.label
              jmps += block.find_jmp i.label
            end
            jmps << block.prev_instruction(i)
          end
          break if prev.nil? && jmps.empty?
        end
      end
    end
  end
end
