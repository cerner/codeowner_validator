# frozen_string_literal: true

module CodeownerValidator
  VERSION = '0.2.0'

  # version module
  module Version
    MAJOR, MINOR, PATCH, *BUILD = VERSION.split '.'
    NUMBERS = [MAJOR, MINOR, PATCH, *BUILD].freeze
  end
end
