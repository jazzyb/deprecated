require 'calypso/file_store'
require 'calypso/logger'
require 'calypso/metadata'

module Calypso
  class FS
    def initialize
      # TODO remember to set the block_size and digest values
      @files = FileStore.connect(:adapter => 'sqlite', :database => ':memory:')
      @attrs = {}
      @files.keys.each { |filename| @attrs[filename] = Metadata.new(filename) }
    end

    def getattr (path)
      Logger.debug { "Calypso::FS: getattr() called" }
      @attrs[path]
    end

    def get_size (path)
      Logger.debug { "Calypso::FS: get_size() called" }
      @files[path].size
    end

    def readdir (path)
      Logger.debug { "Calypso::FS: readdir() called" }
      @files.keys.map { |filename| filename.sub('/', '') }
    end

    def create (path, mode=0600)
      Logger.debug { "Calypso::FS: create() called" }
      @files[path] = FileStore.new(path)
      @attrs[path] = Metadata.new(path, :mode => mode)
    end

    def open (path)
      Logger.debug { "Calypso::FS: open() called" }
      @attrs.has_key?(path) ? true : nil
    end

    def read (path, size, offset)
      Logger.debug { "Calypso::FS: read() called" }
      @files[path].read(size, offset)
    end

    def write (path, buf, size, offset)
      Logger.debug { "Calypso::FS: write() called" }
      @files[path].write(buf, offset)
      size
    end

    def truncate (path, offset)
      Logger.debug { "Calypso::FS: truncate() called" }
      return 1 if offset < 0
      @files[path].truncate(offset)
      0
    end

    def unlink (path)
      Logger.debug { "Calypso::FS: unlink() called" }
      return nil unless @files.has_key?(path)
      @files.delete(path).delete # delete the file_store and the mapping
      @attrs.delete path
    end

    def utime (path, mtime=Time.now.to_i)
      Logger.debug { "Calypso::FS: utime() called" }
      @attrs[path].mtime = mtime
    end

    def chown (path, uid, gid)
      Logger.debug { "Calypso::FS: chown() called" }
      @attrs[path].uid = uid unless uid == -1
      @attrs[path].gid = gid unless gid == -1
    end

    def chmod (path, mode)
      Logger.debug { "Calypso::FS: chmod() called" }
      @attrs[path].mode = mode
    end

    # Singleton implementation:
    #
    # We are rolling our own singleton pattern below instead of using the
    # built-in ruby implementation because calling the instance method from our
    # C code results in the following error:
    #
    #   undefined method `synchronize' for #<Mutex:0x847130c>
    #
    # I don't know why this error occurs, but since I don't think we need a
    # mutex for our particular implementation, we should be fairly safe rolling
    # our own.
    @@_instance = FS.new

    def self.instance
      @@_instance
    end

    private_class_method :new
  end
end
