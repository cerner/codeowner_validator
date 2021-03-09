# frozen_string_literal: true

class DummyTask < ::CodeownerValidator::Tasks::Base
  def summary
    'dummy task summary'
  end
end

RSpec.describe CodeownerValidator::Validator do
  let(:repo_path) { double }
  subject { described_class.new repo_path: repo_path, tasks: [DummyTask] }

  it '#initialize' do
    expect(subject.summary.first).to eq(' * dummy task summary')
  end

  it '#summary' do
    expect(subject).to receive(:tasks).and_return([])
    expect { subject.summary }.not_to raise_error
  end

  it '#validate' do
    expect(subject).to receive(:log_verbose)
    expect(subject).to receive(:in_repo_folder).and_yield
    expect_any_instance_of(DummyTask).to receive(:execute)
    expect(subject).to receive(:log_info)

    expect { subject.validate }.not_to raise_error
  end

  it '#comments' do
    expect(subject).to receive(:in_repo_folder).and_yield
    expect_any_instance_of(DummyTask).to receive(:comments).and_return(
      [
        ::CodeownerValidator::Group::Comment.build(comment: 'comment line 1'),
        ::CodeownerValidator::Group::Comment.build(comment: 'comment line 2'),
        ::CodeownerValidator::Group::Comment.build(comment: 'comment line 3')
      ]
    )
    comments = nil
    expect { comments = subject.comments }.not_to raise_error
    expect(comments.keys.size).to eq(1)
    parent = comments.keys.first
    items = comments[parent]
    expect(parent.comment).to eq('dummy task summary')
    expect(items.size).to eq(3)
  end
end
