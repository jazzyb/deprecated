require 'noya/git/loose_object'
require 'noya/git/pack_file'

module Noya::Git
  class Repository

    # gathers together all the objects in the repository
    def initialize (repo_dir)
      @repo = repo_dir
      @objects = []
      @sha_obj_map = {}
      LooseObject.foreach(@repo) do |obj|
        @sha_obj_map[obj.sha] = obj
        @objects << obj
      end

      @ofs_obj_map = {}
      PackFile.foreach(@repo) do |obj|
        @sha_obj_map[obj.sha] = obj
        @ofs_obj_map[obj.offset] = obj
        @objects << obj
      end

      @objects.each do |obj|
        obj.patch_delta(@sha_obj_map, @ofs_obj_map) if obj.delta?
      end
    end

    # yields each object in the repo in sorted order based on the value of the
    # SHA1 string
    def each_object
      @objects.sort { |a, b| a.sha <=> b.sha }.each { |o| yield o }
    end
  end
end
