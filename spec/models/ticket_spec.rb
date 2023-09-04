# frozen_string_literal: true

describe Models::Ticket do
  it 'raises ArgumentError when initialized with invalid keys' do
    expect { described_class.new({ _id: 1, non_existent_key: 'value' }) }.to raise_error(ArgumentError)
  end

  describe '#add_references' do
    it 'returns all links' do
      ticket = described_class.new({ _id: 123 })
                              .add_references(
                                submitter: 'friendlyantz',
                                assignee: 'bob',
                                organization: 'ZenDesk'
                              )
      expect(ticket.linked_submitter).to eq 'friendlyantz'
      expect(ticket.linked_assignee).to eq 'bob'
      expect(ticket.linked_organization).to eq 'ZenDesk'
    end
  end

  describe '#to_s' do
    let(:decorator) do
      ->(ticket) { "ticket has id of #{ticket._id}" }
    end

    it 'returns the decorated_version' do
      expect(
        described_class.new({ _id: 123 }).to_s(decorator)
      ).to eq 'ticket has id of 123'
    end
  end
end
