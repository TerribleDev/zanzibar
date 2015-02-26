require 'zanzibar/actions/base'
require 'zanzibar/error'
require 'zanzibar'

module Zanzibar
  module Actions
    # Download or verify the secrets in a Zanzifile
    class Bundle < Base
      attr_accessor :settings
      attr_accessor :remote_secrets
      attr_accessor :local_secrets
      attr_accessor :update
      attr_accessor :zanzibar

      def initialize(ui, options, args = {})
        super(ui, options)
        @update = args[:update]
      end

      def run
        ensure_zanzifile
        load_required_secrets
        ensure_secrets_path
        validate_environment
        load_resolved_secrets if resolved_file?
        validate_local_secrets unless @update
        run!
      end

      private

      def run!
        if need_secrets?
          new_secrets = download_remote_secrets
          update_resolved_file new_secrets
        else
          debug { 'No secrets to download...' }
        end
      end

      def ensure_zanzifile
        fail Error, NO_ZANZIFILE_ERROR unless File.exist? ZANZIFILE_NAME
        debug { "#{ZANZIFILE_NAME} located..." }
      end

      def ensure_secrets_path
        FileUtils.mkdir_p(@settings['secret_dir']) unless @settings['secret_dir'] == nil
      end

      def resolved_file?
        File.exist? RESOLVED_NAME
      end

      def load_required_secrets
        zanzifile = YAML.load_file(ZANZIFILE_NAME)
        @settings = zanzifile['settings'] || {}
        @remote_secrets = zanzifile['secrets'] || {}
        @local_secrets = {}
      end

      def validate_environment
        return unless @settings.empty? || @remote_secrets.empty?
        fail Error, INVALID_ZANZIFILE_ERROR
      end

      def load_resolved_secrets
        @local_secrets = YAML.load_file RESOLVED_NAME
      end

      def need_secrets?
        !@remote_secrets.empty?
      end

      def validate_local_secrets
        @local_secrets.each do |key, secret|
          if File.exist?(secret[:path]) && secret[:hash] == Digest::MD5.file(secret[:path]).hexdigest
            debug { "#{key} found locally, skipping download..." }
            @remote_secrets.delete key
          end
        end
      end

      def download_remote_secrets
        args = @settings['ignore_ssl'] ? { ssl_verify_mode: :none } : {}

        downloaded_secrets = {}
        remote_secrets.each do |key, secret|
          downloaded_secrets[key] = download_one_secret(secret['id'],
                                                        secret['label'],
                                                        @settings['secret_dir'],
                                                        args,
                                                        secret['name'] || "#{secret['id']}_password")

          debug { "Downloaded secret: #{key} to #{@settings['secret_dir']}..." }
        end

        downloaded_secrets
      end

      def download_one_secret(scrt_id, label, path, args, name = nil)
        if label == 'Password'
          path = zanzibar(args).get_username_and_password_and_save(scrt_id, path, name)
          { path: path, hash: Digest::MD5.file(path).hexdigest }
        else
          path = zanzibar(args).download_secret_file(scrt_id: scrt_id,
                                                   type: label,
                                                   path: path)
          { path: path, hash: Digest::MD5.file(path).hexdigest }
        end
      end

      def update_resolved_file(new_secrets)
        @local_secrets.merge! new_secrets

        File.open(RESOLVED_NAME, 'w') do |out|
          YAML.dump(@local_secrets, out)
        end

        debug { 'Updated resolved file...' }
      end

      def zanzibar(args)
        @zanzibar ||= ::Zanzibar::Zanzibar.new(wsdl: @settings['wsdl'],
                                               domain: @settings['domain'],
                                               globals: args)
      end
    end
  end
end
