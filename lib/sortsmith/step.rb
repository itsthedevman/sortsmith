# frozen_string_literal: true

module Sortsmith
  #
  # Represents a step in the sorting process
  #
  class Step < Data.define(:type, :block)
    TYPES = [
      TRANSFORMATION = :transformation,
      FILTER = :filter
    ].freeze

    def perform(item)
      block.call(item)
    end
  end
end
