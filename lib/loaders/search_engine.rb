# frozen_string_literal: true

require 'dry/monads/do'

class Loaders::SearchEngine
  class << self
    include Dry::Monads::Do.for(:call)
    include Dry::Monads[:try, :result]

    def call(output:, load_paths:)
      output.puts('Loading data...')
      data = yield load_input_data(load_paths)
      output.puts('Finished loading data!')

      output.puts('Initializing application...')
      search_engine = yield SearchEngine.init(
        user_json: data[:user_json],
        organization_json: data[:organization_json],
        ticket_json: data[:ticket_json]
      )
      output.puts('Finished initializing application!')
      output.puts('==================================')
      output.puts('Welcome to Zendesk Search')
      Success(search_engine)
    end

    private

    def load_input_data(load_paths)
      Try[Errno::ENOENT] do
        {
          user_json: File.read(load_paths[:users]),
          organization_json: File.read(load_paths[:organizations]),
          ticket_json: File.read(load_paths[:tickets])
        }
      end.to_result
    end
  end
end
