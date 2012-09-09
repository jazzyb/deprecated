module Calypso
  class FileStore
    def self.connect(db)
      # TODO
      @@db = db
    end

    def initialize (filename, contents="")
      @name = filename
      @contents = contents
    end

    def size
      @contents.size
    end

    def read (amount=size(), offset=0)
      @contents[offset...(offset+amount)]
    end

    def write (buffer, offset)
      @contents.insert(offset, buffer)
    end

    def truncate (offset)
      @contents = @contents[0...offset]
    end
  end
end
