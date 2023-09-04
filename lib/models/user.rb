# frozen_string_literal: true

module Models
  User = Struct.new(
    *Schema::USERS.keys.map(&:to_sym),
    :linked_submitted_tickets,
    :linked_assigned_tickets,
    :linked_organization,
    keyword_init: true
  ) do
    def add_references(submitted_tickets:, assigned_tickets:, organization:)
      self.class.new(
        to_h.merge(
          linked_submitted_tickets: submitted_tickets,
          linked_assigned_tickets: assigned_tickets,
          linked_organization: organization
        )
      )
    end

    def to_s(decorator = Decorators::User)
      decorator.call(self)
    end
  end
end
