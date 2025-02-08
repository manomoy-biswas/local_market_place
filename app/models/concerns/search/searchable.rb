module Search
  module Searchable
    extend ActiveSupport::Concern

    included do
      include PgSearch::Model

      pg_search_scope :search_by_text,
        against: {
          title: "A",
          description: "B",
          tags: "C"
        },
        using: {
          tsearch: {
            prefix: true,
            dictionary: "english"
          }
        }

      pg_search_scope :search_by_location,
        against: %i[city state country postal_code address latitude longitude],
        using: {
          tsearch: {
            prefix: true
          }
        }
    end
  end
end