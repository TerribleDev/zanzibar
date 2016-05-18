module Zanzibar
  module Actions
    # Basic plumbing for all actions
    class Base
      ##
      # The options passed in from the Thor action
      attr_accessor :options
      private :options=

      ##
      # The logger that Thor is using for this run
      attr_accessor :logger
      private :logger=

      ##
      # Initialize the basic components used by all actions
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
