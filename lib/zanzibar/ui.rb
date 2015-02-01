require 'rubygems/user_interaction'

module Zanzibar
  # Prints messages out to stdout
  class Shell
    attr_writer :shell

    def initialize(shell)
      @shell = shell
      @quiet = false
      @debug = ENV['DEBUG']
    end

    def debug(message = nil)
      @shell.say(message || yield) if @debug && !@quiet
    end

    def info(message = nil)
      @shell.say(message || yield) unless @quiet
    end

    def confirm(message = nil)
      @shell.say(message || yield, :green) unless @quiet
    end

    def warn(message = nil)
      @shell.say(message || yield, :yellow)
    end

    def error(message = nil)
      @shell.say(message || yield, :red)
    end

    def be_quiet!
      @quiet = true
    end

    def debug!
      @debug = true
    end
  end
end
