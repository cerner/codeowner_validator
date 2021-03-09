# frozen_string_literal: true

# monkeypatch class to include line number
module Codeowners
  class Checker
    class Group
      class Line
        attr_accessor :line_number
      end
    end
  end
end
