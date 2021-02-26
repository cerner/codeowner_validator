# frozen_string_literal: true

require 'rainbow'
require 'logger'

module CodeownerValidator
  # Public: Mixin for adding methods needed for logging directly to the stdout
  module Logging
    # Internal: Reader for the logger attribute.
    #
    # Returns a Logger instance.
    def logger
      return @logger if @logger

      # depending of the context, utilize existing rails logger if exists
      @logger = rails_logger || default_logger
    end

    # Public: Designation if to show verbose output
    def log_verbose(*messages)
      return unless verbose?

      messages.flatten.each do |message|
        logger.info Rainbow(message || yield).magenta.bright
      end
    end

    # Public: Displays the command message to the console
    def log_command(*messages)
      messages.flatten.each do |message|
        logger.info Rainbow(message).bright
      end
    end

    # Public: Displays an informational message to the console
    def log_info(*messages)
      messages.flatten.each do |message|
        logger.info Rainbow(message).blue.bright
      end
    end

    # Public: Displays a warning message to the console
    def log_warn(*messages)
      messages.flatten.each do |message|
        logger.warn Rainbow(message).yellow
      end
    end

    # Public: Displays an error message to the console
    def log_error(*messages)
      messages.flatten.each do |message|
        logger.error Rainbow(message).red.bold
      end
    end

    # Public: Displays the stderr output to the console
    def log_stderr(*args)
      args.each do |message|
        logger.error message
      end
    end

    # Public: Displays the current program running name
    def program_name
      @program_name ||= File.basename($PROGRAM_NAME)
    end

    private

    # Get the Rails logger if it's defined.
    #
    # @example Get Rails' logger.
    #   Loggable.rails_logger
    #
    # @return [ Logger ] The Rails logger.
    def rails_logger
      defined?(::Rails) && ::Rails.respond_to?(:logger) && ::Rails.logger
    end

    def default_logger
      logger = ::Logger.new(STDOUT)
      logger.level = ::Logger::INFO
      logger
    end
  end
end
