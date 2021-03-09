# frozen_string_literal: true

RSpec.describe CodeownerValidator::Tasks::SyntaxChecker do
  let(:repo_path) { double }
  let(:codeowners) { double }
  let(:filename) { 'config/foo/bar.rb' }
  let(:missing_line) do
    c = ::Codeowners::Checker::Group::UnrecognizedLine.new(filename)
    c.line_number = 123
    c
  end

  subject { described_class.new repo_path: repo_path }

  it '#summary' do
    expect(subject.summary).to eq('Executing Valid Syntax Checker')
  end

  describe '#comments' do
    before do
      allow(subject).to receive(:codeowners).and_return(codeowners)
    end
    it 'validates' do
      expect(codeowners).to receive(:unrecognized_assignments).and_return([missing_line])
      expect(subject.comments.first.comment).to eq('line 123: Missing owner, at least one owner is required')
    end
  end
end
