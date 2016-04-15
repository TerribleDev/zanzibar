require 'pathname'

# Definitions for various strings used throughout the gem
module Zanzibar
  APPLICATION_NAME = Pathname.new($PROGRAM_NAME).basename
  ZANZIFILE_NAME = 'Zanzifile'.freeze
  RESOLVED_NAME = 'Zanzifile.resolved'.freeze
  TEMPLATE_NAME = 'templates/Zanzifile.erb'.freeze
  DEFAULT_SERVER = 'secret.example.com'.freeze
  DEFAULT_WSDL = 'https://%s/webservices/sswebservice.asmx?wsdl'.freeze

  ALREADY_EXISTS_ERROR = "#{ZANZIFILE_NAME} already exists! Aborting...".freeze
  NO_WSDL_ERROR = 'Could not construct WSDL URL. Please provide either --server or --wsdl'.freeze
  NO_ZANZIFILE_ERROR = "You don't have a #{ZANZIFILE_NAME}! Run `#{APPLICATION_NAME} init` first!".freeze
  INVALID_ZANZIFILE_ERROR = "Unable to load your #{ZANZIFILE_NAME}. Please ensure it is valid YAML.".freeze
end
