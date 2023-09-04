# frozen_string_literal: true

module Decorators
  class Organization
    class << self
      def call(organization)
        string = ''
        string += "* Organization with _id #{organization._id}\n"
        string += decorate_organization_data(organization)

        string += "--- Users:\n"
        string += decorate_users(organization.linked_users)

        string += "--- Tickets:\n"
        string += decorate_tickets(organization.linked_tickets)

        string
      end

      private

      def decorate_organization_data(organization)
        string = ''
        value_mappings = Schema::ORGANIZATIONS.keys.map { |attr| [attr, organization[attr.to_sym]] }

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

      def decorate_users(users)
        string = ''
        users.each_with_index do |user, index|
          string += "#{index + 1}.".rjust(3) + ' name:'.ljust(10) + " #{user[:name]}\n"
          string += ''.rjust(3) + ' alias:'.ljust(10) + " #{user[:alias]}\n"
          string += ''.rjust(3) + ' role:'.ljust(10) + " #{user[:role]}\n"
        end
        string
      end
    end
  end
end
