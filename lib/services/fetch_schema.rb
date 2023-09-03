# frozen_string_literal: true

require 'dry/monads' # FIXME: cant use zeitwerk here somehow # might be require for incl Dry..
require 'dry/transaction' # FIXME: cant use zeitwerk here somehow # might be require for incl Dry..

class Services::FetchSchema
  include Dry::Monads[:try, :result]
  include Dry::Transaction

  step :exec

  def call(record:)
    case record
    in 'users' | 'organizations' | 'tickets' => matched_record
      Try { Schema.const_get(matched_record.upcase) }
        .to_result
        .or(Failure(
              Errors::UnknownSchema.new("schema not found for #{record} record")
            ))
    else
      Failure(
        Errors::UnknownSchema.new("unknown #{record} record")
      )
    end
  end
end
