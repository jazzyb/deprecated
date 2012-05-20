module SWFBoat::Tag
  class FileAttributes
    def initialize (data)
      bits = data.unpack('B*')[0]
      @use_direct_blit = (bits[1] == '1')
      @use_gpu = (bits[2] == '1')
      @has_metadata = (bits[3] == '1')
      @action_script_3 = (bits[4] == '1')
      @use_network = (bits[7] == '1')
      # all other bits are currently reserved
    end

    def use_direct_blit?
      @use_direct_blit
    end

    def use_gpu?
      @use_gpu
    end

    def has_metadata?
      @has_metadata
    end

    def action_script_3?
      @action_script_3
    end

    def use_network?
      @use_network
    end
  end
end
