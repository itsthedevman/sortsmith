# frozen_string_literal: true

module Sortsmith
  #
  # The Sorter class provides a flexible, chainable API for sorting Ruby collections.
  # It supports sorting by keys, methods, case sensitivity, and custom transformations.
  #
  # The sorting process works by building a pipeline of steps that are applied
  # when comparing elements. These steps can be either filters (extracting data)
  # or transformations (modifying data for comparison).
  #
  # @example Sort an array of strings
  #   Sortsmith::Sorter.new(["Bob", "Alice", "Carol"]).sort
  #   # => ["Alice", "Bob", "Carol"]
  #
  # @example Sort hashes by key
  #   users = [{ name: "Bob", age: 30 }, { name: "Alice", age: 25 }]
  #   Sortsmith::Sorter.new(users).by_key(:name).sort
  #   # => [{ name: "Alice", age: 25 }, { name: "Bob", age: 30 }]
  #
  # @example Sort objects by method with case insensitivity
  #   User = Struct.new(:name)
  #   users = [User.new("bob"), User.new("Alice")]
  #   Sortsmith::Sorter.new(users).by_method(:name).case_insensitive.sort
  #   # => [User.new("Alice"), User.new("bob")]
  #
  class Sorter
    #
    # Creates a new Sorter builder instance
    #
    # @param enumerable [Enumerable] The enumerable (Array, Hash) to sort
    #
    # @return [Sorter] A new Sorter instance
    #
    # @example
    #   Sortsmith::Sorter.new(["c", "a", "b"])
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
    # @example Simple sort
    #   Sortsmith::Sorter.new(["c", "b", "a"]).sort
    #   # => ["a", "b", "c"]
    #
    # @example Complex sort
    #   Sortsmith::Sorter.new([{name: "Bob"}, {name: "Alice"}])
    #     .by_key(:name)
    #     .sort
    #   # => [{name: "Alice"}, {name: "Bob"}]
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
    # @yield [item] Block that extracts data from the item being sorted
    # @yieldparam item [Object] The item being processed
    # @yieldreturn [Object] The extracted data to be used for comparison
    #
    # @return [Sorter] The sorter instance for method chaining
    #
    # @example
    #   Sortsmith::Sorter.new(users).add_filter { |user| user.name.downcase }
    #
    def add_filter(&)
      add_step(type: Step::FILTER, &)
    end

    #
    # Adds a "transformation" step to the sort pipeline
    # Transformation steps are used to transform data.
    # These are performed after filter steps
    #
    # @yield [item] Block that transforms the data for comparison
    # @yieldparam item [Object] The data to transform
    # @yieldreturn [Object] The transformed data to be used for comparison
    #
    # @return [Sorter] The sorter instance for method chaining
    #
    # @example
    #   Sortsmith::Sorter.new(users).add_transformation { |str| str.downcase }
    #
    def add_transformation(&)
      add_step(type: Step::TRANSFORMATION, &)
    end

    #
    # Instructs the sorter to perform a fetch by key on the Hash being sorted
    #
    # @param key [String, Symbol, Any] The hash key to fetch
    #
    # @return [Sorter] The sorter instance for method chaining
    #
    # @example
    #   users = [{ name: "Bob" }, { name: "Alice" }]
    #   Sortsmith::Sorter.new(users).by_key(:name).sort
    #   # => [{ name: "Alice" }, { name: "Bob" }]
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
    # @return [Sorter] The sorter instance for method chaining
    #
    # @example
    #   User = Struct.new(:name)
    #   users = [User.new("Bob"), User.new("Alice")]
    #   Sortsmith::Sorter.new(users).by_method(:name).sort
    #   # => [User.new("Alice"), User.new("Bob")]
    #
    def by_method(method)
      add_filter { |i| i&.public_send(method) }
    end

    alias_method :by_attribute, :by_method

    #
    # Instructs the sorter to sort by a case insensitive value
    # This will prioritize capital letters first, followed by their lowercase counterparts
    #
    # @return [Sorter] The sorter instance for method chaining
    #
    # @example
    #   Sortsmith::Sorter.new(["ab", "Ab", "BA", "ba"]).case_insensitive.sort
    #   # => ["Ab", "ab", "BA", "ba"]
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
    # Controls which direction the array will be sorted (ascending)
    #
    # @return [Sorter] The sorter instance for method chaining
    #
    # @example
    #   Sortsmith::Sorter.new([3, 1, 2]).asc.sort
    #   # => [1, 2, 3]
    #
    def asc
      @direction = :asc
      self
    end

    alias_method :forward, :asc

    #
    # Controls which direction the array will be sorted (descending)
    #
    # @return [Sorter] The sorter instance for method chaining
    #
    # @example
    #   Sortsmith::Sorter.new([3, 1, 2]).desc.sort
    #   # => [3, 2, 1]
    #
    def desc
      @direction = :desc
      self
    end

    alias_method :reverse, :desc

    private

    #
    # Adds a step to the pipeline
    #
    # @param type [Symbol] The type of step (filter or transformation)
    # @yield [item] The block to execute for this step
    #
    # @return [Sorter] The sorter instance
    #
    # @api private
    #
    def add_step(type:, &block)
      @pipeline << Step.new(type:, block:)
      self
    end

    #
    # Returns all filter steps from the pipeline
    #
    # @return [Array<Step>] Array of filter steps
    #
    # @api private
    #
    def select_filter_steps
      @pipeline.select { |s| s.type == Step::FILTER }
    end

    #
    # Returns all transformation steps from the pipeline
    #
    # @return [Array<Step>] Array of transformation steps
    #
    # @api private
    #
    def select_transformation_steps
      @pipeline.select { |s| s.type == Step::TRANSFORMATION }
    end

    #
    # Determines the priority of a value based on its type
    # Used for sorting different types of objects
    #
    # @param value [Object] The value to check
    #
    # @return [Integer] The priority value (lower = higher priority)
    #
    # @api private
    #
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

    #
    # Applies all transformation steps to a value
    #
    # @param steps [Array<Step>] The transformation steps to apply
    # @param value [Object] The value to transform
    #
    # @return [Object] The transformed value
    #
    # @api private
    #
    def apply_transformations(steps, value)
      result = value

      steps.each do |step|
        result = step.perform(result)
      end

      result
    end
  end
end
