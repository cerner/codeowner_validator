# frozen_string_literal: true

require 'bundler/setup'
require 'simplecov'
require 'codeowner_validator'
Dir.glob(File.join(File.dirname(__FILE__), 'support', '**/*.rb'), &method(:require))

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.example_status_persistence_file_path = 'build/examples.txt'

  config.disable_monkey_patching!

  config.warnings = true

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

SimpleCov.start do
  coverage_dir 'build/coverage'
  add_filter '/spec/'
end

def remove_config(idents)
  ar = idents.is_a?(Array) ? idents : [idents]

  ar.each do |ident|
    [ident, "#{ident}="].map(&:to_sym).each do |i|
      CodeownerValidator.singleton_class.remove_method(i) if CodeownerValidator.respond_to?(i)
    end
    attribute_variable = "@#{ident}".to_sym
    if CodeownerValidator.respond_to?(attribute_variable)
      CodeownerValidator.remove_instance_variable(attribute_variable)
    end
  end
end

def mock_whitelist(file: 'spec/files/whitelist')
  CodeownerValidator::Lists::Whitelist.new filename: file
end
