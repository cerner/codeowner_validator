# frozen_string_literal: true

require 'codeowner_validator/common/tasks/base'
require 'codeowner_validator/group/comment'

module CodeownerValidator
  module Tasks
    # Public: The file existence checker executes an evaluation on the code owners file looking for references
    # to non-existent files within the repository
    class FileExistsChecker < Base
      include ::CodeownerValidator::Group

      # @see ::CodeownerValidator::Tasks::Base.summary
      def summary
        'Executing File Exists Checker'
      end

      # @see ::CodeownerValidator::Tasks::Base.comments
      def comments
        comments = []

        codeowners.invalid_reference_lines.each do |line|
          file_name = line.pattern? ? line.pattern : line
          msg = "line #{line.line_number}: '#{file_name}' does not match any files in the repository"
          comments << Comment.build(
            comment: msg,
            type: Comment::TYPE_ERROR
          )
        end

        comments
      end
    end
  end
end
