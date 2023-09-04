# frozen_string_literal: true

describe Validators::SearchTerm do
  it 'returns a failure if value is not part of search terms' do
    expect(
      described_class.call(possible_terms: ['url'], search_term: 'invalid')
    .failure
    ).to be_a(Errors::UnknownSearchTerm)
  end

  it 'returns a success for valid terms' do
    expect(
      described_class.call(possible_terms: %w[_id url], search_term: 'url')
    ).to be_a Dry::Monads::Result::Success
  end
end
