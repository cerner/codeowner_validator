# frozen_string_literal: true

require 'codeowner_validator/group/comment'

module CodeownerValidator
  module Group
    module Comment
      # Public: An info comment response
      class Verbose
        include Comment

        class << self
          # @see CodeownerValidator::Group::Comment.match?
          def match?(type)
            type == Comment::TYPE_VERBOSE
          end
        end
      end
    end
  end
end
