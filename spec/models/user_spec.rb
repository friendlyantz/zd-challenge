# frozen_string_literal: true

describe Models::User do
  it 'raises ArgumentError when initialized with invalid keys' do
    expect { described_class.new({ _id: 1, non_existent_key: 'value' }) }.to raise_error(ArgumentError)
  end

  describe '#add_references' do
    it 'returns all links' do
      user = described_class.new({ _id: 800 })
                            .add_references(
                              submitted_tickets: [4, 34, 10],
                              assigned_tickets: %w[hey hello bye],
                              organization: 'ladida'
                            )
      expect(user.linked_submitted_tickets).to eq [4, 34, 10]
      expect(user.linked_assigned_tickets).to eq %w[hey hello bye]
      expect(user.linked_organization).to eq 'ladida'
    end
  end
end
