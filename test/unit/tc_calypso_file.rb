require 'calypso'
require 'sequel'
require 'test/unit'

module Calypso
  class File
    attr_reader :file_id
  end
end

Calypso::Logger.level = Calypso::Logger::INFO # turn off logging

class TestFile < Test::Unit::TestCase
  def setup
    @dbname = '/tmp/test.db'
    @dbconn = 'sqlite://' + @dbname
    @memconn = { :adapter => 'sqlite', :database => ':memory:' }
  end

  def teardown
    FileUtils.rm_f @dbname
    Calypso::File.block_size = Calypso::File::DEFAULT_BLOCK_SIZE
  end

  def test_db_creation
    Calypso::File.digest_algo_type = 8080
    assert_equal({}, Calypso::File.connect(@dbconn))
    db = Sequel.connect(@dbconn)
    assert_equal([:blocks, :config, :files], db.tables.sort)
    expected = { :schema_version => Calypso::File::SCHEMA_VERSION,
                 :block_size => Calypso::File::DEFAULT_BLOCK_SIZE,
                 :digest_algo_type => 8080 }
    assert_equal([expected], db[:config].all)
  end

  def test_db_read
    db = 'sqlite://test/db/tc_calypso_file/test_db_read1.db'
    assert_equal(['/bar', '/baz', '/foo'],
                 Calypso::File.connect(db).keys.sort)
  end

  def test_initialize_empty_block
    Calypso::File.connect(@dbconn)
    db = Sequel.connect(@dbconn)
    name = "hello"
    f = Calypso::File.new(name)
    set = db[:files].where(:id => f.file_id).all
    assert_equal(1, set.size)
    row = set[0]
    assert_equal(f.file_id, row[:id])
    assert_equal(name, row[:encrypted_filename])

    set = db[:blocks].where(:file_id => f.file_id).all
    assert_equal(1, set.size)
    row = set[0]
    assert_equal(0, row[:cleartext_offset])
    assert_equal(0, row[:cleartext_length])
    assert_equal("", row[:encrypted_contents])
  end

  def test_initialize_long_block
    blksz = 30
    Calypso::File.block_size = blksz
    Calypso::File.connect(@dbconn)
    db = Sequel.connect(@dbconn)
    name = "hello"
    contents = "abcdefghijklmnopqrstuvwxyz"
    contents += "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    contents += "0123456789"
    contents *= 20

    f = Calypso::File.new(name, contents)
    set = db[:blocks].where(:file_id => f.file_id).all
    assert_equal(contents.size / blksz + 1, set.size)

    blocks = contents.scan(/.{1,#{blksz}}/m)
    blocks.each_index do |i|
      assert_equal(blksz * i, set[i][:cleartext_offset])
      assert_equal(blocks[i].size, set[i][:cleartext_length])
      assert_equal(blocks[i], set[i][:encrypted_contents])
    end

    g = Calypso::File.new("hello2", ("a" * blksz) + "b")
    assert_not_equal(f.file_id, g.file_id)
    set = db[:blocks].where(:file_id => g.file_id).order(:cleartext_offset).all
    assert_equal("a" * blksz, set[0][:encrypted_contents])
    assert_equal("b", set[1][:encrypted_contents])
  end

  def test_size
    Calypso::File.connect(@memconn)
    contents = "abcdefghijklmnopqrstuvwxyz"
    contents += "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    contents += "0123456789"
    contents *= Calypso::File::DEFAULT_BLOCK_SIZE
    f = Calypso::File.new("f", contents)
    assert_equal(contents.size, f.size)
    g = Calypso::File.new("g", "")
    assert_equal(0, g.size)
  end

  def test_read
    Calypso::File.block_size = 100
    Calypso::File.connect(@memconn)
    contents = "abcdefghijklmnopqrstuvwxyz"
    contents += "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    contents += "0123456789"
    contents *= Calypso::File::DEFAULT_BLOCK_SIZE
    f = Calypso::File.new("f", contents)
    assert_equal(contents, f.read)
    assert_equal(contents[0...2000], f.read(2000))
    assert_equal(contents[1000...2000], f.read(1000, 1000))
    assert_equal(contents[998...2014], f.read(1016, 998))
    assert_equal(contents[25...75], f.read(50, 25))
  end

  def test_write
    blksz = 100
    Calypso::File.block_size = blksz
    Calypso::File.connect(@dbconn)
    db = Sequel.connect(@dbconn)
    contents = "abcdefghijklmnopqrstuvwxyz"
    contents += "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    contents += "0123456789"
    contents *= Calypso::File::DEFAULT_BLOCK_SIZE
    f = Calypso::File.new("f", contents)
    contents.insert(10, "888")
    f.write("888", 10)
    set = db[:blocks].where(:file_id => f.file_id).order(:cleartext_offset).all
    assert_equal(contents[0...blksz], set[0][:encrypted_contents])
    assert_equal(contents[blksz...(blksz+3)], set[1][:encrypted_contents])
    assert_equal(contents[(blksz+3)...(blksz*2+3)], set[2][:encrypted_contents])

    b = '8' * 200
    contents.insert(101, b)
    f.write(b, 101)
    set = db[:blocks].where(:file_id => f.file_id).order(:cleartext_offset).all
    assert_equal(contents[blksz...(blksz*2)], set[1][:encrypted_contents])
    assert_equal(contents[(blksz*2)...(blksz*3)], set[2][:encrypted_contents])
    assert_equal(contents, f.read)

    b = '8' * 150
    contents += b
    f.write(b, f.size)
    assert_equal(contents, f.read)
  end

  def test_truncate
    blksz = 100
    Calypso::File.block_size = blksz
    Calypso::File.connect(@memconn)
    contents = "abcdefghijklmnopqrstuvwxyz"
    contents += "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    contents += "0123456789"
    contents *= Calypso::File::DEFAULT_BLOCK_SIZE
    f = Calypso::File.new("f", contents)
    contents = contents[0...2000]
    f.truncate(2000)
    assert_equal(contents, f.read)
  end

  def test_delete
    blksz = 10
    Calypso::File.block_size = blksz
    Calypso::File.connect(@dbconn)
    db = Sequel.connect(@dbconn)
    contents = "abcdefghijklmnopqrstuvwxyz"
    contents += "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    contents += "0123456789"
    f = Calypso::File.new("f", contents)
    f.delete
    assert_equal([], db[:blocks].where(:file_id => f.file_id).all)
    assert_equal([], db[:files].where(:id => f.file_id).all)
  end
end
