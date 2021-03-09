# frozen_string_literal: true

require 'codeowner_validator/common/tasks/base'
Dir.glob(File.join(File.dirname(__FILE__), 'tasks', '**/*.rb'), &method(:require))
require 'codeowner_validator/group/comment'

module CodeownerValidator
  # Public: The validator is utilized for execution of the tasks associated to the code owner validation tasks.
  # It has the option to either execute a validation and automatically output the stdout or return an [Array]
  # of comments for the consumer to do as they please.  The CLI execution will route all comments to stdout.
  class Validator < ::CodeownerValidator::Tasks::Base
    include ::CodeownerValidator::Group

    # Public: Creates an instance of the executor with provided tasks
    #
    # @param [Hash] options The user provided options from the command line
    # @options options [Array] :tasks Array of tasks that should be specifically executed by the merger
    def initialize(tasks: [], **options)
      super
      @options = options

      # allow defining what tasks the merger should execute
      @tasks = tasks.map { |task_class| task_class.new(**@options) } unless tasks.empty?
    end

    # Public: Returns an array of summaries associated to all tasks that are to be executed
    #
    # @return [Array] An array of strings describing the tasks that are to be executed
    def summary
      tasks.map { |t| " * #{t.summary}" }
    end

    # Public: Performs the execution of all tasks
    def validate
      log_verbose(%w[Started:] + summary)

      in_repo_folder do
        tasks&.each(&:execute)
      end

      log_info 'VALIDATION complete! 🌟'
    end

    # Public: Performs the execution of all tasks and returns the comments to be interpreted
    def comments
      comments = []

      in_repo_folder do
        tasks&.each do |task|
          parent = Comment.build(
            comment: task.summary,
            type: Comment::TYPE_VERBOSE
          )
          task.comments.each do |comment|
            comment.parent = parent
            comments << comment
          end
        end
      end

      comments.group_by(&:parent)
    end

    private

    def tasks
      @tasks ||=
        [
          Tasks::DuplicateChecker,
          Tasks::SyntaxChecker,
          Tasks::FileExistsChecker,
          Tasks::MissingAssignmentChecker
        ].compact.map { |task_class| task_class.new(@options) } # rubocop:disable Performance/ChainArrayAllocation
    end
  end
end
