# frozen_string_literal: true

# rubocop:disable Style/ImplicitRuntimeError
module CodeownerValidator
  # Public: A utility helper to provide common methods for reuse across multiple
  # classes
  module UtilityHelper
    # Provides a way to change the current working directory to a different folder location.
    # This ability can ease the reference of file references when working with multiple
    # repository locations.
    #
    # @raise [RuntimeError] if the folder location does not exist.
    def in_folder(folder)
      raise "The folder location '#{folder}' does not exists" unless File.directory?(folder)

      if defined?(Bundler)
        method = Bundler.respond_to?(:with_unbundled_env) ? :with_unbundled_env : :with_clean_env
        Bundler.send(method) do
          Dir.chdir folder do
            yield
          end
        end
      else
        Dir.chdir folder do
          yield
        end
      end
    end

    def with_clean_env
      return yield unless defined?(Bundler)

      if Bundler.respond_to?(:with_unbundled_env)
        Bundler.with_unbundled_env { yield }
      else
        # Deprecated on Bundler 2.1
        Bundler.with_clean_env { yield }
      end
    end
  end
end
# rubocop:enable Style/ImplicitRuntimeError
