# frozen_string_literal: true

module CodeownerValidator
  module Lists
    # Manage whitelist file reading
    class Whitelist
      attr_reader :repo_path

      # Public: Initialized with a provided file
      #
      # @param [String] filename The filename to initialize the list with
      # @param [String] repo_path The repository base path utilized for evaluation of a .gitignore
      def initialize(filename: nil, repo_path: nil)
        @filename = filename
        @repo_path = repo_path

        # to avoid instance variable not initialized warnings
        @whitelist_file = nil
        @whitelist_file_paths = nil
        @git_ignore_file = nil
      end

      # Public: Checks for existence configuration for the whitelist
      #
      # @return <true> if found; otherwise, <false>
      def exist?
        !pathspec.empty?
      end

      # Public: Returns <true> if the file supplied has been whitelisted; otherwise, <false>
      #
      # @param [String] filename The file to evaluate if has been whitelisted
      # @return <true> if the file supplied has been whitelisted; otherwise, <false>
      def whitelisted?(filename)
        # if no items in the whitelist, assume all items are whitelisted
        return true if pathspec.empty?

        listed?(filename)
      end

      # add a `to_proc` method that allows instances of this class to be passed as a block
      # for easier chaining executions
      def to_proc
        proc { |item| whitelisted?(item) }
      end

      private

      # search for the .gitignore file if provided a repo path
      def git_ignore_file
        # if no repo, there can be no discovery of a file
        return unless repo_path

        return @git_ignore_file if @git_ignore_file

        file = File.join(repo_path, '.gitignore')
        @git_ignore_file = file if File.exist?(file)
      end

      # search for an actual file within the repository named 'CODEOWNERS_WHITELIST'
      def whitelist_file
        # if no repo, there can be no discovery of a file
        return unless repo_path

        return @whitelist_file if @whitelist_file

        whitelist_file_paths.each do |path|
          current_file_path = File.join(repo_path, path)
          return current_file_path if File.exist?(current_file_path)
        end

        nil
      end

      # locations to search for the repository driven codeowners whitelist file
      def whitelist_file_paths
        return @whitelist_file_paths if @whitelist_file_paths

        @whitelist_file_paths = %w[CODEOWNERS_WHITELIST .github/CODEOWNERS_WHITELIST]

        # allow customization of the locations to search for the file
        ENV['CODEOWNER_WHITELIST_FILE_PATHS']&.split(',')&.each(&:strip!)&.each do |str|
          @whitelist_file_paths << str
        end

        @whitelist_file_paths
      end

      # checks for the match of the filename
      def listed?(filename)
        pathspec.match(filename)
      end

      # the pathspec is a combination of files and variables:
      # * CODEOWNERS_WHITELIST - if provided a repo_path, file that exists in either the root repo path
      #   or alongside the CODEOWNERS file
      # * CODEOWNERS_WHITELIST - env variable of comma separated
      # * .gitignore - if provided a repo_path, this file is automatically added
      def pathspec
        # to avoid instance variable @pathspec not initialized must check if defined prior
        return @pathspec if defined?(@pathspec) && @pathspec

        @pathspec = PathSpec.new([])

        # first, add repo driven codeowners whitelist file
        @pathspec.add ::File.readlines(whitelist_file).map(&:chomp) if whitelist_file

        # second, add provided file
        @pathspec.add ::File.readlines(@filename).map(&:chomp) if @filename && File.exist?(@filename)

        # third, add items from the CODEOWNERS_WHITELIST
        if ENV['CODEOWNERS_WHITELIST']
          new_items =
            [].tap do |ar|
              ENV['CODEOWNERS_WHITELIST']&.split(',')&.each(&:strip!)&.each do |str|
                ar << str
              end
            end

          @pathspec.add new_items
        end

        # last, add items from the .gitignore.  this must always be last because
        # of the check for empty specs at this point in which will require inclusion of
        # all files prior to adding items to exclude.

        # if a gitignore exists, add each reference
        if git_ignore_file
          # first, check if existing pathspec evaluation is empty, if yes, need to add all files '**'
          # because the pathspec evaluation will only make evaluations based on the inclusive=false so need
          # to first include all files to provide an entry to inclusive=true
          @pathspec.add ['**'] if @pathspec.empty?

          @pathspec.add ::File.readlines(git_ignore_file).map do |line|
            "!#{line.chomp}"
          end
        end

        @pathspec
      end
    end
  end
end
