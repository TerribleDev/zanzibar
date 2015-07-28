require 'zanzibar/actions/base'
require 'zanzibar/error'
require 'zanzibar'
require 'zanzibar/defaults'

module Zanzibar
  module Actions
    # Fetch a single secret
    class Get < Base
      attr_accessor :zanibar_options
      attr_accessor :scrt_id

      def initialize(ui, options, scrt_id)
        super(ui, options)
        @scrt_id = scrt_id
        @zanzibar_options = {}
      end

      def run
        construct_options
        ensure_options

        fetch_secret(@scrt_id, options['filelabel'])
      end

      def fetch_secret(scrt_id, label = nil)
        scrt = ::Zanzibar::Zanzibar.new(@zanzibar_options)

        if label
          scrt.download_secret_file(scrt_id: scrt_id,
                                    type: label)
        else
          scrt.get_password(scrt_id)
        end
      end

      def construct_options
        @zanzibar_options[:wsdl] = construct_wsdl
        @zanzibar_options[:globals] = { ssl_verify_mode: :none } if options['ignoressl']
        @zanzibar_options[:domain] = options['domain']
        @zanzibar_options[:username] = options['username'] unless options['username'].nil?
        @zanzibar_options[:domain] = options['domain'] ? options['domain'] : 'local'
      end

      def construct_wsdl
        if options['wsdl'].nil? && options['server']
          DEFAULT_WSDL % options['server']
        else
          options['wsdl']
        end
      end

      def ensure_options
        return if @zanzibar_options[:wsdl]
        fail Error, NO_WSDL_ERROR
      end
    end
  end
end
