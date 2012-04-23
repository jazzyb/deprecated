module GitFuzz
  class Dictionary
    def initialize (filename, seed=Random.new_seed)
      @words = []
      File.open(filename) do |file|
        file.each do |line|
          begin
            next if line.include? "'"
            @words << line.strip
          rescue ArgumentError
            next # we read a word that we can't process
          end
        end
      end
      @rand = Random.new seed
    end

    def pick_word
      @words[@rand.rand(@words.size)]
    end

    def line (nwords)
      ret = []
      @rand.rand(0..nwords).times { ret << pick_word }
      ret.join ' '
    end
  end
end
