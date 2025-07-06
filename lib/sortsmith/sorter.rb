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

    def asc
      @steps << {type: :ordering, method: :sort!}
      self
    end

    def desc
      @steps << {type: :ordering, method: :reverse!}
      self
    end

    ############################################################################
    # Terminators
    def sort
      # Extract
      ordering_steps, steps = extract_steps

      # Sort
      sorted = @input.sort do |item_a, item_b|
        apply_steps(steps, item_a, item_b)
      end

      # Order
      apply_ordering_steps(ordering_steps, sorted)
    end

    def sort!
      # Extract
      ordering_steps, steps = extract_steps

      # Sort
      @input.sort! do |item_a, item_b|
        apply_steps(steps, item_a, item_b)
      end

      # Order
      apply_ordering_steps(ordering_steps, @input)
    end

    def reverse
      desc.sort
    end

    def reverse!
      desc.sort!
    end

    private

    def extract_steps
      @steps.partition { |s| s[:type] == :ordering }
    end

    def apply_steps(steps, item_a, item_b)
      steps.each do |step|
        item_a, item_b = apply_step(step, item_a, item_b)
      end

      item_a <=> item_b
    end

    def apply_step(step, item_a, item_b)
      method = step[:method]
      arguments = step[:arguments] || []

      signature =
        if arguments.size > 0
          [method, *arguments]
        else
          [method]
        end

      item_a =
        if item_a.respond_to?(method)
          item_a.public_send(*signature)
        else
          item_a.to_s
        end

      item_b =
        if item_b.respond_to?(method)
          item_b.public_send(*signature)
        else
          item_b.to_s
        end

      [item_a, item_b]
    end

    def apply_ordering_steps(steps, sorted)
      return sorted if steps.size == 0

      steps.each do |step|
        sorted.public_send(step[:method])
      end

      sorted
    end
  end
end
