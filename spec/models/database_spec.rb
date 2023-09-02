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
end
