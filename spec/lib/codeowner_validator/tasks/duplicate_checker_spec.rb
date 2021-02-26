# frozen_string_literal: true

RSpec.describe CodeownerValidator::Tasks::DuplicateChecker do
  let(:filename) { 'config/pattern/file.rb' }
  let(:pattern1) do
    c = ::Codeowners::Checker::Group::Pattern.new("#{filename} @owner/a-team")
    c.line_number = 123
    c
  end
  let(:pattern2) do
    c = ::Codeowners::Checker::Group::Pattern.new("#{filename} @owner/b-team")
    c.line_number = 456
    c
  end
  let(:mock_response) do
    {
      filename => [pattern1, pattern2]
    }
  end
  let(:repo_path) { double }
  let(:codeowners) { double }

  subject { described_class.new repo_path: repo_path }

  it '#summary' do
    expect(subject.summary).to eq('Executing Duplicated Pattern Checker')
  end

  describe '#comments' do
    before do
      allow(subject).to receive(:codeowners).and_return(codeowners)
    end
    it 'validates' do
      expect(codeowners).to receive(:duplicated_patterns).and_return(mock_response)
      expect(subject.comments.first.comment).to eq(
        "Pattern 'config/pattern/file.rb' is defined 2 times on lines 123, 456"
      )
    end
  end
end
