# frozen_string_literal: true

module Models
  Organization = Struct.new(
    *Schema::ORGANIZATIONS.keys.map(&:to_sym),
    :linked_tickets,
    :linked_users,
    keyword_init: true
  ) do
    def add_references(tickets:, users:)
      # require 'pry'; binding.pry
      self.class.new(
        to_h.merge(
          linked_tickets: tickets,
          linked_users: users
        )
      )
    end

    def to_s(decorator = Decorators::Organization)
      decorator.call(self)
    end
  end
end
