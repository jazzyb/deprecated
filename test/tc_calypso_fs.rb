require 'calypso'
require 'logger'
require 'test/unit'

module Calypso
  class FS
    attr_accessor :files
    def self.reset
      @@_instance.files = {}
    end
  end
end

$log.level = Logger::INFO

class TestFS < Test::Unit::TestCase
  def setup
    @fs = Calypso::FS.instance()
  end

  def teardown
    Calypso::FS.reset()
  end

  def test_get_size
    file = "/hello"
    assert_nil(@fs.get_size file)
    @fs.files = {file => "jjjjj"}
    assert_equal(5, @fs.get_size(file))
  end

  def test_readdir
    @fs.files = { '/foo' => '',
                  '/bar' => '',
                  '/baz' => '' }
    assert_equal(['bar', 'baz', 'foo'],
                 @fs.readdir('/').sort)
  end

  def test_create
    file = "/hello"
    @fs.create file
    assert(@fs.files.has_key? file)
    assert_equal(0, @fs.files[file].size)
  end

  def test_open
    file = "/hello"
    assert_nil(@fs.open file)
    @fs.files = {file => "jjjjj"}
    assert(@fs.open file)
  end

  def test_read
    file = "/hello"
    @fs.files = {file => "abcdefghijklmnopqrstuvwxyz"}
    assert_equal("abcdefghij", @fs.read(file, 10, 0))
    assert_equal("stu", @fs.read(file, 3, 18))
    assert_equal("z", @fs.read(file, 100, 25))
  end

  def test_write
    file = "/hello"
    @fs.files = {file => "abcdefghijklmnopqrstuvwxyz"}
    @fs.write file, "888", 3, 10
    assert_equal("abcdefghij888klmnopqrstuvwxyz", @fs.files[file])
    @fs.files = {file => "abcdefghijklmnopqrstuvwxyz"}
    @fs.write file, "888", 3, 26
    assert_equal("abcdefghijklmnopqrstuvwxyz888", @fs.files[file])
    @fs.write file, "888", 3, 0
    assert_equal("888abcdefghijklmnopqrstuvwxyz888", @fs.files[file])
  end
end
