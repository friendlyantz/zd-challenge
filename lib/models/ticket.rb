# frozen_string_literal: true

module Models
  Ticket = Struct.new(
    *Schema::TICKETS.keys.map(&:to_sym),
    :linked_submitter,
    :linked_assignee,
    :linked_organization,
    keyword_init: true
  ) do
    def add_references(submitter:, assignee:, organization:)
      self.class.new(
        to_h.merge(
          linked_submitter: submitter,
          linked_assignee: assignee,
          linked_organization: organization
        )
      )
    end

    def to_s(decorator = Decorators::Ticket)
      decorator.call(self)
    end
  end
end
