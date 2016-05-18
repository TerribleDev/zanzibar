require 'pathname'

# Definitions for various strings used throughout the gem
module Zanzibar
  # The name of the binstub that invoked this code
  APPLICATION_NAME = Pathname.new($PROGRAM_NAME).basename
  # The filename of the Zanzifile
  ZANZIFILE_NAME = 'Zanzifile'.freeze
  # The filename of the resolved Zanzifile
  RESOLVED_NAME = 'Zanzifile.resolved'.freeze
  # The template to use when writing the Zanzifile
  TEMPLATE_NAME = 'templates/Zanzifile.erb'.freeze
  # The default value of the server when writing the Zanzifile
  DEFAULT_SERVER = 'secret.example.com'.freeze
  # The default WSDL location for the Zanzifile template
  DEFAULT_WSDL = 'https://%s/webservices/sswebservice.asmx?wsdl'.freeze

  # Error thrown when trying to overwrite an existing Zanzifile
  ALREADY_EXISTS_ERROR = "#{ZANZIFILE_NAME} already exists! Aborting...".freeze
  # Error thrown when unable to construct the WSDL location
  NO_WSDL_ERROR = 'Could not construct WSDL URL. Please provide either --server or --wsdl'.freeze
  # Error thrown when trying to download secrets from a Zanzifile that doesn't exist
  NO_ZANZIFILE_ERROR = "You don't have a #{ZANZIFILE_NAME}! Run `#{APPLICATION_NAME} init` first!".freeze
  # Error thrown when a Zanzifile is missing necessary information
  INVALID_ZANZIFILE_ERROR = "Unable to load your #{ZANZIFILE_NAME}. Please ensure it is valid YAML.".freeze
end
