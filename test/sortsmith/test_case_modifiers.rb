# frozen_string_literal: true

require "test_helper"

class TestCaseModifiers < Minitest::Test
  def setup
    @mixed_case_strings = ["Cherry", "Apple", "date", "banana"]
    @mixed_case_hashes = [
      {name: "charlie"},
      {name: "Alpha"},
      {name: "delta"},
      {name: "BRAVO"}
    ]
  end

  # Test case insensitive sorting with downcase
  def test_case_insensitive_with_downcase
    input = @mixed_case_strings.dup

    result = input.sort_by.downcase.sort

    assert_equal(["Apple", "banana", "Cherry", "date"], result)
  end

  # Test case insensitive sorting with upcase
  def test_case_insensitive_with_upcase
    input = @mixed_case_strings.dup

    result = input.sort_by.upcase.sort

    assert_equal(["Apple", "banana", "Cherry", "date"], result)
  end

  # Test insensitive alias
  def test_insensitive_alias
    input = @mixed_case_strings.dup

    result = input.sort_by.insensitive.reverse

    assert_equal(["date", "Cherry", "banana", "Apple"], result)
  end

  # Test case modifiers with hash keys
  def test_case_modifiers_with_hashes
    input = @mixed_case_hashes.dup

    result = input.sort_by.dig(:name).insensitive.reverse
    names = result.map { |i| i[:name] }

    assert_equal(["delta", "charlie", "BRAVO", "Alpha"], names)
  end

  # Test case modifiers with non-string values
  def test_case_modifiers_with_numbers
    input = [42, "Apple", nil, "banana"]

    result = input.sort_by.downcase.reverse

    assert_equal(["banana", "Apple", 42, nil], result)
  end
end
