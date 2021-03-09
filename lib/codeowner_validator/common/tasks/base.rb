# frozen_string_literal: true

require 'codeowner_validator/common/logging'
require 'codeowner_validator/common/command'
require 'codeowner_validator/helpers/utility_helper'

module CodeownerValidator
  module Tasks
    # Public: The tasks base class is used for defining the basis for task executions from the
    # importer or merger executors.
    class Base
      include ::CodeownerValidator::Logging
      include ::CodeownerValidator::Command
      include ::CodeownerValidator::UtilityHelper

      # Public: Initializing the task with provided arguments
      # @param [Hash] _args The hash of arguments to utilize for the initialization
      # @options _args [Boolean] :verbose Indicate if verbose output should be included
      # @options _args [String] :repo_path The absolute path to the repo for evaluation
      def initialize(verbose: false, repo_path:, **_args)
        @verbose = verbose
        @repo_path = repo_path
      end

      # Public: Returns the summary of what the task is to accomplish.  Expectation that each
      # task will define its intent which overrides just the class name output.
      def summary
        self.class.name
      end

      # Public: Executes task's commands
      def execute
        comments&.each { |c| log_error c.comment }
      end

      # Public: Executes all tasks and responds with an array of comments
      #
      # @return [Array] Returns an array of comments from the execution of the tasks to be utilized by the consumer
      def comments; end

      # Public: Returns the codeowner object associated to the repository selected
      #
      # @return [CodeownerValidator::CodeOwners] object associate to the repository selected
      def codeowners
        @codeowners ||= CodeOwners.new(repo_path: @repo_path)
      end

      private

      def in_repo_folder(&block)
        in_folder(@repo_path, &block)
      end

      def verbose?
        return CodeownerValidator.verbose if CodeownerValidator.respond_to?(:verbose)

        env_verbose = %w[true yes].include? ENV['VERBOSE']&.downcase
        @verbose || env_verbose
      end
    end
  end
end
