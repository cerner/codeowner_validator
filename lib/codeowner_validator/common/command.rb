# frozen_string_literal: true

require 'codeowner_validator/common/logging'
require 'open3'

module CodeownerValidator
  # Public: Module utilized for housing the interactions with the terminal
  module Command
    include ::CodeownerValidator::Logging

    # Executes system commands
    def run(*args, log: true)
      output = []
      status = nil
      log_command(*args) if log

      Open3.popen2e(*args) do |_stdin, stdout_and_stderr, wait_thr|
        until (line = stdout_and_stderr.gets).nil?
          output.push line
          log_info line.chop
        end

        status = wait_thr.value
      end

      return if status.success?

      message =
        [].tap do |ar|
          ar << "Status: #{status.exitstatus}"
          # because some commands contain sensitive information (ie passwords),
          # may not want to display the actual command
          ar << "Command: #{args.join(' ')}" if log
        end

      log_error message.join(', ')
      raise message.join(', ')
    end
  end
end
