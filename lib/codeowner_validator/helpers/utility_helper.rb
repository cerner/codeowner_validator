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
        Bundler.with_clean_env do
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
  end
end
# rubocop:enable Style/ImplicitRuntimeError
