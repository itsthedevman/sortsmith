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
      @steps << {type: :ordering, method: :reverse}
      self
    end

    alias_method :asc, :self

    alias_method :desc, :reverse

    ############################################################################
    # Terminators
    def sort
      ordering_steps, steps = extract_steps

      sorted = @input.sort do |item_a, item_b|
        apply_steps(steps, item_a, item_b)
      end

      apply_ordering_steps(ordering_steps, sorted)
    end

    def sort!
      ordering_steps, steps = extract_steps

      @input.sort! do |item_a, item_b|
        apply_steps(steps, item_a, item_b)
      end

      apply_ordering_steps(ordering_steps, @input)
    end

    private

    def extract_steps
      @steps.partition { |s| s[:type] == :ordering }
    end

    def apply_steps(steps, item_a, item_b)
    end

    def apply_ordering_steps(steps, sorted)
      return sorted if steps.size == 0

      sorted
    end
  end
end
