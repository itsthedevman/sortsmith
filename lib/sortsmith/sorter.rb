# frozen_string_literal: true

module Sortsmith
  ##
  # A chainable sorting interface that provides a fluent API for complex sorting operations.
  #
  # The Sorter class allows you to build sorting pipelines by chaining extractors,
  # modifiers, and ordering methods before executing the sort with a terminator method.
  # This creates readable, expressive sorting code that handles edge cases gracefully.
  #
  # @example Basic usage
  #   users.sort_by.dig(:name).sort
  #   # => sorted array by name
  #
  # @example Complex chaining
  #   users.sort_by.dig(:name, indifferent: true).downcase.desc.sort
  #   # => sorted by name (case-insensitive, descending, with indifferent key access)
  #
  # @example Method extraction
  #   users.sort_by.method(:full_name).insensitive.sort
  #   # => sorted by calling full_name method on each user
  #
  # @example Mixed key types
  #   mixed_data = [
  #     {name: "Bob"},      # symbol key
  #     {"name" => "Alice"} # string key
  #   ]
  #   mixed_data.sort_by.dig(:name, indifferent: true).sort
  #   # => handles both key types gracefully
  #
  # @example Handling missing methods gracefully
  #   users.sort_by.method(:missing_email).sort
  #   # => preserves original order when method doesn't exist
  #
  # @see Enumerable#sort_by The enhanced sort_by method
  # @since 0.9.0
  #
  class Sorter
    ##
    # Transformation proc for converting hash keys to symbols for indifferent access.
    #
    # Used internally when the `indifferent: true` option is specified in {#dig}.
    # This enables consistent key lookup across hashes with mixed symbol/string keys.
    #
    # @example Usage in indifferent access
    #   mixed_hashes = [
    #     {name: "Bob"},        # symbol key
    #     {"name" => "Alice"}   # string key
    #   ]
    #   # Both will be accessed via :name after transformation
    #
    # @return [Proc] A proc that transforms hash keys to symbols
    # @api private
    #
    INDIFFERENT_KEYS_TRANSFORM = ->(item) { item.transform_keys(&:to_sym) }

    ##
    # Initialize a new Sorter instance.
    #
    # Creates a new chainable sorter for the given collection. Typically called
    # automatically when using `collection.sort_by` without a block.
    #
    # @param input [Array, Enumerable] The collection to be sorted
    #
    # @example Direct instantiation (rarely needed)
    #   sorter = Sortsmith::Sorter.new(users)
    #   sorter.dig(:name).sort
    #
    # @example Typical usage (via sort_by)
    #   users.sort_by.dig(:name).sort
    #
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
    # Extract values from objects using hash keys or object methods.
    #
    # The workhorse method for value extraction. Works with hashes, structs,
    # and any object that responds to the given identifiers. Supports nested
    # digging with multiple arguments and handles mixed key types gracefully.
    #
    # When extracting from objects that don't respond to the specified keys/methods,
    # returns an empty string to preserve the original ordering rather than causing
    # comparison errors.
    #
    # @param identifiers [Array<Symbol, String, Integer>] Keys, method names, or indices to extract
    # @param indifferent [Boolean] When true, normalizes hash keys to symbols for consistent lookup
    #
    # @return [Sorter] Returns self for method chaining
    #
    # @example Hash key extraction
    #   users.sort_by.dig(:name).sort
    #
    # @example Nested hash extraction
    #   users.sort_by.dig(:profile, :email).sort
    #
    # @example Array index extraction
    #   coordinates.sort_by.dig(0).sort  # sort by x-coordinate
    #
    # @example Mixed key types with indifferent access
    #   mixed_data = [
    #     {name: "Bob"},        # symbol key
    #     {"name" => "Alice"}   # string key
    #   ]
    #   mixed_data.sort_by.dig(:name, indifferent: true).sort
    #   # => Both key types work seamlessly
    #
    # @example Object method calls
    #   users.sort_by.dig(:calculate_score).sort
    #
    # @example Graceful handling of missing keys
    #   users.sort_by.dig(:missing_field).sort
    #   # => Preserves original order instead of erroring
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
    # Alias for {#dig} - extracts values from objects using hash keys or object methods.
    #
    # Provides semantic clarity when working primarily with hash keys rather than
    # nested structures or method calls.
    #
    # @return [Sorter] Returns self for method chaining
    #
    # @example Key extraction
    #   users.sort_by.key(:name).sort
    #
    # @see #dig The main extraction method
    #
    alias_method :key, :dig

    ##
    # Extract values by calling methods on objects with optional arguments.
    #
    # Enables chainable sorting by calling methods on each object in the collection.
    # Supports method calls with both positional and keyword arguments. When objects
    # don't respond to the specified method, returns an empty string to preserve
    # original ordering.
    #
    # This is particularly useful for custom objects, calculated values, or methods
    # that require parameters.
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
    # @example Method with positional arguments
    #   products.sort_by.method(:price_in, "USD").sort
    #
    # @example Method with keyword arguments
    #   items.sort_by.method(:calculate_score, boost: 1.5).sort
    #
    # @example Complex method calls
    #   reports.sort_by.method(:metric_for, :revenue, period: "Q1").desc.sort
    #
    # @example Graceful handling of missing methods
    #   mixed_objects.sort_by.method(:priority).sort
    #   # => Objects without :priority method maintain original order
    #
    def method(method_name, *positional, **keyword)
      @extractors << {method: method_name, positional:, keyword:}
      self
    end

    ############################################################################
    # Modifiers
    ############################################################################

    ##
    # Transform extracted values to lowercase for comparison.
    #
    # Only affects values that respond to #downcase (typically strings).
    # Non-string values are converted to strings first, ensuring consistent
    # behavior across mixed data types.
    #
    # @return [Sorter] Returns self for method chaining
    #
    # @example Case-insensitive string sorting
    #   names = ["charlie", "Alice", "BOB"]
    #   names.sort_by.downcase.sort
    #   # => ["Alice", "BOB", "charlie"]
    #
    # @example With hash extraction
    #   users.sort_by.dig(:name).downcase.sort
    #
    # @example Mixed data types
    #   mixed = ["Apple", 42, "banana"]
    #   mixed.sort_by.downcase.sort
    #   # => [42, "Apple", "banana"] (42 becomes "42")
    #
    def downcase
      @modifiers << {method: :downcase}
      self
    end

    ##
    # Alias for {#downcase} - provides case-insensitive sorting.
    #
    # Offers semantic clarity when the intent is case-insensitive comparison
    # rather than specifically forcing lowercase.
    #
    # @return [Sorter] Returns self for method chaining
    #
    # @example Semantic case-insensitive sorting
    #   users.sort_by.dig(:name).insensitive.sort
    #
    # @see #downcase The underlying transformation method
    #
    alias_method :insensitive, :downcase

    ##
    # Transform extracted values to uppercase for comparison.
    #
    # Only affects values that respond to #upcase (typically strings).
    # Non-string values are converted to strings first, ensuring consistent
    # behavior across mixed data types.
    #
    # @return [Sorter] Returns self for method chaining
    #
    # @example Uppercase sorting
    #   names.sort_by.upcase.sort
    #
    # @example With extraction
    #   users.sort_by.dig(:department).upcase.desc.sort
    #
    def upcase
      @modifiers << {method: :upcase}
      self
    end

    ############################################################################
    # Ordering
    ############################################################################

    ##
    # Sort in ascending order (default behavior).
    #
    # This is typically unnecessary as ascending is the default sort direction,
    # but can be useful for explicit clarity or resetting direction after
    # previous desc calls in a chain.
    #
    # @return [Sorter] Returns self for method chaining
    #
    # @example Explicit ascending sort
    #   users.sort_by.dig(:name).asc.sort
    #
    # @example Resetting after desc
    #   users.sort_by.dig(:name).desc.asc.sort  # ends up ascending
    #
    def asc
      @ordering << {method: :sort!}
      self
    end

    ##
    # Sort in descending order.
    #
    # Reverses the final sort order after all comparisons are complete.
    # Can be chained with other modifiers and will apply to the final result.
    #
    # @return [Sorter] Returns self for method chaining
    #
    # @example Descending sort
    #   users.sort_by.dig(:age).desc.sort
    #   # => Oldest users first
    #
    # @example With case modification
    #   users.sort_by.dig(:name).insensitive.desc.sort
    #   # => Case-insensitive, reverse alphabetical
    #
    def desc
      @ordering << {method: :reverse!}
      self
    end

    ############################################################################
    # Terminators
    ############################################################################

    ##
    # Execute the sort pipeline and return a new sorted array.
    #
    # Applies all chained extraction, transformation, and ordering steps
    # to produce the final sorted result. The original collection remains
    # unchanged.
    #
    # @return [Array] A new array containing the sorted elements
    #
    # @example Basic termination
    #   sorted_users = users.sort_by.dig(:name).sort
    #   # original users array unchanged
    #
    # @example Complex pipeline
    #   result = users.sort_by.dig(:name, indifferent: true).insensitive.desc.sort
    #
    def sort
      # Apply all extraction and transformation steps during comparison
      sorted = @input.sort { |a, b| apply_sorting(a, b) }

      # Apply any ordering transformations (like desc)
      apply_ordering(sorted)
    end

    ##
    # Alias for {#sort} - returns a new sorted array.
    #
    # Provides semantic clarity when the intent is to convert the sorter
    # pipeline to an array result.
    #
    # @return [Array] A new array containing the sorted elements
    #
    # @example Array conversion
    #   result = users.sort_by.dig(:name).to_a
    #
    # @see #sort The main termination method
    #
    alias_method :to_a, :sort

    ##
    # Execute the sort pipeline and mutate the original array in place.
    #
    # Same as {#sort} but modifies the original array instead of creating a new one.
    # Returns the mutated array for chaining. Use when memory efficiency is
    # important and you don't need to preserve the original order.
    #
    # @return [Array] The original array, now sorted
    #
    # @example In-place sorting
    #   users.sort_by.dig(:name).sort!
    #   # users array is now modified
    #
    # @example Chaining after mutation
    #   result = users.sort_by.dig(:name).sort!.first(10)
    #
    def sort!
      # Sort the original array in place
      @input.sort! { |a, b| apply_sorting(a, b) }

      # Apply any ordering transformations
      apply_ordering(@input)
    end

    ##
    # Shorthand for adding desc and executing sort.
    #
    # Equivalent to calling `.desc.sort` but more concise and expressive.
    # Useful when you know you want descending order and don't need other
    # modifiers.
    #
    # @return [Array] A new array sorted in descending order
    #
    # @example Reverse sorting
    #   users.sort_by.dig(:created_at).reverse
    #   # => Newest users first
    #
    # @example Equivalent to
    #   users.sort_by.dig(:created_at).desc.sort
    #
    def reverse
      desc.sort
    end

    ##
    # Shorthand for adding desc and executing sort!.
    #
    # Equivalent to calling `.desc.sort!` but more concise. Mutates the
    # original array and returns it in descending order.
    #
    # @return [Array] The original array, sorted in descending order
    #
    # @example In-place reverse sorting
    #   users.sort_by.dig(:score).reverse!
    #
    def reverse!
      desc.sort!
    end

    private

    ##
    # Apply the complete pipeline of steps to two items for comparison.
    #
    # Iterates through all extraction and transformation steps in order,
    # applying each one to both items in sequence. This creates the values
    # that will be compared using Ruby's spaceship operator.
    #
    # @param item_a [Object] First item to compare
    # @param item_b [Object] Second item to compare
    # @return [Integer] Comparison result (-1, 0, 1)
    #
    # @api private
    #
    def apply_sorting(item_a, item_b)
      @extractors.each do |extractor|
        item_a, item_b = apply_extractor(extractor, item_a, item_b)
      end

      @modifiers.each do |modifier|
        item_a, item_b = apply_modifier(modifier, item_a, item_b)
      end

      # Final comparison using Ruby's spaceship operator
      item_a <=> item_b
    end

    ##
    # Apply ordering transformations to the sorted array.
    #
    # Executes any ordering steps (like desc) that affect the final
    # arrangement of the sorted results. This happens after the sort
    # comparison is complete.
    #
    # @param sorted [Array] The array to apply ordering to
    # @return [Array] The array with ordering applied
    #
    # @api private
    #
    def apply_ordering(sorted)
      @ordering.each { |step| sorted.public_send(step[:method]) }

      sorted
    end

    ##
    # Apply an extraction step to both comparison items.
    #
    # Extraction steps pull values out of objects (like hash keys or method calls)
    # that will be used for comparison. When extraction fails, returns empty
    # strings to preserve original ordering.
    #
    # @param extractor [Hash] Extraction step configuration
    # @param item_a [Object] First item to extract from
    # @param item_b [Object] Second item to extract from
    # @return [Array<Object, Object>] Extracted values for comparison
    #
    # @api private
    #
    def apply_extractor(extractor, item_a, item_b)
      item_a = extract_value(item_a, **extractor)
      item_b = extract_value(item_b, **extractor)

      [item_a, item_b]
    end

    ##
    # Extract a value from an object by invoking a specified method.
    #
    # Handles extraction with optional arguments and preprocessing. When the
    # object doesn't respond to the method, returns an empty string to maintain
    # original ordering rather than causing comparison failures.
    #
    # @param item [Object] The object from which to extract the value
    # @param method [Symbol, String] The method to call on the object
    # @param positional [Array] Optional positional arguments to pass to the method
    # @param keyword [Hash] Optional keyword arguments to pass to the method
    # @param before_extract [Proc, nil] Optional proc to preprocess the item before extraction
    # @return [Object, String] The result of the method call, or empty string if method unavailable
    #
    # @api private
    #
    def extract_value(item, method:, positional: [], keyword: {}, before_extract: nil)
      return "" unless item.respond_to?(method)

      item = before_extract.call(item) if before_extract
      item.public_send(method, *positional, **keyword)
    end

    ##
    # Apply a modification step to both comparison items.
    #
    # Modification steps transform values for comparison (like case changes).
    # Both items are processed with the same transformation to ensure
    # consistent comparison behavior.
    #
    # @param modifier [Hash] Modification step configuration
    # @param item_a [Object] First item to modify
    # @param item_b [Object] Second item to modify
    # @return [Array<Object, Object>] Modified values for comparison
    #
    # @api private
    #
    def apply_modifier(modifier, item_a, item_b)
      item_a = modify_value(item_a, **modifier)
      item_b = modify_value(item_b, **modifier)

      [item_a, item_b]
    end

    ##
    # Modify a value using a specified transformation method.
    #
    # Applies transformations like case changes to values. When the value
    # doesn't respond to the transformation method, converts it to a string
    # first to enable string operations on non-string types.
    #
    # @param item [Object] The value to modify
    # @param method [Symbol, String] The transformation method to apply
    # @param positional [Array] Optional positional arguments
    # @param keyword [Hash] Optional keyword arguments
    # @return [Object] The transformed value
    #
    # @api private
    #
    def modify_value(item, method:, positional: [], keyword: {})
      return item.to_s unless item.respond_to?(method)

      item.public_send(method, *positional, **keyword)
    end
  end
end
