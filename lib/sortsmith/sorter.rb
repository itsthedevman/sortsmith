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
  class Sorter
    ##
    # Initialize a new Sorter instance
    #
    # @param input [Array, Enumerable] The collection to be sorted
    def initialize(input)
      @input = input
      @steps = []           # Pipeline of extraction and transformation steps
      @ordering_steps = []  # Pipeline of ordering operations (desc, asc)
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
    # @example Object method calls
    #   objects.sort_by.dig(:calculate_score).sort
    #
    def dig(*identifiers, indifferent: false)
      @steps << {method: :dig, positional: identifiers, indifferent:}
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
      @steps << {method: :downcase}
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
      @steps << {method: :upcase}
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
      @ordering_steps << {method: :sort!}
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
      @ordering_steps << {method: :reverse!}
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
      sorted = @input.sort do |item_a, item_b|
        apply_steps(item_a, item_b)
      end

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
      @input.sort! do |item_a, item_b|
        apply_steps(item_a, item_b)
      end

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
      @steps.each do |step|
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
      @ordering_steps.each do |step|
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
      method = step[:method]
      positional = step[:positional] || []
      indifferent = step[:indifferent] || false

      # For indifferent key access, normalize all positional args to symbols
      if indifferent
        positional = positional.map { |i| i.respond_to?(:to_sym) ? i.to_sym : i }
      end

      item_a = extract_value_from(item_a, method, positional, indifferent)
      item_b = extract_value_from(item_b, method, positional, indifferent)

      [item_a, item_b]
    end

    ##
    # Extracts a value from an object using the specified method and parameters.
    #
    # @param item [Object] the object to extract a value from
    # @param method [Symbol, String] the method name to call on the object
    # @param positional [Array] positional arguments to pass to the method
    # @param indifferent [Boolean] whether to normalize hash keys to symbols for indifferent access
    #
    # @return [Object] the extracted value, or the string representation of the item
    #
    def extract_value_from(item, method, positional, indifferent)
      return item.to_s unless item.respond_to?(method)

      # For hash objects with indifferent access, normalize keys to symbols
      item = item.transform_keys(&:to_sym) if indifferent

      item.public_send(method, *positional)
    end
  end
end
