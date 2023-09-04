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

  def add_index(record:, paths:, index:)
    new_record_ids = search_index(record:, paths:).to_a + [index]

    recursive_insert(
      [record, 'index', *paths],
      new_record_ids.uniq
    )
  end

  def search_index(record:, paths:)
    data.dig(record, 'index', *paths).to_a
  end

  def list_records
    data.keys
  end

  private

  def recursive_insert(keys, value, trie = data)
    key = keys.first
    if keys.length == 1
      trie[key] = value
    else
      trie[key] = {} unless trie[key]
      recursive_insert(keys.slice(1..-1), value, trie[key])
    end
  end
end
