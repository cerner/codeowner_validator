# frozen_string_literal: true

RSpec.describe CodeownerValidator::ConfigHelper do
  let(:prompt) { instance_double('TTY::Prompt') }

  before do
    allow(TTY::Prompt).to receive(:new).and_return(prompt)
  end

  describe '.ask' do
    let(:identifier) { 'identifier' }
    context 'CodeownerValidator does not respond to ident' do
      before do
        allow(CodeownerValidator).to receive(:respond_to?).and_return(false)
      end

      context 'force_ask is false' do
        it 'configures the response' do
          expect(prompt).to receive(:collect).and_return(identifier => 'bar')
          described_class.ask(
            ident: identifier,
            prompt: 'prompt to user'
          )
          expect(CodeownerValidator.send(identifier)).to eq('bar')
        end
      end

      context 'force_ask is true' do
        it 'configures the response' do
          expect(prompt).to receive(:collect).and_return(identifier => 'baz')
          described_class.ask(
            ident: identifier,
            prompt: 'prompt to user',
            force_ask: true
          )
          expect(CodeownerValidator.send(identifier)).to eq('baz')
        end
      end
    end

    context 'CodeownerValidator does respond to ident' do
      before do
        allow(CodeownerValidator).to receive(:respond_to?).and_return(true)
      end

      context 'force_ask is false' do
        it 'does not ask for overwriting values' do
          expect(prompt).to_not receive(:collect)
          expect(CodeownerValidator).to_not receive(:configure!)
          described_class.ask(
            ident: identifier,
            prompt: 'prompt to user'
          )
        end
      end

      context 'force_ask is true' do
        it 'configures the response' do
          expect(prompt).to receive(:collect)
          expect(CodeownerValidator).to receive(:configure!)
          described_class.ask(
            ident: identifier,
            prompt: 'prompt to user',
            force_ask: true
          )
        end
      end
    end
  end

  describe '.select' do
    let(:identifier) { 'identifier' }

    context 'CodeownerValidator does not respond to ident' do
      before :each do
        allow(CodeownerValidator).to receive(:respond_to?).and_return(false)
      end

      context 'force_ask is false' do
        it 'configures the response' do
          expect(prompt).to receive(:select).and_return('bar')
          described_class.select(
            ident: identifier,
            prompt: 'prompt to user',
            choices: %w[foo bar]
          )
          expect(CodeownerValidator.send(identifier)).to eq('bar')
        end
      end

      context 'force_ask is true' do
        it 'configures the response' do
          expect(prompt).to receive(:select).and_return('baz')
          described_class.select(
            ident: identifier,
            prompt: 'prompt to user',
            choices: %w[foo bar],
            force_ask: true
          )
          expect(CodeownerValidator.send(identifier)).to eq('baz')
        end
      end
    end

    context 'CodeownerValidator does respond to ident' do
      before do
        allow(CodeownerValidator).to receive(:respond_to?).and_return(true)
      end

      context 'force_ask is false' do
        it 'does not ask for overwriting values' do
          expect(prompt).to_not receive(:select)
          expect(CodeownerValidator).to_not receive(:configure!)

          described_class.select(
            ident: identifier,
            prompt: 'prompt to user',
            choices: %w[foo bar]
          )
        end
      end

      context 'foce_ask is true' do
        it 'configures the response' do
          expect(prompt).to receive(:select)
          expect(CodeownerValidator).to receive(:configure!)

          described_class.select(
            ident: identifier,
            prompt: 'prompt to user',
            choices: %w[foo bar],
            force_ask: true
          )
        end
      end
    end
  end
end
