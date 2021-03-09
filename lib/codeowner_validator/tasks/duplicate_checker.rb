# frozen_string_literal: true

require 'codeowner_validator/common/tasks/base'
require 'codeowner_validator/group/comment'

module CodeownerValidator
  module Tasks
    # Public: The duplicate checker executes an evaluation on the code owners file looking for duplicate
    # pattern references
    class DuplicateChecker < Base
      include ::CodeownerValidator::Group

      # @see ::CodeownerValidator::Tasks::Base.summary
      def summary
        'Executing Duplicated Pattern Checker'
      end

      # @see ::CodeownerValidator::Tasks::Base.comments
      def comments
        comments = []

        codeowners.duplicated_patterns.each do |key, value|
          msg = "Pattern '#{key}' is defined #{value.size} times on lines " \
                "#{value.map(&:line_number).join(', ')}"
          comments << Comment.build(comment: msg, type: Comment::TYPE_ERROR)
        end

        comments
      end
    end
  end
end
