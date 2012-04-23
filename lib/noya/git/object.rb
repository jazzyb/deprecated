module Noya::Git
  class Object
    attr_reader :sha, :type, :size, :offset, :contents
    def initialize (contents, hash={})
      @contents = contents
      @sha = hash[:sha]
      @type = hash[:type]
      @size = hash[:size]
      @offset = hash[:offset]
    end

    # all deltas must define a patch_delta method to generate the decompressed,
    # patched contents
    def delta?
      respond_to? :patch_delta
    end
  end
end
