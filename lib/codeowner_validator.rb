# frozen_string_literal: true

require 'thor'
# pull in monkeypatch for codeowners-checker
require_relative 'codeowners/checker/group/line'
Dir.glob(File.join(File.dirname(__FILE__), 'codeowner_validator', '**/*.rb'), &method(:require))

# Public: The code owner validator space is utilized for validations against
# the code owner file for a given repository.
module CodeownerValidator
  class << self
    # Public: Provides the ability to configure instance variables within the module.  If the
    # method already exists, the value provide will be overwritten.
    #
    # @params [Hash] attrs The key/value paired items to be configured on the module.
    def configure!(attrs = {})
      attrs.each do |name, value|
        name = name.to_s.to_sym
        # protect against multiple executions
        singleton_class.instance_eval { attr_accessor name } unless self.class.method_defined?(name)
        send("#{name}=", value)
      end
    end
  end

  # Mail CLI
  class CLI < Thor
    desc 'validate', 'validates the codeowners file'
    subcommand 'validate', ValidatorCLI
  end
end
