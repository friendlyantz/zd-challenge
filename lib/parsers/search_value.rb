# frozen_string_literal: true

module Parsers
  class SearchValue
    class << self
      include Dry::Monads[:maybe, :try]

      def call(type:, value:)
        case [value, type]
        in ['', _]        then Some('')
        in [_, /String/]  then Some(value.downcase)
        in [_, /Integer/] then parse_integer(value)
        in [_, /Boolean/] then parse_boolean(value)
        in [_, /Time/]    then parse_time(value)
        in _              then None()
        end
      end

      private

      def parse_integer(value)
        Try[ArgumentError] { Integer(value) }.to_maybe
      end

      def parse_boolean(value)
        case value
        in true  | 'true'  then Some(true)
        in false | 'false' then Some(false)
        in _               then None()
        end
      end

      def parse_time(value)
        Parsers::TimeAttributes.call(value:)
      end
    end
  end
end
