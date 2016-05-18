require 'zanzibar/actions/base'
require 'zanzibar/error'
require 'ostruct'
require 'erb'
require 'zanzibar/defaults'

module Zanzibar
  module Actions
    # Create a new Zanzifile
    class Init < Base
      ##
      # Make sure we don't already have a Zanzifile, then template one
      def run
        check_for_zanzifile
        write_template
      end

      private

      def check_for_zanzifile
        return unless File.exist?(ZANZIFILE_NAME) && !options['force']
        raise Error, ALREADY_EXISTS_ERROR
      end

      def write_template
        template = TemplateRenderer.new(options)

        File.open(ZANZIFILE_NAME, 'w') do |f|
          f.write template.render(File.read(source_root.join(TEMPLATE_NAME)))
        end
      end

      ##
      # Allows us to easily feed our options hash
      # to an ERB
      class TemplateRenderer < OpenStruct
        ##
        # Render an ERB template to a string
        def render(template)
          ERB.new(template).result(binding)
        end
      end
    end
  end
end
