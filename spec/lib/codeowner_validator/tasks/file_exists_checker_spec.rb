# frozen_string_literal: true

RSpec.describe CodeownerValidator::Tasks::FileExistsChecker do
  let(:repo_path) { double }
  let(:filename) { 'foobar' }
  let(:pattern1) do
    c = ::Codeowners::Checker::Group::Pattern.new("#{filename} @owner/a-team")
    c.line_number = 123
    c
  end
  let(:codeowners) { double }

  subject { described_class.new repo_path: repo_path }

  it '#summary' do
    expect(subject.summary).to eq('Executing File Exists Checker')
  end

  describe '#comments' do
    before do
      allow(subject).to receive(:codeowners).and_return(codeowners)
    end
    it 'validates' do
      expect(codeowners).to receive(:invalid_reference_lines).and_return([pattern1])
      expect(subject.comments.first.comment).to eq("line 123: 'foobar' does not match any files in the repository")
    end
  end
end
