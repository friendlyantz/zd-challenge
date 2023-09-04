# frozen_string_literal: true

describe Decorators::User do
  let(:data) do
    {
      _id: 123,
      url: 'some-url',
      external_id: 'some-external-id',
      name: 'some-name',
      alias: 'some-alias',
      created_at: Time.parse('2023-09-01T08:30:30 -10:00'),
      active: true,
      verified: true,
      shared: true,
      locale: 'en-AU',
      timezone: 'Australia/Melbourne',
      last_login_at: Time.parse('2023-09-04T08:32:31 -10:00'),
      email: 'some-email',
      phone: '000',
      signature: 'some-signature',
      organization_id: 101,
      tags: ['tag1'],
      suspended: false,
      role: 'user'
    }
  end

  let(:expected) do
    <<~DOCS
      * User with _id 123
      _id                            123
      url                            some-url
      external_id                    some-external-id
      name                           some-name
      alias                          some-alias
      created_at                     2023-09-01 08:30:30 -1000
      active                         true
      verified                       true
      shared                         true
      locale                         en-AU
      timezone                       Australia/Melbourne
      last_login_at                  2023-09-04 08:32:31 -1000
      email                          some-email
      phone                          000
      signature                      some-signature
      organization_id                101
      tags                           ["tag1"]
      suspended                      false
      role                           user
      --- Submitted Tickets:
       1. subject:  some subject
          priority: high
          status:   open
      --- Assigned Tickets:
       1. subject:  reply
          priority: low
          status:   closed
      --- Organization:
          name:     ZenDesk
    DOCS
  end

  it 'returns a formatted strings' do
    expect(
      described_class.call(
        Models::User.new(data).add_references(
          submitted_tickets: [{ subject: 'some subject', priority: 'high', status: 'open' }],
          assigned_tickets: [{ subject: 'reply', priority: 'low', status: 'closed' }],
          organization: { name: 'ZenDesk' }
        )
      )
    ).to match expected
  end
end
