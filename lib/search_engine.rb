# frozen_string_literal: true

require 'json'
require 'dry/monads/do'

class SearchEngine
  include Dry::Monads[:try, :result]
  include Dry::Monads::Do.for(:search_for)

  class << self
    include Dry::Monads::Do.for(:init)
    include Dry::Monads[:try, :result]

    def init(user_json:, organization_json:, ticket_json:)
      parsed_user_json = yield parse_json(user_json)
      parsed_organization_json = yield parse_json(organization_json)
      parsed_ticket_json = yield parse_json(ticket_json)

      db = yield Services::GenerateDatabase.call(
        'users' => parsed_user_json,
        'organizations' => parsed_organization_json,
        'tickets' => parsed_ticket_json
      )

      Success(new(Repo.new(db)))
    end

    private

    def parse_json(json)
      Try[JSON::ParserError] { JSON.parse(json) }.to_result
    end
  end

  attr_reader :repo

  def initialize(repo)
    @repo = repo
  end

  def list_records
    repo.list_records
  end

  def get_possible_terms_for(record:)
    Services::FetchSchema.new.call(record:).fmap(&:keys)
  end

  def validate_search_term(record:, search_term:)
    get_possible_terms_for(record:).bind do |possible_terms|
      Validators::SearchTerm.call(possible_terms:, search_term:)
    end
  end

  def search_for(record:, search_term:, value:)
    schema = yield Services::FetchSchema.new.call(record:)
    yield Validators::SearchTerm.call(possible_terms: schema.keys, search_term:)
    parsed_value = yield Validators::SearchValue.new.call(type: schema.dig(search_term, :type), value:)

    repo.search(record:, search_term:, value: parsed_value)
  end
end
