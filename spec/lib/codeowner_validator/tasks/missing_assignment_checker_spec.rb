# frozen_string_literal: true

RSpec.describe CodeownerValidator::Tasks::MissingAssignmentChecker do
  let(:repo_path) { double }
  let(:filename) { 'config/foo/bar.rb' }
  let(:codeowners) { double }

  subject { described_class.new repo_path: repo_path }

  it '#summary' do
    expect(subject.summary).to eq('Executing Missing Assignment Checker')
  end

  describe '#comments' do
    before do
      allow(subject).to receive(:codeowners).and_return(codeowners)
    end
    it 'validates' do
      expect(codeowners).to receive(:missing_assignments).and_return([filename])
      expect(subject.comments.first.comment).to eq("File 'config/foo/bar.rb' is missing from the code owners file")
    end
  end
end
