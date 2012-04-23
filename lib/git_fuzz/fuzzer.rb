require 'fileutils'
require 'git_fuzz/repository'

module GitFuzz
  class Fuzzer
    def initialize (dir, seed=Random.new_seed)
      @dir = dir
      @repo = Repository.new dir, seed
      @rand = Random.new seed
      run "git init"
    end

    def run (cmd, dir=@dir)
      Dir.chdir(dir) do
        puts cmd
        system cmd
      end
    end

    def make_commit
      5.times { @repo.edit_rand_file(3) }
      adds = []
      5.times do
        # add a file to an already existing directory
        file = @repo.pick_file
        break if file.nil?
        dirs = file.split('/')[1...-1]
        path = @dir + "/" + dirs[0..(@rand.rand(dirs.size))].join('/')
        adds << @repo.create_file(path)
      end
      5.times { adds << @repo.create_file }
      run "git add #{adds.join(' ')}"
      run "git commit -a --allow-empty-message -m '#{@repo.dict.line 5}'"
    end

    def fuzz (ncommits)
      tar_dir = @dir + "-tars"
      ncommits.times do |count|
        make_commit
        FileUtils.mkdir_p tar_dir
        run "tar cvf #{@dir}#{count}.tar ../#@dir", tar_dir
      end
    end
  end
end
