require 'calypso/file_attr'
require 'calypso/logger'

module Calypso
  class FS
    def initialize
      @files = {}
    end

    def getattr (path)
      Logger.debug { "Calypso::FS: get_size() called" }
      @files[path]
    end

    def readdir (path)
      Logger.debug { "Calypso::FS: readdir() called" }
      @files.keys.map { |filename| filename.sub('/', '') }
    end

    def create (path)
      Logger.debug { "Calypso::FS: create() called" }
      @files[path] = FileAttr.new("")
    end

    def open (path)
      Logger.debug { "Calypso::FS: open() called" }
      @files.has_key?(path) ? true : nil
    end

    def read (path, size, offset)
      Logger.debug { "Calypso::FS: read() called" }
      @files[path].contents[offset...(offset+size)]
    end

    def write (path, buf, size, offset)
      Logger.debug { "Calypso::FS: write() called" }
      @files[path].contents.insert(offset, buf)
      size
    end

    def truncate (path, offset)
      Logger.debug { "Calypso::FS: truncate() called" }
      return 1 if offset < 0
      @files[path].contents = @files[path].contents[0...offset]
      0
    end

    def unlink (path)
      Logger.debug { "Calypso::FS: unlink() called" }
      return nil unless @files.has_key?(path)
      @files.delete path
    end

    def utime (path, mtime=Time.now.to_i)
      Logger.debug { "Calypso::FS: utime() called" }
      @files[path].mtime = mtime
    end

    def chown (path, uid, gid)
      Logger.debug { "Calypso::FS: chown() called" }
      @files[path].uid = uid unless uid == -1
      @files[path].gid = gid unless gid == -1
    end

    def chmod (path, mode)
      Logger.debug { "Calypso::FS: chown() called" }
      @files[path].mode = mode
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
