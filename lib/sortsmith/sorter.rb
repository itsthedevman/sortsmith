# frozen_string_literal: true

module Sortsmith
  class Sorter
    def initialize(input)
      @input = input
      @steps = []
    end

    ############################################################################
    # Extractors
    def dig(*identifiers)
      @steps << {method: :dig, arguments: identifiers}
      self
    end

    ############################################################################
    # Modifiers
    def downcase
      @steps << {method: :downcase}
      self
    end

    alias_method :insensitive, :downcase

    def upcase
      @steps << {method: :upcase}
      self
    end

    def reverse
      @steps << {method: :reverse}
      self
    end

    alias_method :asc, :self

    alias_method :desc, :reverse

    ############################################################################
    # Terminators
    def sort
      @input.sort do |item_a, item_b|
      end
    end

    def sort!
      @input.sort! do |item_a, item_b|
      end
    end
  end
end
