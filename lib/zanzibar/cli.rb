require 'thor'
require 'thor/actions'
require 'zanzibar/version'
require 'zanzibar/cli'
require 'zanzibar/ui'
require 'zanzibar/actions'
require 'zanzibar/error'
require 'zanzibar/defaults'

module Zanzibar
  # The `zanzibar` binay/thor application main class
  class Cli < Thor
    include Thor::Actions

    attr_accessor :ui

    def initialize(*)
      super
      the_shell = (options['no-color'] ? Thor::Shell::Basic.new : shell)
      @ui = Shell.new(the_shell)
      @ui.be_quiet! if options['quiet']
      @ui.debug! if options['verbose']

      debug_header
    end

    desc 'version', 'Display your Zanzibar verion'
    def version
      say "#{APPLICATION_NAME} Version: #{VERSION}"
    end

    desc 'init', "Create an empty #{ZANZIFILE_NAME} in the current directory."
    option 'verbose', type: :boolean, default: false, aliases: :v
    option 'wsdl', type: :string, aliases: :w,
                   default: DEFAULT_WSDL % DEFAULT_SERVER,
                   desc: 'The URI of the WSDL file for your Secret Server instance'
    option 'domain', type: :string, default: 'local', aliases: :d,
                     desc: 'The logon domain for your Secret Server account'
    option 'force', type: :boolean, default: false, aliases: :f,
                    desc: 'Recreate the Zanzifile if one already exists.'
    option 'secretdir', type: :string, default: 'secrets/', aliases: :s,
                        desc: 'The directory to which secrets should be downloaded.'
    option 'ignoressl', type: :boolean, default: 'false', aliases: :k,
                        desc: 'Don\'t check the SSL certificate of Secret Server'
    def init
      run_action { init! }
    end

    desc 'bundle', "Fetch secrets declared in your #{ZANZIFILE_NAME}"
    option 'verbose', type: :boolean, default: false, aliases: :v
    def bundle
      run_action { bundle! }
    end

    desc 'plunder', "Alias to `#{APPLICATION_NAME} bundle`", :hide => true
    alias_method :plunder, :bundle

    desc 'update', "Redownload all secrets in your #{ZANZIFILE_NAME}"
    option 'verbose', type: :boolean, default: false, aliases: :v
    def update
      run_action { update! }
    end

    desc 'get SECRETID', 'Fetch a single SECRETID from Secret Server'
    option 'domain', type: :string, aliases: :d,
                     desc: 'The logon domain to use when logging in.'
    option 'server', type: :string, aliases: :s,
                     desc: 'The Secret Server hostname or IP'
    option 'wsdl', type: :string, aliases: :w,
                   desc: 'Full path to the Secret Server WSDL'
    option 'ignoressl', type: :boolean, aliases: :k,
                        desc: 'Don\'t verify Secret Server\'s SSL certificate'
    option 'filelabel', type: :string, aliases: :f,
                        desc: 'Specify a file (by label) to download'
    option 'username', type: :string, aliases: :u
    option 'password', type: :string, aliases: :p
    def get(scrt_id)
      run_action { get! scrt_id }
    end

    private

    def debug_header
      @ui.debug { "Running #{APPLICATION_NAME} in debug mode..." }
      @ui.debug { "Ruby Version: #{RUBY_VERSION}" }
      @ui.debug { "Ruby Platform: #{RUBY_PLATFORM}" }
      @ui.debug { "#{APPLICATION_NAME} Version: #{VERSION}" }
    end

    # Run the specified action and rescue errors we
    # explicitly send back to format them
    def run_action(&_block)
      yield
    rescue ::Zanzibar::Error => e
      @ui.error e
      abort "Fatal error: #{e.message}"
    end

    def init!
      say "Initializing a new #{ZANZIFILE_NAME} in the current directory..."
      Actions::Init.new(@ui, options).run
      say "Your #{ZANZIFILE_NAME} has been created!"
      say 'You should check the settings and add your secrets.'
      say 'Then run `zanzibar bundle` to fetch them.'
    end

    def bundle!
      say "Checking for secrets declared in your #{ZANZIFILE_NAME}..."
      Actions::Bundle.new(@ui, options).run
      say 'Finished downloading secrets!'
    end

    def update!
      say "Redownloading all secrets declared in your #{ZANZIFILE_NAME}..."
      Actions::Bundle.new(@ui, options, update: true).run
      say 'Finished downloading secrets!'
    end

    def get!(scrt_id)
      say Actions::Get.new(@ui, options, scrt_id).run
    end
  end
end
