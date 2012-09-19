module Calypso
  class Metadata
    attr_accessor :mode, :uid, :gid, :mtime
    attr_reader :name
    def initialize (name, hash_args={})
      @name = name
      # assumes the rest of the arguments are all integers
      @mode = hash_args[:mode] || 0600
      @uid = hash_args[:uid] || Process.uid
      @gid = hash_args[:gid] || Process.gid
      @mtime = hash_args[:mtime] || Time.now.to_i
    end
  end
end
