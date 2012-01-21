require 'ffi'

module Forchess
  module Common
    def self.included (base)
      def base.attach_function (*args)
        Forchess.attach_function(*args)
      end
    end

    def create_struct_object (struct_class, ptr=nil)
      if ptr.nil?
        ptr = FFI::MemoryPointer.new(struct_class, 1)
        # this useless cast gets around a bug in my version of FFI
        # FIXME  Will this cause a memory leak?
        ptr = FFI::Pointer.new ptr
      end
      struct_class.new ptr
    end
  end
end
