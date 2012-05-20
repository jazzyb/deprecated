require 'swf_boat/tag/do_abc'
require 'swf_boat/tag/file_attributes'
require 'swf_boat/tag/unknown'

module SWFBoat::Tag
  class Factory
    def self.create (code, data)
      case code
      when 69
        FileAttributes.new(data)
      when 82
        DoABC.new(data)
      else
        Unknown.new(code, data)
      end
    end
  end
end
