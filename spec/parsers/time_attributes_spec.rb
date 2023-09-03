# frozen_string_literal: true

describe Parsers::TimeAttributes do
  it 'returns a None for invalid input' do
    expect(described_class.call(value: 'foo')).to be_a(Dry::Monads::None)
  end

  it 'returns Array of trie nodes for the provided time' do
    expect(
      described_class.call(value: '2023-09-01T02:25:45 -10:00').value!
    ).to eq([2023, 9, 1, 12, 25, 45])
  end
end
