# CODEOWNER Validator

![CI](https://github.com/cerner/codeowner_validator/actions/workflows/ci.yml/badge.svg)

This library provides interactions with the GitHub CODEOWNERS file for performing validation tasks that include
* ownership checks
* valid syntax
* missing files
* duplicate patterns

## Usage
The library has been designed in a manner that allows invocation by a consumer in one of two options.  The first use case is through the command line
interface (CLI).  This allows the consumer to execute a command on the terminal and output a report resulting from the validation tasks.  The second use
case allows consumers direct consumption of the methods utilized for the validation tasks to allow for writing their own custom implementation on how
to generate a report.

### Command Line Use Case
#### Installation

Add this line to your application's Gemfile:

```ruby
gem 'codeowner_validator'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install codeowner_validator

#### Execution
```
codeowner_validator validate
```

Execution of the validator is against a supplied repository folder location.  The business logic for retrieving said repository is up to the consumer.
Upon execution of the validator, the repository location will be asked of the executor.  You may enter an absolute location or you could supply a parameter
of `-p` or `--repo-path` to avoid the question in the console.  

```
codeowner_validator validate -p /Users/foo/special-repository
```

### Consumer Use Case
#### Installation

Add this line to your application's Gemfile:

```ruby
gem 'codeowner_validator'
```

And then execute:

    $ bundle

#### Execution
```ruby
require 'codeowner_validator'

code_owners = CodeownerValidator::CodeOwners.new(
  repo_path: "/Users/poloka/application-config"
)

# return an array of patterns that have no files associated to them
code_owners.useless_pattern

# returns a list of files from the repository that do not have an owner assigned
code_owners.missing_assignments
```

### Whitelist
With some projects, not all files within the repository need assignments.  In this case, a consumer may define a list of relative path
locations within the repository to be scanned for evaluation.  There are a few options and any combination of these options may be used

#### 'CODEOWNERS_WHITELIST' file
If the initialization of the whitelist object is provided a repository path, the retrieval of the [pathspec][pathspec-ruby] will include
entries from the provided file.  This file may reside in either the root repository location or within the .github folder.
```
application-config/
├── CODEOWNERS_WHITELIST
└── .github/
    ├── CODEOWNERS
    └── CODEOWNERS_WHITELIST
```

#### '.gitignore' file
If the initialization of the whitelist object is provided a repository path, all entries from the .gitignore will be added as items to
exclude from ownership evaluations.

#### ENV['CODEOWNERS_WHITELIST']
This option of an environment variable 'CODEOWNERS_WHITELIST' with a comma separated string is allowed.

```
CODEOWNERS_WHITELIST=config/subfolder_01,config/subfolder_02 codeowner_validator validate -p /Users/foo/special-repository
```

# Building
This project is built using Ruby 2.6+, Rake and Bundler. RSpec is used for unit tests and SimpleCov
is utilized for test coverage. RuboCop is used to monitor the lint and style.

## Setup

To setup the development workspace, run the following after checkout:

    gem install bundler
    bundle install

## Tests

To run the RSpec tests, run the following:

    bin/rspec

## Lint

To analyze the project's style and lint, run the following:

    bin/rubocop

## Bundler Audit

To analyze the project's dependency vulnerabilities, run the following:

    bin/bundle audit

# Availability

This RubyGem will be available on https://rubygems.org/.

# Communication

All questions, bugs, enhancements and pull requests can be submitted here, on GitHub via Issues.

# Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md)

## License

Copyright 2020 Cerner Innovation, Inc.

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

&nbsp;&nbsp;&nbsp;&nbsp;http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

## Code of Conduct

Everyone interacting in the CodeownerValidator project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](CODE_OF_CONDUCT.md).

## References
Shout-out to @jonatas and his project [codeowners-checker](https://github.com/toptal/codeowners-checker).  The checker provided easy reusage which greatly reduced the
dependencies within this project.

[pathspec-ruby]: https://github.com/highb/pathspec-ruby