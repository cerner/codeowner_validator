# frozen_string_literal: true

RSpec.describe CodeownerValidator::Logging do
  class DummyClass
    include CodeownerValidator::Logging
    def verbose?; end
  end

  let(:logger) { double }

  subject { DummyClass.new }

  before :each do
    subject.instance_variable_set(:@logger, logger)
  end

  describe '#logger' do
    before do
      subject.instance_variable_set(:@logger, nil)
    end

    after do
      subject.instance_variable_set(:@logger, logger)
    end

    it 'creates a logger' do
      expect(subject).to receive(:rails_logger)
      expect(subject).to receive(:default_logger)
      expect { subject.logger }.not_to raise_error
    end
  end

  describe '#log_verbose' do
    context 'verbose false' do
      before do
        expect(subject).to receive(:verbose?).and_return(false)
      end

      it 'does not log message' do
        expect(logger).not_to receive(:info)
        subject.log_verbose('verbose message')
      end
    end

    context 'verbose true' do
      before do
        expect(subject).to receive(:verbose?).and_return(true)
      end

      it_behaves_like 'logs messages', :log_verbose, :info
    end
  end

  describe '#log_command' do
    it_behaves_like 'logs messages', :log_command, :info
  end

  describe '#log_info' do
    it_behaves_like 'logs messages', :log_info, :info
  end

  describe '#log_warn' do
    it_behaves_like 'logs messages', :log_warn, :warn
  end

  describe '#log_error' do
    it_behaves_like 'logs messages', :log_error, :error
  end

  describe '#log_stderr' do
    it_behaves_like 'logs messages', :log_stderr, :error
  end

  it '#program_name' do
    expect(subject.program_name).to eq('rspec')
  end
end
