require 'zanzibar/version'
require 'savon'
require 'io/console'
require 'fileutils'
require 'yaml'
require 'zanzibar/client'

module Zanzibar
  ##
  # High-level operations for downloading things from Secret Server
  class Zanzibar
    ##
    # @param args{:domain, :wsdl, :pwd, :username, :globals{}}
    def initialize(args = {})
      @username = resolve_username(args)
      @wsdl = resolve_wsdl(args)
      @password = resolve_password(args)
      @domain = resolve_domain(args)
      args[:globals] = {} unless args[:globals]
      @client = Client.new(@username, @password, @domain, @wsdl, args[:globals])
    end

    ##
    # Gets the user's password if none is provided in the constructor.
    # @return [String] the password for the current user
    def prompt_for_password
      puts "Please enter password for #{@username}:"
      STDIN.noecho(&:gets).chomp.tap do
        puts 'Using password to login...'
      end
    end

    ##
    # Gets the wsdl document location if none is provided in the constructor
    # @return [String] the location of the WDSL document
    def prompt_for_wsdl_location
      puts 'Enter the URL of the Secret Server WSDL:'
      STDIN.gets.chomp
    end

    ##
    # Gets the domain of the Secret Server installation if none is provided in the constructor
    # @return [String] the domain of the secret server installation
    def prompt_for_domain
      puts 'Enter the domain of your Secret Server:'
      STDIN.gets.chomp
    end

    ##
    # Retrieve the value from a field label of a secret
    # Will raise an error if there are any issues
    # @param [Integer] the secret id
    # @param [String] the field label to get, defaults to Password
    # @return [String] the value for the given field label
    def get_fieldlabel_value(scrt_id, fieldlabel = 'Password')
      secret = @client.get_secret(scrt_id)
      secret_items = secret[:secret][:items][:secret_item]
      return @client.get_secret_item_by_field_name(secret_items, fieldlabel)[:value]
    rescue Savon::Error => err
      raise "There was an error getting '#{fieldlabel}' for secret #{scrt_id}: #{err}"
    end

    ##
    # Retrieve a simple password from a secret
    # Calls get get_fieldlabel_value()
    # @param [Integer] the secret id
    # @return [String] the password for the given secret
    def get_password(scrt_id)
      get_fieldlabel_value(scrt_id)
    end

    ##
    # Get the password, save it to a file, and return the path to the file.
    def get_username_and_password_and_save(scrt_id, path, name)
      secret_items = @client.get_secret(scrt_id)[:secret][:items][:secret_item]
      password = @client.get_secret_item_by_field_name(secret_items, 'Password')[:value]
      username = @client.get_secret_item_by_field_name(secret_items, 'Username')[:value]
      save_username_and_password_to_file(password, username, path, name)
      File.join(path, name)
    end

    ##
    # Write the password to a file. Intended for use with a Zanzifile
    def save_username_and_password_to_file(password, username, path, name)
      user_pass = { 'username' => username.to_s, 'password' => password.to_s }.to_yaml
      File.open(File.join(path, name), 'wb') do |file|
        file.print user_pass
      end
    end

    ##
    # Downloads a file for a secret and places it where Zanzibar is running, or :path if specified
    # Raise on error
    # @param [Hash] args, :scrt_id, :type (one of "Private Key", "Public Key", "Attachment"), :scrt_item_id - optional, :path - optional
    def download_secret_file(args = {})
      response = @client.download_file_attachment_by_item_id(args[:scrt_id], args[:scrt_item_id], args[:type])
      raise "There was an error getting the #{args[:type]} for secret #{args[:scrt_id]}: #{response[:errors][:string]}" if response[:errors]
      return write_secret_to_file(args[:path], response)
    rescue Savon::Error => err
      raise "There was an error getting the #{args[:type]} for secret #{args[:scrt_id]}: #{err}"
    end

    ##
    # Download a private key secret
    # @deprecated
    def download_private_key(args = {})
      args[:type] = 'Private Key'
      download_secret_file(args)
    end

    ##
    # Download a public key secret
    # @deprecated
    def download_public_key(args = {})
      args[:type] = 'Public Key'
      download_secret_file(args)
    end

    ##
    # Download an arbitrary secret attachment
    # @deprecated
    def download_attachment(args = {})
      args[:type] = 'Attachment'
      download_secret_file(args)
    end

    private

    def make_or_find_path(path = nil)
      FileUtils.mkdir_p(path) if path
      path || '.'
    end

    def resolve_username(args = {})
      if args[:username]
        args[:username]
      elsif ENV['ZANZIBAR_USER']
        ENV['ZANZIBAR_USER']
      else
        ENV['USER']
      end
    end

    def resolve_wsdl(args = {})
      args[:wsdl]
    end

    def resolve_password(args = {})
      if args[:pwd]
        args[:pwd]
      elsif ENV['ZANZIBAR_PASSWORD']
        ENV['ZANZIBAR_PASSWORD']
      else
        prompt_for_password
      end
    end

    def resolve_domain(args = {})
      if args[:domain]
        args[:domain]
      else
        prompt_for_domain
      end
    end

    def write_secret_to_file(path, secret_response)
      path = make_or_find_path(path)
      filepath = File.join(path, secret_response[:file_name])

      File.open(filepath, 'wb') do |file|
        file.puts Base64.decode64(secret_response[:file_attachment])
      end

      filepath
    end
  end
end
