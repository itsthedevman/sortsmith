# frozen_string_literal: true

require "test_helper"

class TestSortDirection < Minitest::Test
  def setup
    @strings = ["bravo", "alpha", "charlie"]
    @numbers = [2, 1, 3]
  end

  # Test ascending sort (default behavior)
  def test_ascending_sort
    input = @strings.dup

    result = input.sort_by.sort

    assert_equal(["alpha", "bravo", "charlie"], result)
  end

  # Test ascending sort (explicit behavior)
  def test_ascending_sort_explicit
    input = @strings.dup

    result = input.sort_by.asc.sort

    assert_equal(["alpha", "bravo", "charlie"], result)
  end

  # Test descending sort with desc modifier
  def test_descending_sort_with_desc
    input = @strings.dup

    result = input.sort_by.desc.sort

    assert_equal(["charlie", "bravo", "alpha"], result)
  end

  # Test desc with case insensitive
  def test_desc_with_case_insensitive
    input = ["Apple", "banana", "Cherry"].dup

    result = input.sort_by.desc.insensitive.sort

    assert_equal(["Cherry", "banana", "Apple"], result)
  end

  # Test descending with numeric values
  def test_desc_with_numbers
    input = @numbers.dup

    result = input.sort_by.reverse

    assert_equal([3, 2, 1], result)
  end
end
