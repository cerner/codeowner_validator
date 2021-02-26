# frozen_string_literal: true

RSpec.describe CodeownerValidator::Tasks::Base do
  let(:repo_path) { double }

  subject { described_class.new(repo_path: repo_path) }

  describe '#initialize' do
    before do
      remove_config :verbose
    end

    it 'initializes with false' do
      expect(subject.send(:verbose?)).to be_falsey
    end

    it 'initializes with true' do
      task = described_class.new(verbose: true, repo_path: repo_path)
      expect(task.send(:verbose?)).to be_truthy
    end
  end

  it '#summary' do
    expect(subject.summary).to eql('CodeownerValidator::Tasks::Base')
  end

  it '#codeowners' do
    expect(::CodeownerValidator::CodeOwners).to receive(:new).with(repo_path: repo_path)
    expect { subject.codeowners }.not_to raise_error
  end

  it '#in_repo_folder' do
    expect(subject).to receive(:in_folder)
    expect { subject.send(:in_repo_folder) }.not_to raise_error
  end

  describe '#verbose?' do
    context 'module level config exists' do
      before do
        CodeownerValidator.configure! verbose: true
      end
      after do
        remove_config :verbose
      end

      it 'returns verbose' do
        expect(subject.send(:verbose?)).to be_truthy
      end
    end

    context 'module level config does not exists' do
      before do
        allow(ENV).to receive(:[]).with('VERBOSE').and_return('true')
      end
      it 'returns ENV verbose' do
        allow(::CodeownerValidator).to receive(:respond_to?).with(:verbose).and_return(false)
        expect(subject.send(:verbose?)).to be_truthy
      end
    end
  end

  it '#execute' do
    expect(subject).to receive(:comments)
    expect { subject.execute }.not_to raise_error
  end
end
