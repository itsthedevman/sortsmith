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
  end

  # Test number sorting
  def test_basic_number_sorting
    input = @numbers.dup
  end

  # Test empty array handling
  def test_empty_array_sorting
    input = []
  end

  # Test single item array
  def test_single_item_sorting
    input = ["solo"]
  end
end
