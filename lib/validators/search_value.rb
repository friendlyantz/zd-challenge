# frozen_string_literal: true

class Validators::SearchValue
  include Dry::Transaction
  include Dry::Monads[:result]

  step :exec

  def exec(type:, value:)
    Parsers::SearchValue
      .call(type:, value:)
      .to_result(
        Errors::InvalidSearchValue.new(
          "INVALID TYPE FOR SEARCH TERM: #{value}"
        )
      )
  end
end
