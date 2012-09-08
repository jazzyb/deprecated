require 'calypso'
require 'test/unit'

module Calypso
  class FS
    attr_accessor :files
    def self.reset
      @@_instance.files = {}
    end
  end
end

Calypso::Logger.level = Calypso::Logger::INFO # turn off logging

class TestFS < Test::Unit::TestCase
  def setup
    @fs = Calypso::FS.instance()
  end

  def teardown
    Calypso::FS.reset()
  end

  def test_getattr
    file = "/hello"
    assert_nil(@fs.getattr file)
    args = {
      :mtime => Time.now.to_i,
      :uid => 34,
      :gid => 89,
      :mode => 1001
    }
    @fs.files = {file => Calypso::FileAttr.new("jjjjj", args)}
    assert_equal("jjjjj", @fs.getattr(file).contents)
    assert_equal(args[:mtime], @fs.getattr(file).mtime)
    assert_equal(args[:mode], @fs.getattr(file).mode)
    assert_equal(args[:uid], @fs.getattr(file).uid)
    assert_equal(args[:gid], @fs.getattr(file).gid)
  end

  def test_readdir
    @fs.files = { '/foo' => Calypso::FileAttr.new(''),
                  '/bar' => Calypso::FileAttr.new(''),
                  '/baz' => Calypso::FileAttr.new('') }
    assert_equal(['bar', 'baz', 'foo'],
                 @fs.readdir('/').sort)
  end

  def test_create
    file = "/hello"
    @fs.create file
    assert(@fs.files.has_key? file)
    assert_equal(0, @fs.files[file].contents.size)
  end

  def test_open
    file = "/hello"
    assert_nil(@fs.open file)
    @fs.files = {file => Calypso::FileAttr.new("jjjjj")}
    assert(@fs.open file)
  end

  def test_read
    file = "/hello"
    @fs.files = {file => Calypso::FileAttr.new("abcdefghijklmnopqrstuvwxyz")}
    assert_equal("abcdefghij", @fs.read(file, 10, 0))
    assert_equal("stu", @fs.read(file, 3, 18))
    assert_equal("z", @fs.read(file, 100, 25))
  end

  def test_write
    file = "/hello"
    @fs.files = {file => Calypso::FileAttr.new("abcdefghijklmnopqrstuvwxyz")}
    @fs.write file, "888", 3, 10
    assert_equal("abcdefghij888klmnopqrstuvwxyz", @fs.files[file].contents)
    @fs.files = {file => Calypso::FileAttr.new("abcdefghijklmnopqrstuvwxyz")}
    @fs.write file, "888", 3, 26
    assert_equal("abcdefghijklmnopqrstuvwxyz888", @fs.files[file].contents)
    @fs.write file, "888", 3, 0
    assert_equal("888abcdefghijklmnopqrstuvwxyz888", @fs.files[file].contents)
  end

  def test_truncate
    file = "/hello"
    @fs.files = {file => Calypso::FileAttr.new("abcdefghijklmnopqrstuvwxyz")}
    assert_equal(0, @fs.truncate(file, 10))
    assert_equal("abcdefghij", @fs.files[file].contents)
    @fs.truncate file, 100
    assert_equal("abcdefghij", @fs.files[file].contents)
    @fs.truncate file, 0
    assert_equal("", @fs.files[file].contents)

    @fs.files = {file => Calypso::FileAttr.new("abcdefghij")}
    assert_equal(1, @fs.truncate(file, -1))
    assert_equal("abcdefghij", @fs.files[file].contents)
  end

  def test_unlink
    file = "/hello"
    @fs.files = {file => Calypso::FileAttr.new(""),
                 :file2 => Calypso::FileAttr.new("")}
    assert_nil(@fs.unlink "file3")
    assert_not_nil(@fs.unlink file)
    assert_nil(@fs.unlink file)
    assert_equal([:file2], @fs.files.keys)
  end

  def test_utime
    file = "/hello"
    @fs.files = {file => Calypso::FileAttr.new('', :mtime => 0)}
    t = Time.now.to_i
    @fs.utime(file, t)
    assert_equal(t, @fs.files[file].mtime)
  end

  def test_chown
    file = "/hello"
    @fs.files = {file => Calypso::FileAttr.new('', :uid => 1, :gid => 1)}
    @fs.chown(file, 1000, -1)
    assert_equal(1000, @fs.files[file].uid)
    assert_equal(1, @fs.files[file].gid)
    @fs.files = {file => Calypso::FileAttr.new('', :uid => 1, :gid => 1)}
    @fs.chown(file, -1, 1000)
    assert_equal(1, @fs.files[file].uid)
    assert_equal(1000, @fs.files[file].gid)
  end

  def test_chmod
    file = "/hello"
    @fs.files = {file => Calypso::FileAttr.new('', :mode => 0600)}
    @fs.chmod(file, 0755)
    assert_equal(0755, @fs.files[file].mode)
  end
end
