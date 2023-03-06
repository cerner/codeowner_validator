# frozen_string_literal: true

require 'pathname'
require_relative 'helpers/utility_helper'
require 'codeowner_validator/lists/whitelist'
require 'codeowners/checker/group'
require_relative '../codeowners/checker/group/line'

# rubocop:disable Style/ImplicitRuntimeError
module CodeownerValidator
  # Public: Manages the interactions with the GitHub CODEOWNERS file.  Information such as
  # assignments, missing assignments, etc are retrieved though the usage of this class.
  class CodeOwners
    include UtilityHelper

    # Public: The absolute path the the repository for evaluation
    attr_reader :repo_path

    class << self
      # Public: Returns a instance of the [CodeOwners] object
      #
      # @param [Hash] args A hash of arguments allowed for creation of a [CodeOwners] object
      # @option args [String] :repo_path The absolute path to the repository to be evaluated
      def persist!(repo_path:, **args)
        new(repo_path: repo_path, **args)
      end
    end

    # Public: Returns a instance of the [CodeOwners] object
    #
    # @param [Hash] _args A hash of arguments allowed for creation of a [CodeOwners] object
    # @option args [String] :repo_path The absolute path to the repository to be evaluated
    def initialize(repo_path:, **_args)
      @repo_path = repo_path

      # initialize params to suppress warnings about instance variables not initialized
      @list = nil
      @codeowner_file = nil
      @codeowner_file_paths = nil
      @included_files = nil
    end

    # Public: Returns a [Hash] of key/value pairs of relative file name to git status ('A', 'M', 'D')
    # between two commits.
    #
    # @param [String] from The staring point for analyzing. Defaults to 'HEAD'
    # @param [String] to The end point for analyzing. Defaults to 'HEAD^'
    # @return [Hash] of key/value pairs of relative file name to git status ('A', 'M', 'D')
    #
    # @example
    #   {
    #     "config/tenants/cert-int/eds04.yml" => "M",
    #     "config/tenants/dev-int/edd03.yml" => "M"
    #   }
    def changes_to_analyze(from: 'HEAD', to: 'HEAD^')
      git.diff(from, to).name_status.select(&whitelist)
    end

    # Public: Returns an [Array] of patterns that have no files associated to them
    #
    # @return [Array] [Array] of patterns that have no files associated to them
    def useless_pattern
      @useless_pattern ||=
        list.select do |line|
          line.pattern? && !pattern_has_files(line.pattern)
        end
    end

    # Public: Returns a [Hash] of key/value pairs of relative file name to git details for a supplied pattern
    #
    # @param [String] pattern The pattern to search for files within the repository
    # @return [Hash] of key/value pairs of relative file name to git details for a supplied pattern
    #
    # @example
    #   pattern_has_files('config/tenants/dev')
    #   {
    #     {
    #       "config/tenants/dev/64dev.yml" => {
    #         path: "config/tenants/dev/64dev.yml",
    #         mode_index: "100644",
    #         sha_index: "598b2193b22bc006ff000e3a51f6805b336ebed8",
    #         stage: "0"
    #       },
    #       "config/tenants/dev/deveng.yml" => {
    #         path: "config/tenants/dev/deveng.yml",
    #         mode_index: "100644",
    #         sha_index: "ee63d8c6e9ae7f432aafa7bd3436fae222cb3f5c",
    #         stage: "0"
    #       }
    #     }
    #   }
    def pattern_has_files(pattern)
      git.ls_files(pattern.gsub(/^\//, '')).reject(&whitelist).any?
    end

    # Public: Return a list of files from the repository that do not have an owner assigned
    #
    # @return [Array] of files from the repository that are missing an assignment
    def missing_assignments
      @missing_assignments ||= included_files.reject(&method(:defined_owner?))
    end

    # Public: Return a list of files from the codowners file that are missing the owner assignment
    #
    # @return [Array] of unrecognized lines from the codeowners file missing owner assignment
    def unrecognized_assignments
      list.select do |line|
        line.is_a?(Codeowners::Checker::Group::UnrecognizedLine)
      end
    end

    # Public: Return a list of files from the codeowners file that are noted but do not exist
    #
    # @return [Array] of <Codeowners::Checker::Group::UnrecognizedLine>s or <Codeowners::Checker::Group::Pattern>s
    def invalid_reference_lines
      list.select do |line|
        next unless line.pattern? || line.is_a?(Codeowners::Checker::Group::UnrecognizedLine)

        filename = line.pattern? ? line.pattern : line.to_file
        File.exist?(File.join(repo_path, filename)) == false
      end
    end

    # Public: Returns a [Hash] of keyed item to array of patterns that are duplicated within the code owners file
    #
    # @return [Hash] of keyed [String] patterns to an [Array] of [Pattern]s
    #
    # Example:
    # {
    #   "config/domains/cert-int/CaseCartCoordinator_CERTIFICATION.yml": [
    #     {Codeowners::Checker::Group::Pattern},
    #     {Codeowners::Checker::Group::Pattern}
    #   ]
    # }
    def duplicated_patterns
      list.select { |l| l.pattern? }.group_by { |e| e.pattern }.select { |_k, v| v.size > 1 }
    end

    # Public: Return all relative paths to files for evaluation if to be owned by a set of code owners
    #
    # @return [Array] of relative paths to files that are to be included within the code owner evaluation
    def included_files
      return @included_files if @included_files

      @included_files = []
      in_folder repo_path do
        Dir.glob(File.join(Dir.pwd, '**/*')) do |f|
          p = Pathname.new(f)
          # only return files for evaluation
          next unless p.file?

          # in order to properly match, must evaluate relative to the repo location that is
          # being evaluated.  absolute paths of the files do not match with relative matches
          relative_path_to_file = p.relative_path_from(Dir.pwd)
          @included_files << relative_path_to_file.to_s if whitelist.whitelisted?(relative_path_to_file)
        end
      end

      @included_files
    end

    # Public: Returns the patterns utilized with an array association to those patterns
    #
    # @return [Hash] The patterns keyed by the team with an array of associations
    #
    # Example Response:
    # {
    #   "@orion-delivery/delivery-team": [
    #     "*"
    #   ],
    #   "@orion-delivery/orion-delivery-ets": [
    #     "config/domains/production/**/*",
    #     "config/domains/sandbox/**/*"
    #   ],
    #   "@orion-delivery/orion-shells": [
    #     "config/feature_definitions/authn-android-enable_biometric_unlock.yml",
    #     "config/domains/cert-int/IONServer_CERTIFICATION.yml"
    #   ]
    # }
    def patterns_by_owner
      @patterns_by_owner ||=
        main_group.each_with_object(hash_of_arrays) do |line, patterns_by_owner|
          next unless line.pattern?

          line.owners.each { |owner| patterns_by_owner[owner] << line.pattern.gsub(/^\//, '') }
        end
    end

    # Public: Returns the lines associated to a specific owner
    #
    # @param [String] owner The owner to search for patterns
    # @return [Array] of <Codeowners::Checker::Group::Pattern> objects
    def find_by_owner(owner)
      main_group.find.select do |line|
        next unless line.pattern?

        line.owner == owner
      end
    end

    # Public: Returns <true> if there is a defined owner for a given file
    #
    # @param [String] file The file to search if there is an owner assigned
    # @return <true> if found; otherwise, <false>
    def defined_owner?(file)
      main_group.find do |line|
        next unless line.pattern?

        return true if line.match_file?(file)
      end

      false
    end

    # Public: Returns an [Array] of [Codeowners::Checker::Group] objects indicating
    # the grouping of code owners
    #
    # @return [Array] of [Codeowners::Checker::Group] objects indicating the grouping
    # of code owners
    def main_group
      @main_group ||= ::Codeowners::Checker::Group.parse(list)
    end

    # Public: Returns a [String] for the code owner file if it exists; otherwise, raise exception
    #
    # @return [String] the path to the codeowners file; otherwise, raise exception if not exists
    def codeowner_file
      return @codeowner_file if @codeowner_file

      codeowner_file_paths.each do |path|
        current_file_path = File.join(repo_path, path)
        return current_file_path if File.exist?(current_file_path)
      end

      raise "Unable to locate a code owners file located [#{codeowner_file_paths.join(',')}]"
    end

    # Public: Returns <true> if the provided file is deemed whitelisted per the configuration;
    # otherwise, <false>
    #
    # @return [true|false] if the provided file is deemed whitelisted per the configuration
    def whitelisted?(file)
      whitelist.whitelisted?(file)
    end

    private

    # returns the git object representation of the repo provided
    def git
      @git ||= Git.open(@repo_path, log: Logger.new(IO::NULL))
    end

    # returns the configured whitelist of patterns to include
    def whitelist
      @whitelist ||= ::CodeownerValidator::Lists::Whitelist.new(repo_path: repo_path)
    end

    # locations to search for the codeowners file
    def codeowner_file_paths
      return @codeowner_file_paths if @codeowner_file_paths

      @codeowner_file_paths = %w[CODEOWNERS docs/CODEOWNERS .github/CODEOWNERS]

      # allow customization of the locations to search for the file
      ENV['CODEOWNER_FILE_PATHS']&.split(',')&.each(&:strip!)&.each do |str|
        @codeowner_file_paths << str
      end

      @codeowner_file_paths
    end

    # constructs a new hash-to-array mapping
    def hash_of_arrays
      Hash.new { |h, k| h[k] = [] }
    end

    # returns an array of built lines
    def list
      return @list if @list

      @list =
        content.each_with_index.map do |line, index|
          l = build_line(line)
          l.line_number = index + 1
          l
        end

      @list.compact!

      @list
    end

    # builds a group line identifier
    def build_line(line)
      ::Codeowners::Checker::Group::Line.build(line)
    end

    # @return <Array> of lines chomped
    def content
      @content ||= ::File.readlines(codeowner_file).map(&:chomp)
    rescue Errno::ENOENT
      @content = []
    end
  end
end
# rubocop:enable Style/ImplicitRuntimeError
