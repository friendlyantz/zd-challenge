# frozen_string_literal: true

class Decorators::Ticket
  class << self
    def call(ticket)
      string = ''
      string += "* Ticket with _id #{ticket._id}\n"
      string += decorate_ticket_data(ticket)

      string += "--- Submitter:\n"
      string += decorate_user(ticket.linked_submitter)

      string += "--- Assignee:\n"
      string += decorate_user(ticket.linked_assignee)

      string += "--- Organization:\n"
      string += decorate_organization(ticket.linked_organization)

      string
    end

    private

    def decorate_ticket_data(ticket)
      string = ''
      value_mappings = Schema::TICKETS.keys.map { |attr| [attr, ticket[attr.to_sym]] }

      value_mappings.each { |(attr, value)| string += "#{attr.ljust(30)} #{value}\n" }

      string
    end

    def decorate_user(user)
      return '' if user.nil?

      string = ''
      string += ''.rjust(3) + ' name:'.ljust(10) + " #{user[:name]}\n"
      string += ''.rjust(3) + ' alias:'.ljust(10) + " #{user[:alias]}\n"
      string += ''.rjust(3) + ' role:'.ljust(10) + " #{user[:role]}\n"
      string
    end

    def decorate_organization(organization)
      return '' if organization.nil?

      ''.rjust(3) + ' name:'.ljust(10) + " #{organization[:name]}\n"
    end
  end
end
