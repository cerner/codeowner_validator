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
            Comment::TYPE_ERROR == type
          end
        end
      end
    end
  end
end
