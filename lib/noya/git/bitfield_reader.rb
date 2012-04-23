require 'noya/git/object_type'

module Noya::Git
  module BitFieldReader
    TYPE_FLAGS = /(?<flag>[01])(?<type>[01]{3})(?<size>[01]{4})/
    NEXT_FLAGS = /(?<flag>[01])(?<size>[01]{7})/
    def read_bitfield (byte, match_type=false)
      if match_type
        md = byte.unpack('B*')[0].match TYPE_FLAGS
        [md[:flag] == '1', ObjectType[md[:type].to_i(2)], md[:size]]
      else
        md = byte.unpack('B*')[0].match NEXT_FLAGS
        [md[:flag] == '1', md[:size]]
      end
    end
  end
end
