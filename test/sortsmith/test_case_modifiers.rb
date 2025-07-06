# frozen_string_literal: true

require "test_helper"

class TestCaseModifiers < Minitest::Test
  def setup
    @mixed_case_strings = ["Apple", "banana", "Cherry", "date"]
    @mixed_case_hashes = [
      {name: "charlie"},
      {name: "Alpha"},
      {name: "BRAVO"},
      {name: "delta"}
    ]
  end

  # Test case insensitive sorting with downcase
  def test_case_insensitive_with_downcase
    input = @mixed_case_strings.dup
  end

  # Test case insensitive sorting with upcase
  def test_case_insensitive_with_upcase
    input = @mixed_case_strings.dup
  end

  # Test insensitive alias
  def test_insensitive_alias
    input = @mixed_case_strings.dup
  end

  # Test case modifiers with hash keys
  def test_case_modifiers_with_hashes
    input = @mixed_case_hashes.dup
  end

  # Test case modifiers with non-string values
  def test_case_modifiers_with_numbers
    input = [42, "Apple", nil, "banana"]
  end
end
