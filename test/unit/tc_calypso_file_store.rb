require 'calypso'
require 'sequel'
require 'test/unit'

Calypso::Logger.level = Calypso::Logger::INFO # turn off logging

class TestFileStore < Test::Unit::TestCase
  def test_db_creation
    dbname = '/tmp/test.db'
    dbconn = 'sqlite://' + dbname

    Calypso::FileStore.digest_algo_type = 8080
    assert_equal({}, Calypso::FileStore.connect(dbconn))
    db = Sequel.connect(dbconn)
    assert_equal([:blocks, :config, :files], db.tables.sort)
    expected = { :schema_version => Calypso::FileStore::SCHEMA_VERSION,
                 :block_size => Calypso::FileStore::DEFAULT_BLOCK_SIZE,
                 :digest_algo_type => 8080 }
    assert_equal([expected], db[:config].all)

    FileUtils.rm_f dbname
  end

  def test_initialize
  end
end
