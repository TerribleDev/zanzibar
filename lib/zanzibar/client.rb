require 'zanzibar/version'
require 'savon'
require 'io/console'
require 'fileutils'
require 'yaml'

module Zanzibar
  ##
  # Class for performing low-level WSDL actions against Secret Server
  class Client
    ##
    # Initializes the Savon client class variable with the wdsl document location and optional global variables
    # @param globals{}, optional
    def initialize(username, password, domain, wsdl, globals = {})
      @username = username
      @password = password
      @domain = domain

      globals = {} if globals.nil?

      wsdl_loc = wsdl
      @client = Savon.client(globals) do
        wsdl wsdl_loc
      end
    end

    ##
    # Get an authentication token for interacting with Secret Server. These are only good for about 10 minutes so just get a new one each time.
    # Will raise an error if there is an issue with the authentication.
    # @return the authentication token for the current user.
    def generate_token
      response = @client.call(:authenticate, message: { username: @username, password: @password, organization: '', domain: @domain })
                        .hash[:envelope][:body][:authenticate_response][:authenticate_result]
      raise "Error generating the authentication token for user #{@username}: #{response[:errors][:string]}" if response[:errors]
      response[:token]
    rescue Savon::Error => err
      raise "There was an error generating the authentiaton token for user #{@username}: #{err}"
    end

    ##
    # Get a secret returned as a hash
    # Will raise an error if there was an issue getting the secret
    # @param [Integer] the secret id
    # @return [Hash] the secret hash retrieved from the wsdl
    def get_secret(scrt_id, token = nil)
      secret = @client.call(:get_secret, message: { token: token || generate_token, secretId: scrt_id }).hash[:envelope][:body][:get_secret_response][:get_secret_result]
      raise "There was an error getting secret #{scrt_id}: #{secret[:errors][:string]}" if secret[:errors]
      return secret
    rescue Savon::Error => err
      raise "There was an error getting the secret with id #{scrt_id}: #{err}"
    end

    ##
    # Get the secret item id that relates to a key file or attachment.
    # Will raise on error
    # @param [Integer] the secret id
    # @param [String] the type of secret item to get, one of privatekey, publickey, attachment
    # @return [Integer] the secret item id
    def get_scrt_item_id(scrt_id, type, token)
      secret = get_secret(scrt_id, token)
      secret_items = secret[:secret][:items][:secret_item]
      begin
        return get_secret_item_by_field_name(secret_items, type)[:id]
      rescue => e

        raise "Unknown type, #{type}. #{e}"
      end
    end

    ##
    # Get an "Attachment"-type file from a secret
    # @param [Integer] the id of the secret
    # @param [Integer] the id of the attachment on the secret
    # @param [String] the type of the item being downloaded
    # @return [Hash] contents and metadata of the downloaded file
    def download_file_attachment_by_item_id(scrt_id, secret_item_id, item_type, token = nil)
      token = generate_token unless token
      @client.call(:download_file_attachment_by_item_id, message:
                  { token: token, secretId: scrt_id, secretItemId: secret_item_id || get_scrt_item_id(scrt_id, item_type, token) })
             .hash[:envelope][:body][:download_file_attachment_by_item_id_response][:download_file_attachment_by_item_id_result]
    end

    ##
    # Extract an item from a secret based on field name
    def get_secret_item_by_field_name(secret_items, field_name)
      secret_items.each do |item|
        return item if item[:field_name] == field_name
      end
      # key not found
      availableFields = secret_items.map{|item| item[:field_name]}
      raise KeyError, "Field '#{field_name}' not found; available fields are #{availableFields}."
    end
  end
end
