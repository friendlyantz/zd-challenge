# frozen_string_literal: true

module Decorators
  class User
    class << self
      def call(user)
        string = ''
        string += "* User with _id #{user._id}\n"
        string += decorate_user_data(user)

        string += "--- Submitted Tickets:\n"
        string += decorate_tickets(user.linked_submitted_tickets)

        string += "--- Assigned Tickets:\n"
        string += decorate_tickets(user.linked_assigned_tickets)

        string += "--- Organization:\n"
        string += decorate_organization(user.linked_organization)

        string
      end

      private

      def decorate_user_data(user)
        string = ''
        value_mappings = Schema::USERS.keys.map { |attr| [attr, user[attr.to_sym]] }

        value_mappings.each { |(attr, value)| string += "#{attr.ljust(30)} #{value}\n" }

        string
      end

      def decorate_tickets(tickets)
        string = ''
        tickets.each_with_index do |ticket, index|
          string += "#{index + 1}.".rjust(3) + ' subject:'.ljust(10) + " #{ticket[:subject]}\n"
          string += ''.rjust(3) + ' priority:'.ljust(10) + " #{ticket[:priority]}\n"
          string += ''.rjust(3) + ' status:'.ljust(10) + " #{ticket[:status]}\n"
        end
        string
      end

      def decorate_organization(organization)
        return '' if organization.nil?

        ''.rjust(3) + ' name:'.ljust(10) + " #{organization[:name]}\n"
      end
    end
  end
end
