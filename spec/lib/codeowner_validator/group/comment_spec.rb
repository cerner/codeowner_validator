# frozen_string_literal: true

RSpec.describe CodeownerValidator::Group::Comment do
  describe '.build' do
    subject { described_class.build(comment: 'foo', type: type) }

    context 'info' do
      let(:type) { described_class::TYPE_INFO }
      it 'creates' do
        expect(subject).to be_an_instance_of(CodeownerValidator::Group::Comment::Info)
      end
    end
    context 'warn' do
      let(:type) { described_class::TYPE_WARN }
      it 'creates' do
        expect(subject).to be_an_instance_of(CodeownerValidator::Group::Comment::Warn)
      end
    end
    context 'error' do
      let(:type) { described_class::TYPE_ERROR }
      it 'creates' do
        expect(subject).to be_an_instance_of(CodeownerValidator::Group::Comment::Error)
      end
    end
    context 'verbose' do
      let(:type) { described_class::TYPE_VERBOSE }
      it 'creates' do
        expect(subject).to be_an_instance_of(CodeownerValidator::Group::Comment::Verbose)
      end
    end
    context 'unknown' do
      let(:type) { -1 }
      it 'raises error' do
        expect { subject }.to raise_error(RuntimeError, "Type '-1' not supported")
      end
    end
  end

  describe '#initialize' do
    class DummyCommentClass
      include CodeownerValidator::Group::Comment
    end

    let(:mock_comment) { 'mock-comment' }
    subject { DummyCommentClass.new(mock_comment) }

    it 'create a comment' do
      expect(subject.instance_variable_get(:@comment)).to eql(mock_comment)
    end
  end
end
