# frozen_string_literal: true

module Sortsmith
  class Sorter
    #
    # Creates a Sorter builder instance
    #
    # @param enumerable [Enumerable] The enumerable (Array, Hash) to sort
    #
    def initialize(enumerable)
      @enumerable = enumerable
      @steps = []
      @direction = :asc
    end

    #
    # Finalizes the Sorter instance and sorts the enumerable
    #
    # @return [Enumerable] The sorted enumerable
    #
    def sort
      filter_steps = select_filter_steps

      transformation_steps = [
        transform_to_string,
        *select_transformation_steps
      ]

      result =
        @enumerable.sort do |left, right|
          filter_steps.each do |step|
            left = step.perform(left)
            right = step.perform(right)
          end

          transformation_steps.each do |step|
            left = step.perform(left)
            right = step.perform(right)
          end

          left <=> right
        end

      (@direction == :asc) ? result : result.reverse
    end

    #
    # Instructs the sorter to perform a fetch by key on the Hash being sorted
    #
    # @param key [String, Symbol, Any] The hash key to fetch
    #
    # @return [Self] The sorter instance
    #
    def by_key(key)
      add_step(type: Step::FILTER) { |i| i&.fetch(key) }
      self
    end

    #
    # Instructs the sorter to perform a method call on the object being sorted
    #
    # @param method [String, Symbol] The method name to call
    #
    # @return [Self] The sorter instance
    #
    def by_method(method)
      add_step(type: Step::FILTER) { |i| i&.public_send(method) }
    end

    alias_method :by_attribute, :by_method

    #
    # Instructs the sorter to sort by a case insensitive value
    #
    # @return [Self] The sorter instance
    #
    def case_insensitive
      add_step(type: Step::TRANSFORMATION) do |item|
        [item&.downcase || "", item || ""]
      end
    end

    #
    # Controls which direction the array will be sorted
    #
    # @return [Self] The sorter instance
    #
    def asc
      @direction = :asc
      self
    end

    alias_method :forward, :asc

    #
    # Controls which direction the array will be sorted
    #
    # @return [Self] The sorter instance
    #
    def desc
      @direction = :desc
      self
    end

    alias_method :reverse, :desc

    private

    def add_step(type:, &block)
      @steps << Step.new(type: type, block: block)
      self
    end

    def select_filter_steps
      @steps.select { |s| s.type == Step::FILTER }
    end

    def select_transformation_steps
      @steps.select { |s| s.type == Step::TRANSFORMATION }
    end

    def transform_to_string
      Step.new(type: Step::TRANSFORMATION, block: ->(i) { i.to_s })
    end
  end
end
