# frozen_string_literal: true

describe Models::Organization do
  it 'raises ArgumentError when initialized with invalid keys' do
    expect { described_class.new({ _id: 1, non_existant_key: 'value' }) }.to raise_error(ArgumentError)
  end

  describe '#add_references' do
    it 'returns all links' do
      organization = described_class.new({ _id: 1 })
                                    .add_references(
                                      tickets: [1, 2, 3],
                                      users: %w[friendlyantz unclebob prime]
                                    )
      expect(organization.linked_tickets).to eq [1, 2, 3]
      expect(organization.linked_users).to eq %w[friendlyantz unclebob prime]
    end
  end

  describe '#to_s' do
    let(:decorator) do
      ->(organization) { "organization has id of #{organization._id}" }
    end

    it 'returns the decorated_version' do
      expect(
        described_class.new({ _id: 123 }).to_s(decorator)
      ).to eq 'organization has id of 123'
    end
  end
end
