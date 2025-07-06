# frozen_string_literal: true

require_relative "sortsmith/version"
require_relative "sortsmith/core_ext/enumerable"
require_relative "sortsmith/sorter"

##
# Sortsmith provides a flexible, chainable API for sorting Ruby collections.
#
# The gem extends Ruby's built-in {Enumerable} module to provide an intuitive
# sorting interface that reads like natural language and supports complex
# sorting operations through method chaining.
#
# @example Basic usage
#   users = ["Charlie", "alice", "Bob"]
#   users.sort_by.downcase.sort
#   # => ["alice", "Bob", "Charlie"]
#
# @example Hash sorting
#   users = [
#     { name: "Charlie", age: 25 },
#     { name: "alice", age: 30 },
#     { name: "Bob", age: 20 }
#   ]
#   users.sort_by.dig(:name).insensitive.sort
#   # => sorted by name, case-insensitive
#
# @example Complex chaining
#   users.sort_by.dig(:name, indifferent: true).downcase.desc.sort
#   # => Extract name (works with both string/symbol keys), downcase, descending
#
# @see Sortsmith::Sorter The main sorting interface
# @see Enumerable#sort_by The extended sort_by method
#
# @author Bryan "itsthedevman"
# @since 0.1.0
#
module Sortsmith
  ##
  # Base error class for all Sortsmith-related exceptions.
  #
  # This provides a namespace for any custom errors that may be raised
  # during sorting operations, making it easier to rescue Sortsmith-specific
  # issues without catching unrelated StandardError instances.
  #
  # @example Rescuing Sortsmith errors
  #   begin
  #     complex_sort_operation
  #   rescue Sortsmith::Error => e
  #     handle_sorting_error(e)
  #   end
  #
  # @since 0.1.0
  #
  class Error < StandardError; end
end
