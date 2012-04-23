require 'fileutils'
require 'git_fuzz/dictionary'

module GitFuzz
  class Repository
    attr_reader :dict
    def initialize (dir, seed=Random.new_seed)
      @repo = dir
      FileUtils.mkdir_p dir
      @files = list_files_recursively dir
      @dict = Dictionary.new 'doc/dictionary.txt', seed
      @rand = Random.new seed
    end

    def list_files_recursively (dir)
      ret = []
      Dir.foreach(dir) do |filename|
        next if filename[0] == '.'
        if File.directory? filename
          ret += list_files_recursively filename
        else
          ret << dir + "/" + filename
        end
      end
      ret
    end

    def pick_file
      return nil if @files.empty?
      @files[@rand.rand(@files.size)]
    end

    def write_file (filename)
      File.open(filename, "w") do |file|
        @rand.rand(20).times do
          file.puts @dict.line(5)
        end
      end
    end

    def create_file (path=nil)
      name = @dict.pick_word + ".txt"
      path = @repo + "/" + @dict.line(4).split.join('/') if path.nil?
      FileUtils.mkdir_p path
      name = path + "/" + name
      write_file name
      @files << name
      name.gsub(/\A#@repo\/*/, '')
    end

    def edit_rand_file (nedits)
      filename = pick_file
      return if filename.nil?
      lines = []
      File.open(filename) do |file|
        file.each { |line| lines << line.strip.split }
      end

      nedits.times do
        # replace a single word in the file
        return if lines.empty?
        line = lines[@rand.rand(lines.size)]
        return if line.empty?
        line[@rand.rand(line.size)] = @dict.pick_word
      end

      # remove some lines and add some lines
      @rand.rand(3).times do
        return if lines.empty?
        lines.delete_at(@rand.rand(lines.size))
      end
      @rand.rand(3).times do
        if lines.empty?
          lines << @dict.line(5).split
        else
          idx = @rand.rand(lines.size)
          lines = lines[0...idx] + [@dict.line(5).split] + lines[idx..-1]
        end
      end

      File.open(filename, "w") do |file|
        lines.each do |line|
          file.puts line.join(' ')
        end
      end
    end
  end
end
