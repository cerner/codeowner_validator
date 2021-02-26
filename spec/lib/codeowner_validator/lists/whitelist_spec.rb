# frozen_string_literal: true

RSpec.describe CodeownerValidator::Lists::Whitelist do
  describe 'with no file' do
    subject { described_class.new }

    it '#initialize' do
      expect { subject }.not_to raise_error
    end

    it '#exists?' do
      expect(subject).not_to be_exist
    end

    it 'listed?' do
      expect(subject.send(:listed?, 'foo')).to be_falsey
    end

    it 'pathspec' do
      pathspec = subject.send(:pathspec)
      expect(pathspec.specs).to be_empty
    end

    it 'whitelisted?' do
      expect(subject.whitelisted?(double)).to be_truthy
    end

    it 'to_proc' do
      expect(%w[foo bar].count(&subject)).to eq(2)
    end
  end

  describe 'with supplied file' do
    let(:filename) { 'spec/files/whitelist' }
    subject { described_class.new filename: filename }

    it '#initialize' do
      expect { subject }.not_to raise_error
    end

    it '#exists?' do
      expect(subject).to be_exist
    end

    it 'listed?' do
      expect(subject.send(:listed?, 'whitelist/foo.rb')).to be_truthy
    end

    it 'pathspec' do
      pathspec = subject.send(:pathspec)
      expect(pathspec.specs).not_to be_empty
    end

    it 'whitelisted?' do
      expect(subject.whitelisted?('whitelist/foo.rb')).to be_truthy
      expect(subject.whitelisted?('whitelist/bar.rb')).to be_falsey
      expect(subject.whitelisted?('blacklist/foo.rb')).to be_falsey
    end

    it 'to_proc' do
      expect(%w[whitelist/foo blacklist/bar].count(&subject)).to eq(1)
    end
  end

  describe 'with ENV variables' do
    subject { described_class.new }

    before do
      allow(ENV).to receive(:[]).with('CODEOWNERS_WHITELIST').and_return('def/**/*.rb, ghi/**/*.yml')
    end

    it 'whitelisted?' do
      expect(subject.whitelisted?('abc/foo.rb')).to be_falsey
      expect(subject.whitelisted?('def/bar.rb')).to be_truthy
      expect(subject.whitelisted?('def/bar.yml')).to be_falsey
    end

    it 'to_proc' do
      expect(%w[def/foo.yml def/bar.rb ghi/baz.yml].count(&subject)).to eq(2)
      expect(%w[zzz/foo.yml zzz/bar.rb zzz/baz.yml].count(&subject)).to eq(0)
    end
  end

  describe 'with supplied repo location' do
    let(:repo_path) { 'spec/files/whitelist_spec' }
    subject { described_class.new repo_path: repo_path }

    it 'whitelisted?' do
      expect(subject.whitelisted?('whitelist/foo.rb')).to be_truthy
      expect(subject.whitelisted?('whitelist/bar.rb')).to be_truthy
      expect(subject.whitelisted?('blacklist/bar.yml')).to be_falsey
      expect(subject.whitelisted?('non-existent/bar.yml')).to be_falsey
    end

    it 'to_proc' do
      expect(%w[whitelist/foo.yml whitelist/bar.rb blacklist/baz.yml].count(&subject)).to eq(2)
      expect(%w[zzz/foo.yml zzz/bar.rb zzz/baz.yml].count(&subject)).to eq(0)
    end
  end
end
