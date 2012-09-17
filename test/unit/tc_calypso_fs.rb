require 'calypso'
require 'test/unit'

module Calypso
  class FS
    attr_accessor :files, :attrs
    def self.reset
      @@_instance.files = {}
      @@_instance.attrs = {}
    end

    # 'hash' is a mapping of filename => [contents, args]
    def preset (hash)
      FS.reset
      hash.each do |name, arr|
        @files[name] = FileStore.new(name, arr[0])
        if arr.size == 2
          @attrs[name] = FileAttr.new(name, arr[1])
        else
          @attrs[name] = FileAttr.new(name)
        end
      end
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
    @fs.preset({file => ["jjjjj", args]})
    assert_equal(5, @fs.get_size(file))
    assert_equal(args[:mtime], @fs.getattr(file).mtime)
    assert_equal(args[:mode], @fs.getattr(file).mode)
    assert_equal(args[:uid], @fs.getattr(file).uid)
    assert_equal(args[:gid], @fs.getattr(file).gid)
  end

  def test_readdir
    @fs.preset({ '/foo' => [''],
                 '/bar' => [''],
                 '/baz' => [''] })
    assert_equal(['bar', 'baz', 'foo'],
                 @fs.readdir('/').sort)
  end

  def test_create
    file = "/hello"
    @fs.create file
    assert(@fs.attrs.has_key? file)
    assert_equal(0, @fs.files[file].size)
  end

  def test_open
    file = "/hello"
    assert_nil(@fs.open file)
    @fs.preset({file => ["jjjjj"]})
    assert(@fs.open file)
  end

  def test_read
    file = "/hello"
    @fs.preset({file => ["abcdefghijklmnopqrstuvwxyz"]})
    assert_equal("abcdefghij", @fs.read(file, 10, 0))
    assert_equal("stu", @fs.read(file, 3, 18))
    assert_equal("z", @fs.read(file, 100, 25))
  end

  def test_write
    file = "/hello"
    @fs.preset({file => ["abcdefghijklmnopqrstuvwxyz"]})
    @fs.write file, "888", 3, 10
    assert_equal("abcdefghij888klmnopqrstuvwxyz", @fs.files[file].read)
    @fs.preset({file => ["abcdefghijklmnopqrstuvwxyz"]})
    @fs.write file, "888", 3, 26
    assert_equal("abcdefghijklmnopqrstuvwxyz888", @fs.files[file].read)
    @fs.write file, "888", 3, 0
    assert_equal("888abcdefghijklmnopqrstuvwxyz888", @fs.files[file].read)
  end

  def test_truncate
    file = "/hello"
    @fs.preset({file => ["abcdefghijklmnopqrstuvwxyz"]})
    assert_equal(0, @fs.truncate(file, 10))
    assert_equal("abcdefghij", @fs.files[file].read)
    @fs.truncate file, 100
    assert_equal("abcdefghij", @fs.files[file].read)
    @fs.truncate file, 0
    assert_equal("", @fs.files[file].read)

    @fs.preset({file => ["abcdefghij"]})
    assert_equal(1, @fs.truncate(file, -1))
    assert_equal("abcdefghij", @fs.files[file].read)
  end

  def test_unlink
    file = "/hello"
    @fs.preset({file => [""],
                "file2" => [""]})
    assert_nil(@fs.unlink "file3")
    assert_not_nil(@fs.unlink file)
    assert_nil(@fs.unlink file)
    assert_equal(["file2"], @fs.attrs.keys)
  end

  def test_utime
    file = "/hello"
    @fs.preset({file => ['', :mtime => 0]})
    t = Time.now.to_i
    @fs.utime(file, t)
    assert_equal(t, @fs.attrs[file].mtime)
  end

  def test_chown
    file = "/hello"
    @fs.preset({file => ['', :uid => 1, :gid => 1]})
    @fs.chown(file, 1000, -1)
    assert_equal(1000, @fs.attrs[file].uid)
    assert_equal(1, @fs.attrs[file].gid)
    @fs.preset({file => ['', :uid => 1, :gid => 1]})
    @fs.chown(file, -1, 1000)
    assert_equal(1, @fs.attrs[file].uid)
    assert_equal(1000, @fs.attrs[file].gid)
  end

  def test_chmod
    file = "/hello"
    @fs.preset({file => ['', :mode => 0600]})
    @fs.chmod(file, 0755)
    assert_equal(0755, @fs.attrs[file].mode)
  end
end
