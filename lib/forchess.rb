require 'ffi'

module Forchess
  extend FFI::Library
  ffi_lib 'ext/libforchess/lib/libforchess.so'
end

require 'forchess/forchess'
