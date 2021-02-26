# frozen_string_literal: true

RSpec.describe CodeownerValidator::Command do
  class DummyCommandClass
    include ::CodeownerValidator::Command
  end

  let(:stdin) { double('stdin') }
  let(:stdout_and_stderr) { double('stdout_and_stderr') }
  let(:wait_thr) { double('wait_thr') }
  let(:status) { double }

  subject { DummyCommandClass.new }

  describe '#run' do
    before :each do
      expect(stdout_and_stderr).to receive(:gets).and_return nil
      expect(subject).to receive(:log_command)
    end

    context 'with successful execution' do
      it 'runs a command' do
        expect(subject).not_to receive(:log_error)
        expect(Open3).to receive(:popen2e).and_yield(stdin, stdout_and_stderr, wait_thr) do
          expect(wait_thr).to receive(:value).and_return(status)
          expect(status).to receive(:success?).and_return(true)
        end
        expect { subject.run('cmd') }.not_to raise_error
      end
    end

    context 'with an unsuccessful execution' do
      it 'runs a command' do
        expect(subject).to receive(:log_error)
        expect(Open3).to receive(:popen2e).and_yield(stdin, stdout_and_stderr, wait_thr) do
          expect(wait_thr).to receive(:value).and_return(status)
          expect(status).to receive(:success?).and_return(false)
          expect(status).to receive(:exitstatus).and_return(99)
        end
        expect { subject.run('cmd') }.to raise_error(RuntimeError, 'Status: 99, Command: cmd')
      end
    end
  end
end
