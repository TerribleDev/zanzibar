require 'zanzibar/actions/base'
require 'zanzibar/error'
require 'zanzibar'
require 'zanzibar/defaults'

module Zanzibar
  module Actions
    # Fetch a single secret
    class Get < Base
      ##
      # The options to use when initializing our Zanzibar client
      attr_accessor :zanibar_options

      ##
      # The id of the secret to download
      attr_accessor :scrt_id

      ##
      # Initialize the action
      def initialize(ui, options, scrt_id)
        super(ui, options)
        @scrt_id = scrt_id
        @zanzibar_options = {}
      end

      ##
      # Ensure we have the options we need and download the secret
      def run
        construct_options
        ensure_options

        fetch_secret(@scrt_id)
      end

      ##
      # Actually download the secret
      def fetch_secret(scrt_id)
        scrt = ::Zanzibar::Zanzibar.new(@zanzibar_options)

        if @zanzibar_options[:filelabel]
          scrt.download_secret_file(scrt_id: scrt_id,
                                    type: @zanzibar_options[:filelabel])
        else
          scrt.get_fieldlabel_value(scrt_id, @zanzibar_options[:fieldlabel])
        end
      end

      ##
      # Coalesce our options and some defaults to ensure we are ready to run
      def construct_options
        @zanzibar_options[:wsdl] = construct_wsdl
        @zanzibar_options[:globals] = { ssl_verify_mode: :none } if options['ignoressl']
        @zanzibar_options[:domain] = options['domain']
        @zanzibar_options[:username] = options['username'] unless options['username'].nil?
        @zanzibar_options[:domain] = options['domain'] ? options['domain'] : 'local'
        @zanzibar_options[:fieldlabel] = options['fieldlabel'] || 'Password'
        @zanzibar_options[:filelabel] = options['filelabel'] if options['filelabel']
      end

      ##
      # Construct a WSDL URL from the server hostname if necessary
      def construct_wsdl
        if options['wsdl'].nil? && options['server']
          DEFAULT_WSDL % options['server']
        else
          options['wsdl']
        end
      end

      ##
      # Make sure a proper WSDL was constructed
      def ensure_options
        return if @zanzibar_options[:wsdl]
        raise Error, NO_WSDL_ERROR
      end
    end
  end
end
