# frozen_string_literal: true

class Models::Database
  attr_reader :data, :schema

  def initialize(data = {}, schema = {})
    @data = data
    @schema = schema
  end

  def add_schema(record:, schema:)
    @schema[record] = schema
  end

  def get_record(record:, key:)
    data.dig(record, key)
  end

  def add_record(record:, key:, value:)
    data[record] = {} unless data[record]
    data[record][key] = value
  end
end
