# frozen_string_literal: true

require 'codeowner_validator/group/comment'

module CodeownerValidator
  module Group
    module Comment
      # Public: An error comment response
      class Error
        include Comment

        class << self
          # @see CodeownerValidator::Group::Comment.match?
          def match?(type)
            type == Comment::TYPE_ERROR
          end
        end
      end
    end
  end
end
