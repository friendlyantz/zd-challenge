# frozen_string_literal: true

describe Decorators::Organization do
  let(:data) do
    {
      _id: 777,
      url: 'some-url',
      external_id: 'some-external-id',
      name: 'some-name',
      domain_names: ['a.com', 'b.com'],
      created_at: Time.parse('2023-09-01T08:32:31 -10:00'),
      details: 'some-details',
      shared_tickets: true,
      tags: ['some-tag']
    }
  end

  let(:expected) do
    <<~DOCS
      * Organization with _id 777
      _id                            777
      url                            some-url
      external_id                    some-external-id
      name                           some-name
      domain_names                   ["a.com", "b.com"]
      created_at                     2023-09-01 08:32:31 -1000
      details                        some-details
      shared_tickets                 true
      tags                           ["some-tag"]
      --- Users:
       1. name:     anton
          alias:    friendlyantz
          role:     admin
      --- Tickets:
       1. subject:  hi
          priority: high
          status:   open
    DOCS
  end

  it 'returns a formatted strings' do
    expect(
      described_class.call(
        Models::Organization.new(data)
        .add_references(
          tickets: [{ subject: 'hi', priority: 'high', status: 'open' }],
          users: [{ name: 'anton', alias: 'friendlyantz', role: 'admin' }]
        )
      )
    ).to match expected
  end
end
