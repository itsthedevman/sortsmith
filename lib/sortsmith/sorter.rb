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
      @pipeline = []
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
        # Transforms the item to a string immediately after filtering
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
    # Adds a "filter" step to the sort pipeline.
    # Filter steps are used to get data from the current item being sorted
    # These are performed before transformation steps
    #
    # @param & [Proc] The block to execute
    #
    # @return [Self] The sorter instance
    #
    def add_filter(&)
      add_step(type: Step::FILTER, &)
    end

    #
    # Adds a "transformation" step to the sort pipeline
    # Transformation steps are used to transform data.
    # These are performed after filter steps
    #
    # @param & [Proc] The block to execute
    #
    # @return [Self] The sorter instance
    #
    def add_transformation(&)
      add_step(type: Step::TRANSFORMATION, &)
    end

    #
    # Instructs the sorter to perform a fetch by key on the Hash being sorted
    #
    # @param key [String, Symbol, Any] The hash key to fetch
    #
    # @return [Self] The sorter instance
    #
    def by_key(key)
      add_filter { |i| i&.fetch(key) }
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
      add_filter { |i| i&.public_send(method) }
    end

    alias_method :by_attribute, :by_method

    #
    # Instructs the sorter to sort by a case insensitive value
    # This will prioritize capital letters first, followed by their lowercase counterparts
    #
    # @return [Self] The sorter instance
    #
    def case_insensitive
      add_transformation do |item|
        text = item.to_s
        text.chars.flat_map { |c| [c.downcase, c] }
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
      @pipeline << Step.new(type:, block:)
      self
    end

    def select_filter_steps
      @pipeline.select { |s| s.type == Step::FILTER }
    end

    def select_transformation_steps
      @pipeline.select { |s| s.type == Step::TRANSFORMATION }
    end

    def transform_to_string
      Step.new(type: Step::TRANSFORMATION, block: ->(i) { i.to_s })
    end
  end
end
