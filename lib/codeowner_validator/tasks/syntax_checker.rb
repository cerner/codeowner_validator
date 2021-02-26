# frozen_string_literal: true

require 'codeowner_validator/common/tasks/base'

module CodeownerValidator
  module Tasks
    # Public: The syntax checker executes an evaluation on the code owners file looking for missing assignment
    # within the file itself
    class SyntaxChecker < Base
      include ::CodeownerValidator::Group

      # @see ::CodeownerValidator::Tasks::Base.summary
      def summary
        'Executing Valid Syntax Checker'
      end

      # @see ::CodeownerValidator::Tasks::Base.comments
      def comments
        comments = []

        codeowners.unrecognized_assignments.each do |line|
          comments << Comment.build(
            comment: "line #{line.line_number}: Missing owner, at least one owner is required",
            type: Comment::TYPE_ERROR
          )
        end

        comments
      end
    end
  end
end
