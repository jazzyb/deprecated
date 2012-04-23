require 'noya/git/object'
require 'zlib'

module Noya::Git
  class LooseObject
    def self.foreach (repo_dir)
      path = repo_dir + '/.git/objects/'
      Dir.foreach(path) do |dirname|
        next if ['.', '..', 'info', 'pack'].include? dirname
        Dir.foreach(path + dirname) do |filename|
          next if filename == '.' || filename == '..'
          yield extract_object_from_file(path + dirname + '/' + filename)
        end
      end
    end

    def self.extract_object_from_file (filename)
      sha = filename.split('/')[-2..-1].join
      File.open(filename, 'rb') do |file|
        header, content = Zlib::Inflate.inflate(file.read).split("\0", 2)
        type, size = header.split
        create_object(sha, type, size.to_i, content)
      end
    end

    def self.create_object (sha, type, size, content)
      case type
      when 'blob', 'commit', 'tree'
        Object.new(content, :sha => sha,
                            :type => type,
                            :size => size)
      else
        raise "cannot handle type '#{type}'"
      end
    end
  end
end
