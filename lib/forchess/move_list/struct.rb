require 'ffi'

module Forchess
  class MoveList
    module MoveListLayout
      def self.included (base)
        base.class_eval do
          layout :moves, :pointer,
                 :index, :uint32
        end
      end
    end

    class ManagedMoveListStruct < FFI::ManagedStruct
      include MoveListLayout

      def self.release (ptr)
        Forchess.fc_mlist_free(ptr)
        Forchess.free_object(ptr)
      end
    end

    class MoveListStruct < FFI::Struct
      include MoveListLayout
    end
  end
end
