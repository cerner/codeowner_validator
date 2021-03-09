# frozen_string_literal: true

RSpec.describe CodeownerValidator::CodeOwners do
  let(:repo_path) { double }
  let(:git) { double }

  subject { described_class.new repo_path: repo_path }

  before do
    allow(subject).to receive(:git).and_return(git)
  end

  it '.persist!' do
    expect(described_class).to receive(:new).with(repo_path: repo_path)
    expect { described_class.persist! repo_path: repo_path }.not_to raise_error
  end

  it '#initialize' do
    expect { subject }.not_to raise_error
    expect(subject.instance_variable_get(:@repo_path)).to eq(repo_path)
  end

  describe '#changes_to_analyze' do
    let(:diff) { double }
    let(:name_status) { double }
    let(:array) { double }
    let(:whitelist) { proc { true } }

    before :each do
      expect(subject).to receive(:whitelist).and_return(whitelist)

      expect(diff).to receive(
        :name_status
      ).and_return(name_status)
      expect(name_status).to receive(:select).and_return(array)
    end

    context 'with no params' do
      it 'analyzes with HEAD and previous commit' do
        expect(git).to receive(:diff).with(
          'HEAD',
          'HEAD^'
        ).and_return(diff)

        expect { subject.changes_to_analyze }.not_to raise_error
      end
    end

    context 'with params' do
      it 'analyzes with provided commits' do
        expect(git).to receive(:diff).with(
          'HEAD',
          'HEAD~2'
        ).and_return(diff)

        expect { subject.changes_to_analyze(to: 'HEAD~2') }.not_to raise_error
      end
    end
  end

  describe '#missing_assignments' do
    let(:file) { 'file' }

    it 'validate' do
      expect(subject).to receive(:included_files).and_return([file])
      expect(subject).to receive(:defined_owner?).with(file).and_return(false)
      expect { subject.missing_assignments }.not_to raise_error
    end
  end

  describe '#unrecognized_assignments' do
    let(:repo_path) { 'spec/files/code_owners_spec/unrecognized_assignment' }
    subject { described_class.new repo_path: repo_path }

    it 'validates' do
      response = nil
      expect { response = subject.unrecognized_assignments }.not_to raise_error
      expect(response.size).to eq(1)
    end
  end

  describe '#invalid_reference_lines' do
    let(:repo_path) { 'spec/files/code_owners_spec/invalid_reference_lines' }
    subject { described_class.new repo_path: repo_path }

    it 'validates' do
      response = nil
      expect { response = subject.invalid_reference_lines }.not_to raise_error
      expect(response.size).to eq(2)
    end
  end

  describe '#duplicated_patterns' do
    let(:repo_path) { 'spec/files/code_owners_spec/duplicated_patterns' }
    subject { described_class.new repo_path: repo_path }

    it 'validates' do
      response = nil
      expect { response = subject.duplicated_patterns }.not_to raise_error
      expect(response.size).to eq(1)
      expect(response.keys).not_to include('file1.yml')
      expect(response.keys).to include('file2.yml')
    end
  end

  describe '#included_files' do
    let(:repo_path) { 'spec/files/code_owners_spec/included_files' }
    subject { described_class.new repo_path: repo_path }

    it 'validates' do
      response = nil
      expect { response = subject.included_files }.not_to raise_error
      expect(response.size).to eq(2)
      expect(response).to include('file1.yml')
      expect(response).to include('CODEOWNERS')
    end
  end

  describe '#patterns_by_owner' do
    let(:repo_path) { 'spec/files/code_owners_spec/patterns_by_owner' }
    subject { described_class.new repo_path: repo_path }

    it 'validates' do
      response = nil
      expect { response = subject.patterns_by_owner }.not_to raise_error
      expect(response.keys).to include('@org/team1', '@org/team2', '@org/team3')
    end
  end

  describe '#find_by_owner' do
    let(:repo_path) { 'spec/files/code_owners_spec/patterns_by_owner' }
    subject { described_class.new repo_path: repo_path }

    context 'with valid team' do
      it 'validates' do
        response = nil
        expect { response = subject.find_by_owner('@org/team1') }.not_to raise_error
        expect(response.size).to eq(2)
      end
    end

    context 'with invalid team' do
      it 'finds no lines' do
        response = nil
        expect { response = subject.find_by_owner('@org/team99') }.not_to raise_error
        expect(response.size).to eq(0)
      end
    end
  end

  describe '#defined_owner?' do
    let(:repo_path) { 'spec/files/code_owners_spec/patterns_by_owner' }
    subject { described_class.new repo_path: repo_path }

    context 'with valid owner' do
      it 'returns true' do
        expect(subject.defined_owner?('file1.yml')).to be_truthy
      end
    end

    context 'without valid owner' do
      it 'returns false' do
        expect(subject.defined_owner?('non-existent-file.yml')).to be_falsey
      end
    end
  end

  describe '#main_group' do
    it 'uses the checker for parsing lines' do
      expect(subject).to receive(:list)
      expect(::Codeowners::Checker::Group).to receive(:parse)
      expect { subject.main_group }.not_to raise_error
    end
  end

  describe '#codeowner_file' do
    let(:repo_path) { 'spec/files/code_owners_spec/patterns_by_owner' }
    subject { described_class.new repo_path: repo_path }

    context 'when file exist' do
      it 'returns file' do
        expect { subject.codeowner_file }.not_to raise_error
      end
    end

    context 'when file does not exist' do
      it 'raises exception' do
        allow(File).to receive(:exist?).and_return(false)
        expect { subject.codeowner_file }.to raise_error(RuntimeError)
      end
    end
  end
end
