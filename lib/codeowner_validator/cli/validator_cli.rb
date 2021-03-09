# frozen_string_literal: true

require 'codeowner_validator/validator'

module CodeownerValidator
  # Public: Class utilized for housing all validator executions
  class ValidatorCLI < Thor
    REPO_PATH_DESC = 'Absolute path to repository location for evaluation'
    VERBOSE_DESC   = 'Verbose output'

    default_task :validate
    desc '', 'validates the codeowners file'

    method_option :repo_path, aliases: %w[-p --repo-path], desc: REPO_PATH_DESC
    method_option :verbose, aliases: %w[-v --verbose], desc: VERBOSE_DESC, type: :boolean, default: false
    # Public: Entry point execution to being the codeowner validation
    def validate
      get_user_input(options)

      validator = Validator.new options
      validator.validate
    end

    no_commands do
      # combination of options from input and environment variables
      def options
        return @new_options if @new_options

        original_options = super

        # add any environment variables as overrides
        @new_options =
          {}.tap do |h|
            original_options.each do |key, value|
              h[key.to_sym] = value
            end

            h[:verbose] = ENV['VERBOSE'] unless ENV['VERBOSE'].nil?
            h[:repo_path] = ENV['REPO_PATH'] unless ENV['REPO_PATH'].nil?
          end

        # setup initial configuration
        CodeownerValidator.configure! @new_options

        @new_options
      end

      # steps needed to ask for input that is deemed missing
      def get_user_input(options = {})
        return if options[:repo_path]

        ConfigHelper.ask(
          ident: :repo_path,
          prompt: REPO_PATH_DESC,
          required: true,
          default: Dir.pwd
        )

        # set response on the options hash
        options[:repo_path] = CodeownerValidator.repo_path
      end
    end
  end
end
