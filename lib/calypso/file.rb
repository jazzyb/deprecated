require 'rubygems'
require 'sequel'

module Calypso
  class File
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
      files = {}
      @@db[:files].all.each do |row|
        files[row[:encrypted_filename]] = Calypso::File.new(row[:id])
      end
      files
    end

    def initialize (identifier, contents="")
      raise "no calypso database" unless defined? @@db

      # If the identifier for the file is an Integer, then we assume this file
      # already exists in the database and that identifier must be the file id.
      # Otherwise, we assume that it is a String and represents the name of a
      # new file to create.
      if identifier.kind_of? Integer
        @file_id = identifier
      else
        @file_id = @@db[:files].insert( :encrypted_filename => identifier )
        insert_blocks contents.scan(/.{1,#@@block_size}/m)
      end
    end

    def size
      return @size if @size
      row = get_file_blocks.
        order(:cleartext_offset).
        last
      @size = row[:cleartext_offset] + row[:cleartext_length]
    end

    def read (amount=size(), offset=0)
      return "" if amount == 0
      amount = size() - offset if amount > size() - offset

      first = get_file_blocks.
        where { cleartext_offset <= offset }.
        order(:cleartext_offset).
        last

      start = offset - first[:cleartext_offset]
      if offset + amount <= first[:cleartext_offset] + first[:cleartext_length]
        return first[:encrypted_contents][start...(start + amount)]
      end

      rest = get_file_blocks.
        where { cleartext_offset > offset }.
        where { cleartext_offset < (offset + amount) }.
        order(:cleartext_offset).
        all
      ret = first[:encrypted_contents][start..-1]
      amount -= ret.size
      rest[0...-1].each do |row|
        ret += row[:encrypted_contents]
        amount -= row[:cleartext_length]
      end
      ret + rest[-1][:encrypted_contents][0...amount]
    end

    def write (buffer, offset)
      @size = nil # all destructive methods must invalidate @size

      orig_buf_len = buffer.size
      row = get_file_blocks.
        where { cleartext_offset <= offset }.
        order(:cleartext_offset).
        last

      # update the first block
      rel_off = offset - row[:cleartext_offset]
      buf = buffer.slice!(0...(@@block_size - rel_off))
      str = row[:encrypted_contents]
      str.insert(rel_off, buf)
      buffer += str.slice!(@@block_size..-1) if str.size >= @@block_size
      update_block( row[:id], :encrypted_contents => str,
                              :cleartext_length => str.size )

      # update all remaining blocks
      start_off = row[:cleartext_offset] + @@block_size
      set = get_file_blocks.
        where { cleartext_offset > offset }.
        all
      set.each do |row|
        new_off = row[:cleartext_offset] + orig_buf_len
        update_block( row[:id], :cleartext_offset => new_off )
      end

      return if buffer.empty?
      # finally, insert the new blocks to hold the rest of the buffer
      insert_blocks(buffer.scan(/.{1,#@@block_size}/m), start_off)
    end

    def truncate (offset)
      @size = nil # all destructive methods must invalidate @size

      # delete all blocks higher than the offset
      get_file_blocks.
        where { cleartext_offset > offset }.
        delete

      # now truncate the last block
      row = get_file_blocks.
        order(:cleartext_offset).
        last
      rel_off = offset - row[:cleartext_offset]
      str = row[:encrypted_contents][0...rel_off]
      update_block( row[:id], :encrypted_contents => str,
                              :cleartext_length => str.size )
    end

    def delete
      get_file_blocks.delete
      @@db[:files].where(:id => @file_id).delete
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

    def insert_blocks (blocks, index=0)
      if blocks.empty?
        # insert a blank block if the file is empty
        @@db[:blocks].insert( :file_id => @file_id,
                              :cleartext_offset => index,
                              :cleartext_length => 0,
                              :encrypted_contents => "" )
        return
      end

      blocks.each do |block|
        @@db[:blocks].insert( :file_id => @file_id,
                              :cleartext_offset => index,
                              :cleartext_length => block.size,
                              :encrypted_contents => block )
        index += @@block_size
      end
    end

    def get_file_blocks
      @@db[:blocks].where(:file_id => @file_id)
    end

    def update_block (id, args)
      @@db[:blocks].where(:id => id).update(args)
    end
  end
end
