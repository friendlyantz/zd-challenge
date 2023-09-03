# frozen_string_literal: true

describe Services::FetchSchema do
  it 'returns Success monad with correct schema for user record' do
    schema =  described_class.new.call(record:  'users')
    expect(schema).to be_a Dry::Monads::Result::Success
    expect(schema.value!).to eq Schema::USERS
  end

  it 'returns Success monad with correct schema for organisation record' do
    schema =  described_class.new.call(record: 'organizations')
    expect(schema).to be_a Dry::Monads::Result::Success
    expect(schema.value!).to eq Schema::ORGANIZATIONS
  end

  it 'returns Success monad with correct schema for organisation record' do
    schema =  described_class.new.call(record: 'tickets')
    expect(schema).to be_a Dry::Monads::Result::Success
    expect(schema.value!).to eq Schema::TICKETS
  end

  it 'returns Failure monad for unkown record' do
    schema =  described_class.new.call(record: 'unkown_record')
    expect(schema).to be_a Dry::Monads::Result::Failure
  end

  context 'when not able to find the schema' do
    it 'returns Failure monad ' do
      allow(Schema).to receive(:const_get).and_raise
      schema = described_class.new.call(record: 'tickets')
      expect(schema).to be_a Dry::Monads::Result::Failure
      expect(schema.failure).to be_a(Errors::UnknownSchema)
    end
  end
end
