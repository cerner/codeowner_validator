# frozen_string_literal: true

require 'codeowner_validator/group/comment'

module CodeownerValidator
  module Group
    module Comment
      # Public: A warn comment response
      class Warn
        include Comment

        class << self
          # @see CodeownerValidator::Group::Comment.match?
          def match?(type)
            Comment::TYPE_WARN == type
          end
        end
      end
    end
  end
end
