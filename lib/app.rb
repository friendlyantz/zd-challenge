# frozen_string_literal: true

unless defined?(Zeitwerk)
  require 'zeitwerk'
  loader = Zeitwerk::Loader.new
  loader.push_dir('lib')
  loader.push_dir('db')
  loader.setup
end

LOAD_PATHS = {
  users: 'db/users.json',
  organizations: 'db/organizations.json',
  tickets: 'db/tickets.json'
}.freeze

class App
  def initialize(
    load_paths: LOAD_PATHS,
    output: Renderers::Printer.new,
    input: $stdin
  )
    Loaders::UiInterfaceErrors.call(output:) do
      Loaders::SearchEngine.call(output:, load_paths:)
                           .bind do |search_engine|
        Loaders::Cli
          .new(search_engine:, input:, output:)
          .call
      end
    end
  end
end
