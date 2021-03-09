# frozen_string_literal: true

module CodeownerValidator
  module Group
    # Public: Object for storing base comment information that can be rendered appropriately by the consumer
    module Comment
      TYPE_VERBOSE = 1
      TYPE_INFO    = 2
      TYPE_WARN    = 3
      TYPE_ERROR   = 4

      # to keep track of hierarchical structure of comments and allow grouping
      attr_accessor :parent
      attr_reader :comment

      class << self
        # Public: Creates an instance of the comment for usage.
        #
        # @param [Hash] _args The hash of arguments accepted
        # @option _args [String] :comment The comment to create
        # @option _args [Integer] :type The comment type (info, warn, error, verbose)
        #
        # @return [Info|]
        def build(comment:, type: TYPE_INFO, **_args)
          subclasses.each do |klass|
            return klass.new(comment) if klass.match?(type)
          end
          raise "Type '#{type}' not supported" # rubocop:disable Style/ImplicitRuntimeError
        end

        # Public: Returns <true> if the type of object requested is supported by the object; otherwise, <false>
        #
        # @param [Integer] type The type of comment to match on a subclass
        def match?(type); end

        private

        # returns the available subclasses to the base object
        def subclasses
          [Info, Warn, Error, Verbose]
        end
      end

      # Public: Creates an instance of the comment
      #
      # @param [String] comment The string text of the comment
      def initialize(comment)
        @comment = comment
      end
    end
  end
end

# require all subclasses
Dir.glob(File.join(File.dirname(__FILE__), 'comment', '**/*.rb'), &method(:require))
