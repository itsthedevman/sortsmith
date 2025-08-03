# frozen_string_literal: true

##
# Extensions to Ruby's built-in Enumerable module.
#
# Sortsmith extends {Enumerable} to provide enhanced sorting capabilities
# while preserving the original behavior when used with blocks.
#
# The key enhancement is allowing `sort_by` to be called without a block,
# which returns a {Sortsmith::Sorter} instance for method chaining.
#
# @example Original behavior (unchanged)
#   [1, 2, 3].sort_by { |n| -n }
#   # => [3, 2, 1]
#
# @example New chainable behavior
#   users.sort_by.dig(:name).downcase.sort
#   # => Returns Sorter instance for chaining
#
# @see Sortsmith::Sorter The chainable sorting interface
#
module Enumerable
  ##
  # Stores the original sort_by method before extension.
  #
  # This alias preserves Ruby's original `sort_by` behavior, allowing
  # Sortsmith to enhance the method while maintaining full backward
  # compatibility when blocks are provided.
  #
  # @see #sort_by The enhanced version
  # @api private
  #
  alias_method :og_sort_by, :sort_by

  ##
  # Enhanced sort_by that supports both traditional block usage and direct field extraction.
  #
  # This method extends Ruby's built-in `sort_by` to provide a fluent, chainable API
  # for sorting operations. When called with a block, it behaves exactly like the
  # original `sort_by`. When called without a block, it returns a {Sortsmith::Sorter}
  # instance for method chaining.
  #
  # The direct syntax (`sort_by(field)`) provides a concise way to sort by a specific
  # field or method without verbose chaining, making simple sorting operations more
  # readable and intuitive.
  #
  # @param field [Symbol, String, nil] Optional field name for direct extraction
  # @param block [Proc, nil] Optional block for traditional sort_by behavior
  #
  # @return [Array, Sortsmith::Sorter] Array when block given, Sorter instance otherwise
  #
  # @example Traditional block usage (unchanged)
  #   users.sort_by { |user| user.name.downcase }
  #   # => sorted array
  #
  # @example Direct field syntax (new)
  #   users.sort_by(:name).insensitive.sort
  #   # => sorted array via method chaining
  #
  # @example Direct syntax with immediate result
  #   users.sort_by(:score).desc.first(3)
  #   # => top 3 users by score
  #
  # @example Chainable interface without field
  #   users.sort_by.dig(:profile, :email).sort
  #   # => sorted by nested email field
  #
  # @example Mixed key types
  #   mixed_data = [
  #     { name: "Bob" },        # symbol key
  #     { "name" => "Alice" }   # string key
  #   ]
  #   mixed_data.sort_by(:name, indifferent: true).sort
  #   # => handles both key types gracefully
  #
  # @example Object method sorting
  #   products.sort_by(:calculate_price).desc.sort
  #   # => sorted by calculated price method
  #
  # @example Dynamic field selection
  #   sort_field = params[:sort_by]  # might be nil
  #   users.sort_by(sort_field).sort
  #   # => gracefully handles nil field
  #
  # @example Integration with enumerable methods
  #   users.sort_by(:created_at).desc.take(10)
  #   # => newest 10 users without breaking the chain
  #
  # @raise [ArgumentError] When extraction results in incomparable types
  #
  # @note This method maintains full backward compatibility with Ruby's original sort_by
  # @note When field is nil, returns a plain Sorter instance for manual chaining
  #
  # @see Sortsmith::Sorter The chainable sorting interface
  # @see #extract Universal extraction method
  # @see Enumerable#sort_by Original Ruby method (aliased as og_sort_by)
  # @since 1.0.0
  #
  def sort_by(field = nil, *, **, &block)
    return og_sort_by(&block) if block

    sorter = Sortsmith::Sorter.new(self)
    return sorter if field.nil?

    sorter.extract(field, *, **)
  end
end
