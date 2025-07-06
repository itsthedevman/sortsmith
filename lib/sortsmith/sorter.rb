# frozen_string_literal: true

module Sortsmith
  class Sorter
    def initialize(input)
      @input = input
      @steps = []
      @ordering_steps = []
    end

    ############################################################################
    # Extractors
    def dig(*identifiers, indifferent: false)
      @steps << {method: :dig, positional: identifiers, indifferent:}
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

    ############################################################################
    # Ordering
    def asc
      @ordering_steps << {method: :sort!}
      self
    end

    def desc
      @ordering_steps << {method: :reverse!}
      self
    end

    ############################################################################
    # Terminators
    def sort
      # Sort
      sorted = @input.sort do |item_a, item_b|
        apply_steps(item_a, item_b)
      end

      # Order
      apply_ordering_steps(sorted)
    end

    def sort!
      # Sort
      @input.sort! do |item_a, item_b|
        apply_steps(item_a, item_b)
      end

      # Order
      apply_ordering_steps(@input)
    end

    def reverse
      desc.sort
    end

    def reverse!
      desc.sort!
    end

    private

    def apply_steps(item_a, item_b)
      @steps.each do |step|
        item_a, item_b = apply_step(step, item_a, item_b)
      end

      item_a <=> item_b
    end

    def apply_step(step, item_a, item_b)
      method = step[:method]
      positional = step[:positional] || []
      indifferent = step[:indifferent] || false

      if indifferent
        positional = positional.map { |i| i.respond_to?(:to_sym) ? i.to_sym : i }
      end

      item_a =
        if item_a.respond_to?(method)
          item_a = item_a.transform_keys(&:to_sym) if indifferent
          item_a.public_send(method, *positional)
        else
          item_a.to_s
        end

      item_b =
        if item_b.respond_to?(method)
          item_b = item_b.transform_keys(&:to_sym) if indifferent
          item_b.public_send(method, *positional)
        else
          item_b.to_s
        end

      [item_a, item_b]
    end

    def apply_ordering_steps(sorted)
      @ordering_steps.each do |step|
        sorted.public_send(step[:method])
      end

      sorted
    end
  end
end
