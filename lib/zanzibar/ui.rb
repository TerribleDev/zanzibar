require 'rubygems/user_interaction'

module Zanzibar
  ##
  # Prints messages out to stdout
  class Shell
    ##
    # The stream to write log messages (usually stdout)
    attr_writer :shell

    ##
    # Logging options and initializing stream
    def initialize(shell)
      @shell = shell
      @quiet = false
      @debug = ENV['DEBUG']
    end

    ##
    # Write a debug message if debug is enabled
    def debug(message = nil)
      @shell.say(message || yield) if @debug && !@quiet
    end

    ##
    # Write an info message unless we have silenced output
    def info(message = nil)
      @shell.say(message || yield) unless @quiet
    end

    ##
    # Ask the user for confirmation unless we have silenced output
    def confirm(message = nil)
      @shell.say(message || yield, :green) unless @quiet
    end

    ##
    # Print a warning
    def warn(message = nil)
      @shell.say(message || yield, :yellow)
    end

    ##
    # Print an error
    def error(message = nil)
      @shell.say(message || yield, :red)
    end

    ##
    # Enable silent mode
    def be_quiet!
      @quiet = true
    end

    ##
    # Enable debug mode
    def debug!
      @debug = true
    end
  end
end
