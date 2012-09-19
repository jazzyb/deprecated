require 'syslog'

module Calypso
  class Logger
    DEBUG = 0
    OFF = 1

    @@level = DEBUG

    def self.debug (&dblk)
      Syslog.open($0, 0) do |log|
        log.debug dblk.call if @@level <= DEBUG
      end
    end

    def self.level= (level)
      @@level = level
    end
  end
end
