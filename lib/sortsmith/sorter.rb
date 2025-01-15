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
      transformation_steps = select_transformation_steps

      result =
        @enumerable.sort do |left, right|
          filter_steps.each do |step|
            left = step.perform(left)
            right = step.perform(right)
          end

          left_priority = type_priority(left)
          right_priority = type_priority(right)

          # Apply the transformation pipeline only for same-type comparisons
          if left_priority == right_priority
            left = apply_transformations(transformation_steps, left)
            right = apply_transformations(transformation_steps, right)

            left <=> right
          else
            left_priority <=> right_priority
          end
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
        case item
        when String
          item.chars.flat_map { |c| [c.downcase, c] }
        else
          item
        end
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

    def type_priority(value)
      case value
      when NilClass then 0
      when Numeric then 1
      when String then 2
      when Array then 3
      when Hash then 4
      else
        5
      end
    end

    def apply_transformations(steps, value)
      result = value

      steps.each do |step|
        result = step.perform(result)
      end

      result
    end
  end
end
