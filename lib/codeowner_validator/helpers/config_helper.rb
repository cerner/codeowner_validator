# frozen_string_literal: true

require 'tty-prompt'
require 'tty-spinner'

module CodeownerValidator
  # Public: A configuration helper designed to assist in simple abstraction of TTY:Prompt requests
  # and assign those responses to the base module's configuration
  class ConfigHelper
    class << self
      # Public: An abstraction onto the TTY:Prompt.ask to allow requesting information from the user's input
      # and saving that input within the base module's configuration
      #
      # @param [Hash] args The arguments in which to accept
      # @option args [String] :ident The identifier to the config to store
      # @option args [String] :prompt The prompt to display to the user
      # @option args [String] :default The default value to display
      # @option args [Boolean] :required Indicates if the requested ask required input from the user
      # @option args [Boolean] :force_ask Indicates to ignore previous ask and perform again
      # @option args [Boolean] :mask Indicates that the response should be hidden
      def ask(ident:, prompt:, required: false, force_ask: false, mask: false, **args)
        opts =
          {}.tap do |h|
            h[:required] = required
            h[:default] = args[:default] if args[:default]
          end

        # return if either not being forced to ask or the information has been previously captured
        return if !force_ask && ::CodeownerValidator.respond_to?(ident)

        tty_prompt = ::TTY::Prompt.new
        response =
          tty_prompt.collect do
            if mask
              key(ident.to_sym).mask(
                prompt,
                opts
              )
            else
              key(ident.to_sym).ask(
                prompt,
                opts
              )
            end
          end

        ::CodeownerValidator.configure! response
      end

      # Public: An abstraction onto the TTY:Prompt.select to allow requesting information from the user's input
      # and saving that input within the base module's configuration
      #
      # @param [Hash] args The arguments in which to accept
      # @option args [String] :ident The identifier to the config to store
      # @option args [String] :prompt The prompt to display to the user
      # @option args [Boolean] :force_ask Indicates to ignore previous ask and perform again
      # @option args [Boolean] :choices The array of choices available for selection by the user
      def select(ident:, prompt:, force_ask: false, choices:, **args)
        # return if either not being forced to ask or the information has been previously captured
        return if !force_ask && ::CodeownerValidator.respond_to?(ident)

        tty_prompt = ::TTY::Prompt.new
        response = tty_prompt.select(
          prompt,
          choices,
          args
        )

        ::CodeownerValidator.configure! ident => response
      end
    end
  end
end
