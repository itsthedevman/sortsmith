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
  # Enhanced sort_by that supports both traditional block usage and chainable API.
  #
  # When called with a block, behaves exactly like Ruby's original `sort_by`.
  # When called without a block, returns a {Sortsmith::Sorter} instance that
  # provides a chainable interface for complex sorting operations.
  #
  # This dual behavior ensures complete backward compatibility while unlocking
  # powerful new sorting capabilities.
  #
  # @param block [Proc, nil] Optional block for traditional sort_by behavior
  # @return [Array, Sortsmith::Sorter] Array when block given, Sorter when block nil
  #
  # @example Traditional usage (unchanged)
  #   users.sort_by { |user| user.name.downcase }
  #   # => sorted array
  #
  # @example Chainable usage (new)
  #   users.sort_by.dig(:name).downcase.desc.sort
  #   # => sorted array via method chaining
  #
  # @example Mixed key types with indifferent access
  #   mixed_data = [
  #     { name: "Bob" },        # symbol key
  #     { "name" => "Alice" }   # string key
  #   ]
  #   mixed_data.sort_by.dig(:name, indifferent: true).sort
  #   # => handles both key types gracefully
  #
  # @see Sortsmith::Sorter#dig
  # @see Sortsmith::Sorter#sort
  # @see #og_sort_by Original sort_by behavior
  #
  # @since 0.1.0
  #
  def sort_by(&block)
    return Sortsmith::Sorter.new(self) if block.nil?

    og_sort_by(&block)
  end
end
