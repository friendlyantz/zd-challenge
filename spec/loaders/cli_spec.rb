# frozen_string_literal: true

require 'stringio'

describe Loaders::Cli do
  include Dry::Monads[:result]

  let(:cli_command) do
    described_class.new(search_engine:, input:, output:)
  end
  let(:input) { StringIO.new }
  let(:output) { StringIO.new }
  let(:search_engine) do
    instance_double(
      SearchEngine,
      list_records:,
      get_possible_terms_for:,
      validate_search_term:,
      search_for:
    )
  end
  let(:list_records) { Success(['users']) }
  let(:get_possible_terms_for) { Success(['name']) }
  let(:validate_search_term) { Success() }
  let(:search_for) { Success([1]) }

  describe '.call' do
    subject(:call) { cli_command.call(command_one) }

    let(:command_one) do
      lambda do |_data|
        output.puts("command_one is called\n")
        Success({ next_command: command_two })
      end
    end
    let(:command_two) do
      lambda do |_data|
        output.puts("command_two is called\n")
        Success({ next_command: command_three })
      end
    end
    let(:command_three) do
      lambda do |_data|
        output.puts("command_three is called\n")
        Failure(:exit)
      end
    end

    it 'calls all the commands until it resolved to a Failure' do
      call
      expect(output.string).to match(
        "command_one is called\ncommand_two is called\ncommand_three is called"
      )
    end

    it 'returns a failure at the end' do
      expect(call.failure).to eq(:exit)
    end

    context 'when command_two returns a failure' do
      let(:command_two) do
        lambda do |_data|
          output.puts("command_two is called\n")
          Failure('error in command_two')
        end
      end

      it 'calls only command_one and comman_2' do
        call
        expect(output.string).to match(
          "command_one is called\ncommand_two is called"
        )
      end

      it 'returns the failure' do
        expect(call.failure).to eq('error in command_two')
      end
    end
  end

  describe '#select_object' do
    subject(:select_object) { cli_command.select_object(data) }

    let(:data) do
      {
        next_command: cli_command.method(:select_object)
      }
    end
    let(:input) { StringIO.new('1') }

    it 'outputs a welcome message' do
      select_object
      expect(output.string).to match(
        "Press '1' to search for users\nType 'exit' to exit anytime"
      )
    end

    context 'when search_engine.list_records returns a Failure' do
      let(:list_records) do
        Failure('error')
      end

      it 'returns a failure' do
        expect(select_object.failure).to eq 'error'
      end
    end

    context "when 'exit' input is received" do
      let(:input) { StringIO.new('exit') }

      it 'returns a failure' do
        expect(select_object.failure).to eq :exit
      end
    end

    context 'when entered input is valid' do
      let(:input) { StringIO.new('1') }

      it 'returns a success' do
        expect(select_object.success?).to be true
      end

      it 'has the record and next_command data' do
        expect(select_object.value!).to match({
                                                record: 'users',
                                                next_command: cli_command.method('enter_search_term')
                                              })
      end
    end

    context 'when entered input is invalid' do
      let(:input) { StringIO.new('-1') }

      it 'returns a success' do
        expect(select_object.success?).to be true
      end

      it 'has the next_command data' do
        expect(select_object.value!).to match({
                                                next_command: cli_command.method('select_object')
                                              })
      end

      it 'outputs a message' do
        select_object
        expect(output.string).to match(
          "Sorry, don't understand -1"
        )
      end
    end
  end

  describe '#enter_search_term' do
    subject(:enter_search_term) { cli_command.enter_search_term(data) }

    let(:data) do
      {
        record: 'users'
      }
    end
    let(:input) { StringIO.new('name') }

    it 'outputs a welcome message' do
      enter_search_term
      expect(output.string).to match <<~DOCS
        Search users with:
        _______________________
        name
        _______________________
        Enter search term:
      DOCS
    end

    context 'when search_engine.get_possible_terms_for returns a Failure' do
      let(:get_possible_terms_for) do
        Failure('error')
      end

      it 'returns a failure' do
        expect(enter_search_term.failure).to eq 'error'
      end
    end

    context "when 'exit' input is received" do
      let(:input) { StringIO.new('exit') }

      it 'returns a failure' do
        expect(enter_search_term.failure).to eq :exit
      end
    end

    context 'when entered input is valid' do
      let(:input) { StringIO.new('name') }

      it 'returns a success' do
        expect(enter_search_term.success?).to be true
      end

      it 'has the record, search_term, and next_command data' do
        expect(enter_search_term.value!).to match({
                                                    record: 'users',
                                                    search_term: 'name',
                                                    next_command: cli_command.method('enter_search_value')
                                                  })
      end
    end

    context 'when entered input is invalid' do
      let(:validate_search_term) do
        Failure(StandardError.new('invalid value'))
      end
      let(:input) { StringIO.new('-1') }

      it 'returns a success' do
        expect(enter_search_term.success?).to be true
      end

      it 'has the next_command data' do
        expect(enter_search_term.value!).to match({
                                                    record: 'users',
                                                    next_command: cli_command.method('enter_search_term')
                                                  })
      end

      it 'outputs a message' do
        enter_search_term
        expect(output.string).to match(
          'invalid value'
        )
      end
    end
  end

  describe '#enter_search_value' do
    subject(:enter_search_value) { cli_command.enter_search_value(data) }

    let(:data) do
      {
        record: 'users',
        search_term: 'name'
      }
    end
    let(:input) { StringIO.new('1') }

    it 'outputs a welcome message' do
      enter_search_value
      expect(output.string).to match(
        'Enter search value:'
      )
    end

    context "when 'exit' input is received" do
      let(:input) { StringIO.new('exit') }

      it 'returns a failure' do
        expect(enter_search_value.failure).to eq :exit
      end
    end

    context 'when entered input is valid and return search results' do
      let(:search_for) { Success(['user 1']) }
      let(:input) { StringIO.new('1') }

      it 'returns a success' do
        expect(enter_search_value.success?).to be true
      end

      it 'has the next_command data' do
        expect(enter_search_value.value!).to match({
                                                     next_command: cli_command.method('search_again')
                                                   })
      end

      it 'outputs a message' do
        enter_search_value
        expect(output.string).to match(
          "Found 1 search results.\nuser 1"
        )
      end
    end

    context 'when entered input is valid and return no search results' do
      let(:search_for) { Success([]) }
      let(:input) { StringIO.new('1') }

      it 'returns a success' do
        expect(enter_search_value.success?).to be true
      end

      it 'has the next_command data' do
        expect(enter_search_value.value!).to match({
                                                     next_command: cli_command.method('search_again')
                                                   })
      end

      it 'outputs a message' do
        enter_search_value
        expect(output.string).to match(
          'No results found.'
        )
      end
    end

    context 'when entered input is invalid' do
      let(:input) { StringIO.new('-1') }
      let(:search_for) { Failure(StandardError.new('invalid value')) }

      it 'returns a success' do
        expect(enter_search_value.success?).to be true
      end

      it 'has the record, search_term and next_command data' do
        expect(enter_search_value.value!).to match({
                                                     record: 'users',
                                                     search_term: 'name',
                                                     next_command: cli_command.method('enter_search_value')
                                                   })
      end

      it 'outputs a message' do
        enter_search_value
        expect(output.string).to match(
          'invalid value'
        )
      end
    end
  end

  describe '#search_again' do
    subject(:search_again) { cli_command.search_again(data) }

    let(:data) do
      {
        next_command: cli_command.method(:search_again)
      }
    end
    let(:input) { StringIO.new('y') }

    it 'outputs a welcome message' do
      search_again
      expect(output.string).to match(
        "Search again?: y/n\n"
      )
    end

    context "when 'exit' input is received" do
      let(:input) { StringIO.new('exit') }

      it 'returns a failure' do
        expect(search_again.failure).to eq :exit
      end
    end

    context "when 'n' input is received" do
      let(:input) { StringIO.new('n') }

      it 'returns a failure' do
        expect(search_again.failure).to eq :exit
      end
    end

    context 'when entered input is valid' do
      let(:input) { StringIO.new('y') }

      it 'returns a success' do
        expect(search_again.success?).to be true
      end

      it 'has the record and next_command data' do
        expect(search_again.value!).to match({
                                               next_command: cli_command.method('select_object')
                                             })
      end
    end

    context 'when entered input is invalid' do
      let(:input) { StringIO.new('-1') }

      it 'returns a success' do
        expect(search_again.success?).to be true
      end

      it 'has the next_command data' do
        expect(search_again.value!).to match({
                                               next_command: cli_command.method('search_again')
                                             })
      end

      it 'outputs a message' do
        search_again
        expect(output.string).to match(
          "Sorry, don't understand, please enter 'y' or 'n'\n"
        )
      end
    end
  end
end
