# frozen_string_literal: true

class SharedLoggingDummyClass
  include CodeownerValidator::Logging
  def verbose?; end
end

RSpec.shared_examples 'logs messages' do |log_command, log_type|
  let(:logger) { double }

  subject { SharedLoggingDummyClass.new }

  before :each do
    subject.instance_variable_set(:@logger, logger)
  end

  it "logs #{log_type} message" do
    expect(logger).to receive(log_type)
    subject.send(log_command, 'message')
  end
end
