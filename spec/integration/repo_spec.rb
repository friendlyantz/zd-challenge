# frozen_string_literal: true

describe Repo, type: :integration do
  let(:schema) do
    {
      'users' => { '_id' => { type: 'Integer', 'primary_key' => true },
                   'organization_id' => { type: 'Integer' } },
      'organizations' => { '_id' => { type: 'Integer', 'primary_key' => true } },
      'tickets' => { '_id' => { type: 'String', 'primary_key' => true },
                     'assignee_id' => { type: 'Integer' },
                     'submitter_id' => { type: 'Integer' },
                     'organization_id' => { type: 'Integer' } }
    }
  end

  let(:db_data) do
    {
      'users' => { 1 => { '_id' => 1, 'organization_id' => 101 },
                   2 => { '_id' => 2, 'organization_id' => 999 },
                   'index' => {
                     'organization_id' => { 101 => [1], 999 => [2] }
                   } },
      'organizations' => {
        101 => { '_id' => 101 },
        102 => { '_id' => 102 }
      },
      'tickets' => {
        '74341f74-9c79-49d5-9611-87ef9b6eb75f' => ticket_one,
        '9270ed79-35eb-4a38-a46f-35725197ea8d' => ticket_two,
        'index' => {
          'submitter_id' => {
            1 => ['74341f74-9c79-49d5-9611-87ef9b6eb75f'],
            999 => ['9270ed79-35eb-4a38-a46f-35725197ea8d']
          },
          'assignee_id' => {
            1 => ['74341f74-9c79-49d5-9611-87ef9b6eb75f'],
            999 => ['9270ed79-35eb-4a38-a46f-35725197ea8d']
          },
          'organization_id' => {
            101 => ['74341f74-9c79-49d5-9611-87ef9b6eb75f'],
            999 => ['9270ed79-35eb-4a38-a46f-35725197ea8d']
          }
        }
      }
    }
  end

  let(:ticket_one) do
    {
      '_id' => '74341f74-9c79-49d5-9611-87ef9b6eb75f',
      'submitter_id' => 1,
      'assignee_id' => 1,
      'organization_id' => 101
    }
  end

  let(:ticket_two) do
    {
      '_id' => '9270ed79-35eb-4a38-a46f-35725197ea8d',
      'submitter_id' => 999,
      'assignee_id' => 999,
      'organization_id' => 999
    }
  end

  describe '#search' do
    subject(:search_results) do
      described_class
        .new(Models::Database.new(db_data, schema))
        .search(record:, search_term:, value:)
    end

    context 'with invalid data' do
      let(:record) { 'Fusers' }
      let(:search_term) { '_id' }
      let(:value) { 1 }

      it 'returns Success monad with correct data' do
        expect(search_results).to be_a Dry::Monads::Result::Failure
      end
    end

    context 'when searching for users' do
      context 'with _id 1' do
        let(:record) { 'users' }
        let(:search_term) { '_id' }
        let(:value) { 1 }
        let(:expected_tickets) { [Models::Ticket.new(ticket_one)] }

        it 'returns Success monad with correct data' do
          expect(search_results).to be_a Dry::Monads::Result::Success
          expect(search_results.value!).to all(be_a(Models::User))
          expect(search_results.value!.size).to eq 1
          expect(search_results.value!.first.linked_submitted_tickets).to eq(expected_tickets)
          expect(search_results.value!.first.linked_assigned_tickets).to eq(expected_tickets)
          expect(search_results.value!.first.linked_organization).to eq(Models::Organization.new({ '_id' => 101 }))
        end
      end

      context 'with _id 2' do
        let(:record) { 'users' }
        let(:search_term) { '_id' }
        let(:value) { 2 }

        it 'returns Success monad with correct data' do
          expect(search_results).to be_a Dry::Monads::Result::Success
          expect(search_results.value!).to all(be_a(Models::User))
          expect(search_results.value!.size).to eq 1
          expect(search_results.value!.first.linked_submitted_tickets).to be_empty
          expect(search_results.value!.first.linked_assigned_tickets).to be_empty
          expect(search_results.value!.first.linked_organization).to be_nil
        end
      end
    end

    context 'when searching for organizations' do
      context 'with _id 101' do
        let(:record) { 'organizations' }
        let(:search_term) { '_id' }
        let(:value) { 101 }

        it 'returns Success monad and correct data' do
          expect(search_results).to be_a Dry::Monads::Result::Success
          expect(search_results.value!).to all(be_a(Models::Organization))
          expect(search_results.value!.size).to eq 1
          expect(search_results.value!.first.linked_tickets).to eq([Models::Ticket.new(ticket_one)])
          expect(search_results.value!.first.linked_users).to eq([Models::User.new({ '_id' => 1,
                                                                                     'organization_id' => 101 })])
        end
      end

      context 'with _id 102' do
        let(:record) { 'organizations' }
        let(:search_term) { '_id' }
        let(:value) { 102 }

        it 'returns a Success with correct data' do
          expect(search_results).to be_a Dry::Monads::Result::Success
          expect(search_results.value!).to all(be_a(Models::Organization))
          expect(search_results.value!.size).to eq 1
          expect(search_results.value!.first.linked_tickets).to be_empty
          expect(search_results.value!.first.linked_users).to be_empty
        end
      end
    end

    context 'when searching for tickets' do
      context 'with _id 74341f74-9c79-49d5-9611-87ef9b6eb75f' do
        let(:record) { 'tickets' }
        let(:search_term) { '_id' }
        let(:value) { '74341f74-9c79-49d5-9611-87ef9b6eb75f' }

        it 'returns Success monad with correct data' do
          expected_user = Models::User.new({ '_id' => 1, 'organization_id' => 101 })

          expect(search_results).to be_a Dry::Monads::Result::Success
          expect(search_results.value!).to all(be_a(Models::Ticket))
          expect(search_results.value!.size).to eq 1
          expect(search_results.value!.first.linked_submitter).to eq(expected_user)
          expect(search_results.value!.first.linked_assignee).to eq(expected_user)
          expect(search_results.value!.first.linked_organization).to eq(Models::Organization.new({ '_id' => 101 }))
        end
      end

      context 'with _id 9270ed79-35eb-4a38-a46f-35725197ea8d' do
        let(:record) { 'tickets' }
        let(:search_term) { '_id' }
        let(:value) { '9270ed79-35eb-4a38-a46f-35725197ea8d' }

        it 'returns Success monad and correct data' do
          expect(search_results).to be_a Dry::Monads::Result::Success
          expect(search_results.value!).to all(be_a(Models::Ticket))
          expect(search_results.value!.size).to eq 1
          expect(search_results.value!.first.linked_submitter).to be_nil
          expect(search_results.value!.first.linked_assignee).to be_nil
          expect(search_results.value!.first.linked_organization).to be_nil
        end
      end
    end
  end
end
