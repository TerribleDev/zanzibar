include 'pathname'

# Definitions for various strings used throughout the gem
module Zanzibar
  APPLICATION_NAME = Pathname.new($PROGRAM_NAME).basename
  ZANZIFILE_NAME = 'Zanzifile'
  RESOLVED_NAME = 'Zanzifile.resolved'
  TEMPLATE_NAME = 'templates/Zanzifile.erb'
  DEFAULT_SERVER = 'secret.example.com'
  DEFAULT_WSDL = 'https://%s/webservices/sswebservice.asmx?wsdl'

  ALREADY_EXISTS_ERROR = "#{ZANZIFILE_NAME} already exists! Aborting..."
  NO_WSDL_ERROR = 'Could not construct WSDL URL. Please provide either --server or --wsdl'
  NO_ZANZIFILE_ERROR = "You don't have a #{ZANZIFILE_NAME}! Run `#{APPLICATION_NAME} init` first!"
  INVALID_ZANZIFILE_ERROR = "Unable to load your #{ZANZIFILE_NAME}. Please ensure it is valid YAML."
end
