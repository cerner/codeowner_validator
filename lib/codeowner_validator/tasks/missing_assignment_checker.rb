# frozen_string_literal: true

require 'codeowner_validator/common/tasks/base'

module CodeownerValidator
  module Tasks
    # Public: The missing assignment checker executes an evaluation on the code owners file looking for files
    # within the repository that are not noted as been assigned by the codeowners file
    class MissingAssignmentChecker < Base
      include ::CodeownerValidator::Group

      # @see ::CodeownerValidator::Tasks::Base.summary
      def summary
        'Executing Missing Assignment Checker'
      end

      # @see ::CodeownerValidator::Tasks::Base.comments
      def comments
        comments = []

        codeowners.missing_assignments.each do |file|
          comments << Comment.build(
            comment: "File '#{file}' is missing from the code owners file",
            type: Comment::TYPE_ERROR
          )
        end

        comments
      end
    end
  end
end
