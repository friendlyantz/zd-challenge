# frozen_string_literal: true

require 'dry/monads'

class Repo
  include Dry::Monads[:try, :result]

  attr_reader :database

  def initialize(database)
    @database = database
  end

  def list_records
    Try { database.list_records }.to_result
  end

  def search(record:, search_term:, value:)
    Try do
      method("search_#{record}")
        .call(search_term, value)
        .then { |results| method("search_#{record}_associations").call(results) }
    end.to_result
  end

  private

  def search_users(search_term, value)
    search_records('users')
      .call(search_term, value)
      .map { |record| Models::User.new(record.transform_keys(&:to_sym)) }
  end

  def search_users_associations(users)
    users.map do |user|
      user.add_references(
        submitted_tickets: search_tickets('submitter_id', user._id),
        assigned_tickets: search_tickets('assignee_id', user._id),
        organization: search_organizations('_id', user.organization_id).first
      )
    end
  end

  def search_organizations(search_term, value)
    search_records('organizations')
      .call(search_term, value)
      .map { |record| Models::Organization.new(record.transform_keys(&:to_sym)) }
  end

  def search_organizations_associations(organizations)
    organizations.map do |organization|
      organization.add_references(
        tickets: search_tickets('organization_id', organization._id),
        users: search_users('organization_id', organization._id)
      )
    end
  end

  def search_tickets(search_term, value)
    search_records('tickets')
      .call(search_term, value)
      .map { |record| Models::Ticket.new(record.transform_keys(&:to_sym)) }
  end

  def search_tickets_associations(tickets)
    tickets.map do |ticket|
      ticket.add_references(
        submitter: search_users('_id', ticket.submitter_id).first,
        assignee: search_users('_id', ticket.assignee_id).first,
        organization: search_organizations('_id', ticket.organization_id).first
      )
    end
  end

  def search_records(record)
    lambda do |search_term, value|
      if database.schema.dig(record, search_term, 'primary_key')
        [database.get_record(record:, key: value)].compact
      else
        search_by_index(record, search_term, value)
      end
    end
  end

  def search_by_index(record, search_term, value)
    database
      .search_index(record:, paths: [search_term, *value])
      .map { |index| database.get_record(record:, key: index) }
  end
end
