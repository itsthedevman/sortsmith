# frozen_string_literal: true

require_relative "sortsmith/sorter"
require_relative "sortsmith/step"
require_relative "sortsmith/version"

#
# Sortsmith provides a flexible, chainable API for sorting Ruby collections
# with support for custom transformations, filtering by keys or methods,
# and case-insensitive comparisons.
#
# @example Basic array sorting
#   users = ["Bob", "Alice", "Carol"]
#   sorted_users = Sortsmith::Sorter.new(users).sort
#   # => ["Alice", "Bob", "Carol"]
#
# @example Sorting objects by method
#   users = [User.new(name: "Bob"), User.new(name: "Alice")]
#   sorted_users = Sortsmith::Sorter.new(users).by_method(:name).sort
#
# @example Case-insensitive hash sorting
#   users = [{ name: "bob" }, { name: "Alice" }]
#   sorted_users = Sortsmith::Sorter.new(users)
#     .by_key(:name)
#     .case_insensitive
#     .sort
#
module Sortsmith
  #
  # Custom error class for Sortsmith-specific exceptions
  #
  # @example Raising a Sortsmith error
  #   raise Sortsmith::Error, "Something went wrong with the sorting operation"
  #
  class Error < StandardError; end
end
