require 'logger'
$log = Logger.new("/tmp/fuse-test.txt")
$log.level = Logger::DEBUG

module Calypso
  autoload :FS, 'calypso/fs'
end
