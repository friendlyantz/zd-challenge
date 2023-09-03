# frozen_string_literal: true

describe Models::Database do
  describe '#add_schema' do
    it 'adds schema' do
      db = Models::Database.new
      db.add_schema(record: 'some_record', schema: { id: { type: 'String' } })
      expect(db.schema).to eq({ 'some_record' => { id: { type: 'String' } } })
    end
  end

  describe '#get_record' do
    it 'returns value of the record or nil for non-existebt object or keys' do
      db = Models::Database.new({ some_object: { 'column_name' => 777 } })
      expect(db.get_record(record: :some_object, key: 'column_name')).to eq 777
      expect(db.get_record(record: 'some_object', key: 'column_name')).to eq nil
      expect(db.get_record(record: :some_object, key: 2)).to eq nil
    end
  end

  describe '#add_record' do
    context 'when db is empty' do
      let(:db) { Models::Database.new({}) }

      it 'add new records' do
        db.add_record(record: :some_object, key: 'new_key', value: { new: 'key' })
        expect(db.data).to match({ some_object: { 'new_key' => { new: 'key' } } })
      end
    end

    context 'when db has records' do
      let(:db) { Models::Database.new(some_object: { 'existing_key' => { existing: 'key' } }) }

      it 'overrides existing data' do
        db.add_record(record: :some_object, key: 'existing_key', value: { overriden: 'value' })
        expect(db.data).to match({ some_object: { 'existing_key' => { overriden: 'value' } } })
      end
    end
  end

  describe 'index and search' do
    describe '#search_index' do
      it 'returns the value or an empty array when provided record does not exist' do
        db = described_class
             .new(some_object: { 'index' => { 'some_key_for_trie' => { 'some_other_key_trie' => [777] } } })
        expect(db.search_index(record: :some_object, paths: %w[some_key_for_trie some_other_key_trie])).to eq [777]
        expect(db.search_index(record: :some_object, paths: ['is_admin', false])).to eq []
        expect(db.search_index(record: :non_existent, paths: %w[some_key_for_trie some_other_key_trie])).to eq []
      end
    end

    describe '#add_index' do
      context 'when initial data is empty' do
        let(:db) { described_class.new({}) }

        it 'updates the index within the data with the provided record, paths, and index' do
          db.add_index(record: :some_record, paths: %w[trie_key_one trie_key_two], index: 777)
          expect(db.data).to match({ some_record: { 'index' => { 'trie_key_one' => { 'trie_key_two' => [777] } } } })
        end
      end

      context 'when initial data is not empty' do
        let(:db) do
          described_class.new({ some_record: { 'index' => { 'trie_key_one' => { 'trie_key_two' => [25] } } } })
        end

        it 'append the index within the data with the provided record, paths, and index' do
          db.add_index(record: :some_record, paths: %w[trie_key_one trie_key_two], index: 777)
          db.add_index(record: :some_record, paths: %w[trie_key_one another_trie_key_two], index: 888)
          expect(db.data).to match(
            { some_record: { 'index' => { 'trie_key_one' =>
              {
                'trie_key_two' => [25, 777],
                'another_trie_key_two' => [888]
              } } } }
          )
        end
      end
    end
  end
end
