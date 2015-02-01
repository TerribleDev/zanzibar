module Zanzibar
  module Actions
    # Basic plumbing for all actions
    class Base
      attr_accessor :options
      private :options=

      attr_accessor :logger
      private :logger=

      def initialize(logger, options = {})
        self.logger  = logger
        self.options = options
      end

      private

      def debug(*args, &block)
        logger.debug(*args, &block)
      end

      def source_root
        @source_root ||= Pathname.new(File.expand_path('../../../../', __FILE__))
      end
    end
  end
end
