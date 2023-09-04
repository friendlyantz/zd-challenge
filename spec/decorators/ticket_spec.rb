# frozen_string_literal: true

describe Decorators::Ticket do
  let(:data) do
    {
      _id: 123,
      url: 'some-url',
      external_id: 'some-external-id',
      created_at: Time.parse('2023-09-01T08:32:31 -10:00'),
      type: 'special',
      subject: 'urgent ticket',
      description: 'lalala',
      priority: 'urgent',
      status: 'open',
      submitter_id: 123,
      assignee_id: 987,
      organization_id: 101,
      tags: ['some-tags'],
      has_incidents: false,
      due_at: Time.parse('2023-09-05T08:32:31 -10:00'),
      via: 'web'
    }
  end

  let(:expected) do
    <<~DOCS
      * Ticket with _id 123
      _id                            123
      url                            some-url
      external_id                    some-external-id
      created_at                     2023-09-01 08:32:31 -1000
      type                           special
      subject                        urgent ticket
      description                    lalala
      priority                       urgent
      status                         open
      submitter_id                   123
      assignee_id                    987
      organization_id                101
      tags                           ["some-tags"]
      has_incidents                  false
      due_at                         2023-09-05 08:32:31 -1000
      via                            web
      --- Submitter:
          name:     antz
          alias:    friendlyantz
          role:     admin
      --- Assignee:
      --- Organization:
          name:     ZenDesk
    DOCS
  end

  it 'returns a formatted strings' do
    expect(
      described_class.call(
        Models::Ticket.new(data).add_references(
          submitter: { name: 'antz', alias: 'friendlyantz', role: 'admin' },
          assignee: nil,
          organization: { name: 'ZenDesk' }
        )
      )
    ).to match expected
  end
end
