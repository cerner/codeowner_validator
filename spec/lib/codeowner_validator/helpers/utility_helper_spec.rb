# frozen_string_literal: true

RSpec.describe CodeownerValidator::UtilityHelper do
  class DummyClass
    include CodeownerValidator::UtilityHelper
  end

  let(:repo_path) { double }

  subject { DummyClass.new }

  describe '#in_folder' do
    context 'when folder does not exists' do
      it 'raises an error' do
        allow(File).to receive(:directory?).and_return(false)
        expect { subject.send(:in_folder) }.to raise_error(StandardError)
      end
    end

    context 'when folder exists' do
      it 'changes directory' do
        allow(File).to receive(:directory?).and_return(true)
        expect(Dir).to receive(:chdir).with(repo_path)
        subject.send(:in_folder, repo_path)
      end
    end
  end
end
