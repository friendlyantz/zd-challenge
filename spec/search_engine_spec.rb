# frozen_string_literal: true

require 'search_engine'
require 'json'

describe SearchEngine do
  let(:valid_organization_json_hash) do
    [
      {
        _id: 101,
        url: 'http://initech.zendesk.com/api/v2/organizations/101.json',
        external_id: '9270ed79-35eb-4a38-a46f-35725197ea8d',
        name: 'Enthaze',
        domain_names: ['kage.com', 'ecratic.com', 'endipin.com', 'zentix.com'],
        created_at: '2016-05-21T11:10:28 -10:00',
        details: 'MegaCorp',
        shared_tickets: false,
        tags: %w[Fulton West Rodriguez Farley]
      },
      {
        _id: 102,
        url: 'http://initech.zendesk.com/api/v2/organizations/102.json',
        external_id: '7cd6b8d4-2999-4ff2-8cfd-44d05b449226',
        name: 'Nutralab',
        domain_names: ['trollery.com', 'datagen.com', 'bluegrain.com', 'dadabase.com'],
        created_at: '2016-04-07T08:21:44 -10:00',
        details: 'Non profit',
        shared_tickets: false,
        tags: %w[Cherry Collier Fuentes Trevino]
      }
    ]
  end
  let(:valid_user_json_hash) do
    [
      {
        _id: 1,
        url: 'http://initech.zendesk.com/api/v2/users/1.json',
        external_id: '74341f74-9c79-49d5-9611-87ef9b6eb75f',
        name: 'Francisca Rasmussen',
        alias: 'Miss Coffey',
        created_at: '2023-09-01T05:19:46 -10:00',
        active: true,
        verified: true,
        shared: false,
        locale: 'en-AU',
        timezone: 'Sri Lanka',
        last_login_at: '2023-09-02T05:19:46 -10:00',
        email: 'coffeyrasmussen@flotonic.com',
        phone: '8335-422-718',
        signature: "Don't Worry Be Happy!",
        organization_id: 119,
        tags: ['Springville', 'Sutton', 'Hartsville/Hartley', 'Diaperville'],
        suspended: true,
        role: 'admin'
      },
      {
        _id: 2,
        url: 'http://initech.zendesk.com/api/v2/users/2.json',
        external_id: 'c9995ea4-ff72-46e0-ab77-dfe0ae1ef6c2',
        name: 'Cross Barlow',
        alias: 'Miss Joni',
        created_at: '2023-09-01T05:19:46 -10:00',
        active: true,
        verified: true,
        shared: false,
        locale: 'zh-CN',
        timezone: 'Armenia',
        last_login_at: '2023-09-02T05:19:46 -10:00',
        email: 'jonibarlow@flotonic.com',
        phone: '9575-552-585',
        signature: "Don't Worry Be Happy!",
        organization_id: 106,
        tags: %w[Foxworth Woodlands Herlong Henrietta],
        suspended: false,
        role: 'admin'
      }
    ]
  end
  let(:valid_ticket_json_hash) do
    [
      {
        _id: '436bf9b0-1147-4c0a-8439-6f79833bff5b',
        url: 'http://initech.zendesk.com/api/v2/tickets/436bf9b0-1147-4c0a-8439-6f79833bff5b.json',
        external_id: '9210cdc9-4bee-485f-a078-35396cd74063',
        created_at: '2016-04-28T11:19:34 -10:00',
        type: 'incident',
        subject: 'A Catastrophe in Korea (North)',
        description: 'some description',
        priority: 'high',
        status: 'pending',
        submitter_id: 38,
        assignee_id: 24,
        organization_id: 116,
        tags: ['Ohio', 'Pennsylvania', 'American Samoa', 'Northern Mariana Islands'],
        has_incidents: false,
        due_at: '2016-07-31T02:37:50 -10:00',
        via: 'web'
      },
      {
        _id: '1a227508-9f39-427c-8f57-1b72f3fab87c',
        url: 'http://initech.zendesk.com/api/v2/tickets/1a227508-9f39-427c-8f57-1b72f3fab87c.json',
        external_id: '3e5ca820-cd1f-4a02-a18f-11b18e7bb49a',
        created_at: '2016-04-14T08:32:31 -10:00',
        type: 'incident',
        subject: 'A Catastrophe in Micronesia',
        description: 'some decription',
        priority: 'low',
        status: 'hold',
        submitter_id: 71,
        assignee_id: 38,
        organization_id: 112,
        tags: ['Puerto Rico', 'Idaho', 'Oklahoma', 'Louisiana'],
        has_incidents: false,
        due_at: '2016-08-15T05:37:32 -10:00',
        via: 'chat'
      }
    ]
  end

  let(:search_engine) do
    described_class.init(
      user_json: JSON.generate(valid_user_json_hash),
      organization_json: JSON.generate(valid_organization_json_hash),
      ticket_json: JSON.generate(valid_ticket_json_hash)
    )
  end

  describe '#init' do
    it 'returns Success monad with correct data' do
      init = described_class.init(
        user_json: JSON.generate(valid_user_json_hash),
        organization_json: JSON.generate(valid_organization_json_hash),
        ticket_json: JSON.generate(valid_ticket_json_hash)
      )
      expect(init).to be_a Dry::Monads::Result::Success
      expect(init.value!).to be_a described_class
    end

    context 'when provided user_json is invalid' do
      it 'returns a failure' do
        init = described_class.init(
          user_json: 'invalid json data',
          organization_json: JSON.generate(valid_organization_json_hash),
          ticket_json: JSON.generate(valid_ticket_json_hash)
        )
        expect(init).to be_a Dry::Monads::Result::Failure
        expect(init.failure).to be_a(JSON::ParserError)
      end
    end

    context 'when provided organization_json is invalid' do
      it 'returns a failure' do
        init = described_class.init(
          user_json: JSON.generate(valid_user_json_hash),
          organization_json: 'invalid json data',
          ticket_json: JSON.generate(valid_ticket_json_hash)
        )
        expect(init.failure).to be_a(JSON::ParserError)
      end
    end

    context 'when provided ticket_json is invalid' do
      it 'returns a failure' do
        init = described_class.init(
          user_json: JSON.generate(valid_user_json_hash),
          organization_json: JSON.generate(valid_organization_json_hash),
          ticket_json: 'invalid json data'
        )
        expect(init.failure).to be_a(JSON::ParserError)
      end
    end

    context 'when there is an error in generating database' do
      it 'returns a failure' do
        init = described_class.init(
          user_json: JSON.generate([{ 'invalid key' => 'value' }]),
          organization_json: JSON.generate(valid_organization_json_hash),
          ticket_json: JSON.generate(valid_ticket_json_hash)
        )
        expect(init.failure).to be_a(Errors::GenerateDatabase)
      end
    end
  end

  describe '#search_for' do
    let(:valid_search_term) { 'created_at' }
    let(:valid_record) { 'users' }
    let(:valid_value) { '2023-09-01T05:19:46 -10:00' }

    it 'returns a Failure fetching schema for unkown record' do
      expect(
        search_engine.value!.search_for(record: 'unkown', search_term: valid_search_term, value: valid_value)
        .failure
      ).to be_a Errors::UnknownSchema
    end

    it 'returns a Failure for unkown term' do
      expect(
        search_engine.value!.search_for(record: valid_record, search_term: 'invalid_search_term', value: valid_value)
        .failure
      ).to be_a Errors::UnknownSearchTerm
    end

    it 'returns a Failure invalid value type' do
      expect(
        search_engine.value!.search_for(record: valid_record, search_term: valid_search_term, value: 'INvalid_value')
        .failure
      ).to be_a Errors::InvalidSearchValue
    end

    it 'returns a Success and correct data for valid query' do
      search_for = search_engine.value!.search_for(
        record: valid_record, search_term: valid_search_term, value: valid_value
      )
      expect(search_for).to be_a Dry::Monads::Result::Success
      expect(search_for.value!.size).to eq 2
    end
  end
end
