require 'rubygems'
require 'sequel'

module Calypso
  class FileStore
    SCHEMA_VERSION = 1
    DEFAULT_BLOCK_SIZE = 1024
    DEFAULT_DIGEST_ALGO_TYPE = 0

    def self.block_size= (block_size)
      @@block_size = block_size
    end

    def self.digest_algo_type= (algo_type)
      @@digest_algo_type = algo_type
    end

    def self.connect (opts)
      @@db = Sequel.connect(opts)
      if @@db.tables.empty?
        create_database
      end
      {} # return hash of { cleartext-filename => FileStore.new }
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

    private

    # create a default file_store database
    def self.create_database
      # details on how information is to be stored in the database
      @@db.create_table :config do
        column :schema_version, :integer
        column :block_size, :integer
        column :digest_algo_type, :integer
      end

      # user info
=begin Right now, we don't care about user, but we'll need this table later.
      @@db.create_table :users do
        primary_key :id, :type => Bignum
        column :uuid, :string, :null => false, :unique => true
        column :symmetric_algo_type, :integer
        column :asymmetric_algo_type, :integer
        column :asymmetric_public_key, :blob
        column :space_limit, :integer
        column :total_space, :integer
      end
=end

      # file metadata
      @@db.create_table :files do
        primary_key :id, :type => Bignum
        #foreign_key :user_id, :users
        column :encrypted_symmetric_key, :string
        column :encrypted_filename, :blob
        column :encrypted_filename_signature, :string
      end

      # the contents of the files
      @@db.create_table :blocks do
        primary_key :id, :type => Bignum
        foreign_key :file_id, :files
        column :cleartext_offset, :integer
        column :cleartext_length, :integer
        column :encrypted_contents, :blob
        column :encrypted_contents_signature, :string
      end

      initialize_config
    end

    def self.initialize_config
      @@block_size ||= DEFAULT_BLOCK_SIZE
      @@digest_algo_type ||= DEFAULT_DIGEST_ALGO_TYPE
      @@db[:config].insert( :schema_version => SCHEMA_VERSION,
                            :block_size => @@block_size,
                            :digest_algo_type => @@digest_algo_type )
    end
  end
end
