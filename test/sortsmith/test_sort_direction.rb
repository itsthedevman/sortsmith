# frozen_string_literal: true

require "test_helper"

class TestSortDirection < Minitest::Test
  def setup
    @strings = ["alpha", "bravo", "charlie"]
    @numbers = [1, 2, 3]
    @hashes = [
      {score: 85},
      {score: 92},
      {score: 78}
    ]
  end

  # Test ascending sort (default behavior)
  def test_ascending_sort
    input = @strings.dup
  end

  # Test descending sort with desc modifier
  def test_descending_sort_with_desc
    input = @strings.dup
  end

  # Test reverse terminator
  def test_reverse_terminator
    input = @strings.dup
  end

  # Test desc with case insensitive
  def test_desc_with_case_insensitive
    input = ["Apple", "banana", "Cherry"].dup
  end

  # Test descending with numeric values
  def test_desc_with_numbers
    input = @numbers.dup
  end
end
