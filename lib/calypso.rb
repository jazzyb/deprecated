# FIXME
#
# Cthulhu, I hope this doesn't break anything...
#
# This work-around exists because of (what I believe) is an error in the ruby
# development libraries telling me that Mutex has no method 'synchronize'.  When
# the problem is fixed, I will remove this:
class ::Mutex
  def synchronize
    yield
  end
end

module Calypso
  autoload :Metadata,  'calypso/metadata'
  autoload :FileStore, 'calypso/file_store'
  autoload :FS,        'calypso/fs'
  autoload :Logger,    'calypso/logger'
end
