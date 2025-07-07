# frozen_string_literal: true

require "test_helper"

class TestSortingBasics < Minitest::Test
  def setup
    @strings = ["Delta", "charlie", "Bravo", "alpha"]
    @numbers = [42, 1, 99, 15]
    @mixed_case = ["Apple", "banana", "Cherry", "date"]
  end

  # Test basic string sorting without any modifiers
  def test_basic_string_sorting
    input = @strings.dup

    assert_equal(
      ["Bravo", "Delta", "alpha", "charlie"],
      input.sort_by.sort # IDK why you would do this like this
    )
  end

  # Test number sorting
  def test_basic_number_sorting
    input = @numbers.dup

    assert_equal(
      [1, 15, 42, 99],
      input.sort_by.sort
    )
  end

  # Test empty array handling
  def test_empty_array_sorting
    input = []

    assert_equal([], input.sort_by.sort)
  end

  # Test single item array
  def test_single_item_sorting
    input = ["solo"]

    assert_equal(["solo"], input.sort_by.sort)
  end
end
