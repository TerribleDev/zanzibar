require 'zanzibar/version'
require 'savon'
require 'io/console'
require 'fileutils'
require 'yaml'

module Zanzibar
  ##
  # Class for interacting with Secret Server
  class Zanzibar
    ##
    # @param args{:domain, :wsdl, :pwd, :username, :globals{}}

    def initialize(args = {})
      if args[:username]
        @@username = args[:username]
      elsif ENV['ZANZIBAR_USER']
        @@username = ENV['ZANZIBAR_USER']
      else
        @@username = ENV['USER']
      end

      if args[:wsdl]
        @@wsdl = args[:wsdl]
      else
        @@wsdl = get_wsdl_location
      end

      if args[:pwd]
        @@password = args[:pwd]
      elsif ENV['ZANZIBAR_PASSWORD']
        @@password = ENV['ZANZIBAR_PASSWORD']
      else
        @@password = prompt_for_password
      end

      if args[:domain]
        @@domain = args[:domain]
      else
        @@domain = prompt_for_domain
      end
      args[:globals] = {} unless args[:globals]
      init_client(args[:globals])
    end

    def get_client_username
      @@username
    end

    def get_client_password
      @@password
    end

    ## Initializes the Savon client class variable with the wdsl document location and optional global variables
    # @param globals{}, optional

    def init_client(globals = {})
      globals = {} if globals.nil?
      @@client = Savon.client(globals) do
        wsdl @@wsdl
      end
    end

    ## Gets the user's password if none is provided in the constructor.
    # @return [String] the password for the current user

    def prompt_for_password
      puts "Please enter password for #{@@username}:"
      STDIN.noecho(&:gets).chomp.tap do
        puts "Using password to login..."
      end
    end

    ## Gets the wsdl document location if none is provided in the constructor
    # @return [String] the location of the WDSL document

    def prompt_for_wsdl_location
      puts 'Enter the URL of the Secret Server WSDL:'
      STDIN.gets.chomp
    end

    ## Gets the domain of the Secret Server installation if none is provided in the constructor
    # @return [String] the domain of the secret server installation

    def prompt_for_domain
      puts 'Enter the domain of your Secret Server:'
      STDIN.gets.chomp
    end

    ## Get an authentication token for interacting with Secret Server. These are only good for about 10 minutes so just get a new one each time.
    # Will raise an error if there is an issue with the authentication.
    # @return the authentication token for the current user.

    def get_token
      response = @@client.call(:authenticate, message: { username: @@username, password: @@password, organization: '', domain: @@domain })
                 .hash[:envelope][:body][:authenticate_response][:authenticate_result]
      fail "Error generating the authentication token for user #{@@username}: #{response[:errors][:string]}"  if response[:errors]
      response[:token]
    rescue Savon::Error => err
      raise "There was an error generating the authentiaton token for user #{@@username}: #{err}"
    end

    ## Get a secret returned as a hash
    # Will raise an error if there was an issue getting the secret
    # @param [Integer] the secret id
    # @return [Hash] the secret hash retrieved from the wsdl

    def get_secret(scrt_id, token = nil)
      secret = @@client.call(:get_secret, message: { token: token || get_token, secretId: scrt_id }).hash[:envelope][:body][:get_secret_response][:get_secret_result]
      fail "There was an error getting secret #{scrt_id}: #{secret[:errors][:string]}" if secret[:errors]
      return secret
    rescue Savon::Error => err
      raise "There was an error getting the secret with id #{scrt_id}: #{err}"
    end

    ## Retrieve a simple password from a secret
    # Will raise an error if there are any issues
    # @param [Integer] the secret id
    # @return [String] the password for the given secret

    def get_password(scrt_id)
      secret = get_secret(scrt_id)
      secret_items = secret[:secret][:items][:secret_item]
      return get_secret_item_by_field_name(secret_items, 'Password')[:value]
    rescue Savon::Error => err
      raise "There was an error getting the password for secret #{scrt_id}: #{err}"
    end

    ## Get the password, save it to a file, and return the path to the file.
    def get_username_and_password_and_save(scrt_id, path, name)
      secret_items = get_secret(scrt_id)[:secret][:items][:secret_item]
      password = get_secret_item_by_field_name(secret_items, 'Password')[:value]
      username = get_secret_item_by_field_name(secret_items, 'Username')[:value]
      save_username_and_password_to_file(password, username, path, name)
      return File.join(path, name)
    end

    def write_secret_to_file(path, secret_response)
      File.open(File.join(path, secret_response[:file_name]), 'wb') do |file|
        file.puts Base64.decode64(secret_response[:file_attachment])
      end
    end

    ## Write the password to a file. Intended for use with a Zanzifile
    def save_username_and_password_to_file(password, username, path, name)
      user_pass = {'username' => username.to_s, 'password' => password.to_s}.to_yaml
      File.open(File.join(path, name), 'wb') do |file|
        file.print user_pass
      end
    end

    def get_secret_item_by_field_name(secret_items, field_name)
      secret_items.each do |item|
        return item if item[:field_name] == field_name
      end
    end

    ## Get the secret item id that relates to a key file or attachment.
    # Will raise on error
    # @param [Integer] the secret id
    # @param [String] the type of secret item to get, one of privatekey, publickey, attachment
    # @return [Integer] the secret item id

    def get_scrt_item_id(scrt_id, type, token)
      secret = get_secret(scrt_id, token)
      secret_items = secret[:secret][:items][:secret_item]
      begin
        return get_secret_item_by_field_name(secret_items, type)[:id]
      rescue
        raise "Unknown type, #{type}."
      end
    end

    ## Downloads a file for a secret and places it where Zanzibar is running, or :path if specified
    # Raise on error
    # @param [Hash] args, :scrt_id, :type (one of "Private Key", "Public Key", "Attachment"), :scrt_item_id - optional, :path - optional

    def download_secret_file(args = {})
      token = get_token
      FileUtils.mkdir_p(args[:path]) if args[:path]
      path = args[:path] ? args[:path] : '.' ## The File.join below doesn't handle nils well, so let's take that possibility away.
      begin
        response = @@client.call(:download_file_attachment_by_item_id, message:
          { token: token, secretId: args[:scrt_id], secretItemId: args[:scrt_item_id] || get_scrt_item_id(args[:scrt_id], args[:type], token) })
                   .hash[:envelope][:body][:download_file_attachment_by_item_id_response][:download_file_attachment_by_item_id_result]
        fail "There was an error getting the #{args[:type]} for secret #{args[:scrt_id]}: #{response[:errors][:string]}"  if response[:errors]
        write_secret_to_file(path, response)
        return File.join(path, response[:file_name])
      rescue Savon::Error => err
        raise "There was an error getting the #{args[:type]} for secret #{args[:scrt_id]}: #{err}"
      end
    end

    ## Methods to maintain backwards compatibility
    def download_private_key(args = {})
      args[:type] = 'Private Key'
      download_secret_file(args)
    end

    def download_public_key(args = {})
      args[:type] = 'Public Key'
      download_secret_file(args)
    end

    def download_attachment(args = {})
      args[:type] = 'Attachment'
      download_secret_file(args)
    end
  end
end
