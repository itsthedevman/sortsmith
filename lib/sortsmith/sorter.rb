# frozen_string_literal: true

module Sortsmith
  ##
  # A chainable sorting interface that provides a fluent API for complex sorting operations.
  #
  # The Sorter class allows you to build sorting pipelines by chaining extractors,
  # modifiers, and ordering methods before executing the sort with a terminator method.
  #
  # @example Basic usage
  #   users.sort_by.dig(:name).sort
  #   # => sorted array by name
  #
  # @example Complex chaining
  #   users.sort_by.dig(:name, indifferent: true).downcase.desc.sort
  #   # => sorted by name (case-insensitive, descending, with indifferent key access)
  #
  # @example Mixed key types
  #   mixed_data = [
  #     {name: "Bob"},      # symbol key
  #     {"name" => "Alice"} # string key
  #   ]
  #   mixed_data.sort_by.dig(:name, indifferent: true).sort
  #   # => handles both key types gracefully
  #
  #
  class Sorter
    ##
    # Converts a hash's keys to symbols
    #
    # @param item [Hash] The hash whose keys will be transformed.
    # @return [Hash] A new hash with all keys converted to symbols.
    #
    INDIFFERENT_KEYS_TRANSFORM = ->(item) { item.transform_keys(&:to_sym) }

    ##
    # Initialize a new Sorter instance
    #
    # @param input [Array, Enumerable] The collection to be sorted
    def initialize(input)
      @input = input
      @extractors = []
      @modifiers = []
      @ordering = []
    end

    ############################################################################
    # Extractors
    ############################################################################

    ##
    # Extract values from objects using hash keys or object methods
    #
    # Works with hashes, structs, and any object that responds to the given identifiers.
    # Supports nested digging with multiple arguments.
    #
    # @param identifiers [Array<Symbol, String, Integer>] Keys, method names, or indices to extract
    # @param indifferent [Boolean] When true, normalizes hash keys to symbols for consistent lookup
    #
    # @return [Sorter] Returns self for method chaining
    #
    # @example Hash extraction
    #   users.sort_by.dig(:name).sort
    #
    # @example Nested extraction
    #   users.sort_by.dig(:profile, :email).sort
    #
    # @example Mixed key types
    #   users.sort_by.dig(:name, indifferent: true).sort
    #
    def dig(*identifiers, indifferent: false)
      if indifferent
        identifiers = identifiers.map(&:to_sym)
        before_extract = INDIFFERENT_KEYS_TRANSFORM
      end

      @extractors << {method: :dig, positional: identifiers, before_extract:}
      self
    end

    ##
    # Alias for #dig - extracts values from objects using hash keys or object methods.
    #
    alias_method :key, :dig

    ##
    # Extract values by calling methods on objects
    #
    # Enables chainable sorting by calling methods on each object in the collection.
    # Supports method calls with positional and keyword arguments. Falls back to
    # string conversion for objects that don't respond to the method.
    #
    # @param method_name [Symbol, String] The method name to call on each object
    # @param positional [Array] Positional arguments to pass to the method
    # @param keyword [Hash] Keyword arguments to pass to the method
    #
    # @return [Sorter] Returns self for method chaining
    #
    # @example Basic method sorting
    #   users.sort_by.method(:name).sort
    #
    # @example Method with chainable modifiers
    #   users.sort_by.method(:full_name).insensitive.desc.sort
    #
    # @example Method with arguments
    #   products.sort_by.method(:price_in, "USD").sort
    #
    # @example Method with keyword arguments
    #   items.sort_by.method(:calculate_score, boost: 1.5).sort
    #
    def method(method_name, *positional, **keyword)
      @extractors << {method: method_name, positional:, keyword:}
      self
    end

    ############################################################################
    # Modifiers
    ############################################################################

    ##
    # Transform extracted values to lowercase for comparison
    #
    # Only affects values that respond to #downcase (typically strings).
    # Non-string values pass through unchanged.
    #
    # @return [Sorter] Returns self for method chaining
    #
    # @example Case-insensitive string sorting
    #   names.sort_by.downcase.sort
    #
    # @example With hash extraction
    #   users.sort_by.dig(:name).downcase.sort
    #
    def downcase
      @modifiers << {method: :downcase}
      self
    end

    ##
    # Alias for #downcase - provides case-insensitive sorting
    #
    # @return [Sorter] Returns self for method chaining
    #
    alias_method :insensitive, :downcase

    ##
    # Transform extracted values to uppercase for comparison
    #
    # Only affects values that respond to #upcase (typically strings).
    # Non-string values pass through unchanged.
    #
    # @return [Sorter] Returns self for method chaining
    #
    # @example Uppercase sorting
    #   names.sort_by.upcase.sort
    #
    def upcase
      @modifiers << {method: :upcase}
      self
    end

    ############################################################################
    # Ordering
    ############################################################################

    ##
    # Sort in ascending order (default behavior)
    #
    # This is typically unnecessary as ascending is the default,
    # but can be useful for explicit clarity or resetting after desc.
    #
    # @return [Sorter] Returns self for method chaining
    #
    def asc
      @ordering << {method: :sort!}
      self
    end

    ##
    # Sort in descending order
    #
    # Reverses the final sort order after all comparisons are complete.
    #
    # @return [Sorter] Returns self for method chaining
    #
    # @example Descending sort
    #   users.sort_by.dig(:age).desc.sort
    #
    def desc
      @ordering << {method: :reverse!}
      self
    end

    ############################################################################
    # Terminators
    ############################################################################

    ##
    # Execute the sort pipeline and return a new sorted array
    #
    # Applies all chained extraction, transformation, and ordering steps
    # to produce the final sorted result. The original collection is unchanged.
    #
    # @return [Array] A new array containing the sorted elements
    #
    # @example Basic termination
    #   sorted_users = users.sort_by.dig(:name).sort
    #
    def sort
      # Apply all extraction and transformation steps during comparison
      sorted = @input.sort { |a, b| apply_steps(a, b) }

      # Apply any ordering transformations (like desc)
      apply_ordering_steps(sorted)
    end

    ##
    # Alias for #sort - returns a new sorted array
    #
    # @return [Array] A new array containing the sorted elements
    #
    # @see #sort
    #
    alias_method :to_a, :sort

    ##
    # Execute the sort pipeline and mutate the original array in place
    #
    # Same as #sort but modifies the original array instead of creating a new one.
    # Returns the mutated array for chaining.
    #
    # @return [Array] The original array, now sorted
    #
    # @example In-place sorting
    #   users.sort_by.dig(:name).sort!
    #   # users array is now modified
    #
    def sort!
      # Sort the original array in place
      @input.sort! { |a, b| apply_steps(a, b) }

      # Apply any ordering transformations
      apply_ordering_steps(@input)
    end

    ##
    # Shorthand for adding desc and executing sort
    #
    # Equivalent to calling .desc.sort but more concise.
    #
    # @return [Array] A new array sorted in descending order
    #
    # @example Reverse sorting
    #   users.sort_by.dig(:name).reverse
    #
    def reverse
      desc.sort
    end

    ##
    # Shorthand for adding desc and executing sort!
    #
    # Equivalent to calling .desc.sort! but more concise.
    #
    # @return [Array] The original array, sorted in descending order
    #
    def reverse!
      desc.sort!
    end

    private

    ##
    # Apply the complete pipeline of steps to two items for comparison
    #
    # Iterates through all extraction and transformation steps,
    # applying each one to both items in sequence.
    #
    # @param item_a [Object] First item to compare
    # @param item_b [Object] Second item to compare
    # @return [Integer] Comparison result (-1, 0, 1)
    #
    def apply_steps(item_a, item_b)
      @extractors.each do |step|
        item_a, item_b = apply_step(step, item_a, item_b)
      end

      @modifiers.each do |step|
        item_a, item_b = apply_step(step, item_a, item_b)
      end

      # Final comparison using Ruby's spaceship operator
      item_a <=> item_b
    end

    ##
    # Apply ordering transformations to the sorted array
    #
    # Executes any ordering steps (like desc) that affect the final
    # arrangement of the sorted results.
    #
    # @param sorted [Array] The array to apply ordering to
    # @return [Array] The array with ordering applied
    #
    def apply_ordering_steps(sorted)
      @ordering.each do |step|
        sorted.public_send(step[:method])
      end

      sorted
    end

    ##
    # Apply a single step to both items in the comparison
    #
    # Handles different step types and safely manages method calls,
    # falling back to string conversion for non-responsive objects.
    #
    # @param step [Hash] Step configuration containing method and arguments
    # @param item_a [Object] First item to transform
    # @param item_b [Object] Second item to transform
    # @return [Array<Object, Object>] Transformed items
    #
    def apply_step(step, item_a, item_b)
      item_a = extract_value_from(item_a, **step)
      item_b = extract_value_from(item_b, **step)

      [item_a, item_b]
    end

    ##
    # Extracts a value from an object by invoking a specified method with optional arguments.
    #
    # @param item [Object] The object from which to extract the value.
    # @param method [Symbol, String] The method to call on the object.
    # @param positional [Array] Optional positional arguments to pass to the method.
    # @param keyword [Hash] Optional keyword arguments to pass to the method.
    # @param before_extract [Proc, nil] Optional proc to preprocess the item before extraction.
    # @return [Object, String] The result of the method call, or the string representation
    #                          of the item if the method is not available.
    #
    def extract_value_from(item, method:, positional: [], keyword: {}, before_extract: nil)
      return item.to_s unless item.respond_to?(method)

      item = before_extract.call(item) if before_extract
      item.public_send(method, *positional, **keyword)
    end
  end
end
