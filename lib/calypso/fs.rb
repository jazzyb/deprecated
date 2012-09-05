require 'calypso/logger'

module Calypso
  class FS
    def initialize
      @files = {}
    end

    def get_size (path)
      Logger.debug { "Calypso::FS: get_size() called" }
      return nil unless @files.has_key? path
      @files[path].size
    end

    def readdir (path)
      Logger.debug { "Calypso::FS: readdir() called" }
      @files.keys.map { |filename| filename.sub('/', '') }
    end

    def create (path)
      Logger.debug { "Calypso::FS: create() called" }
      @files[path] = ""
    end

    def open (path)
      Logger.debug { "Calypso::FS: open() called" }
      @files.has_key?(path) ? true : nil
    end

    def read (path, size, offset)
      Logger.debug { "Calypso::FS: read() called" }
      @files[path][offset...(offset+size)]
    end

    def write (path, buf, size, offset)
      Logger.debug { "Calypso::FS: write() called" }
      @files[path].insert(offset, buf)
      size
    end

    # Singleton implementation:
    #
    # We are rolling our own singleton pattern below instead of using the built-in
    # ruby implementation because calling the instance method from our C code
    # results in the following error:
    #
    #   undefined method `synchronize' for #<Mutex:0x847130c>
    #
    # I don't know why this error occurs, but since I don't think we need a mutex
    # for our particular implementation, we should be fairly safe rolling our own.
    @@_instance = FS.new

    def self.instance
      @@_instance
    end

    private_class_method :new
  end
end
