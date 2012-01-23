require 'ffi'

require 'forchess/ai/algorithm'

module Forchess
  class AI
    module AILayout
      def self.included (base)
        base.class_eval do
          layout :board, :pointer,
                 :bv, :pointer,
                 :mlv, :pointer,
                 :timeout, :long, # time_t
                 :algo, Algorithm
        end
      end
    end

    class ManagedAIStruct < FFI::ManagedStruct
      include AILayout

      def self.release (ptr)
        Forchess.free_object(ptr)
      end
    end

    class AIStruct < FFI::Struct
      include AILayout
    end
  end
end
