# frozen_string_literal: true

require "test_helper"

class TestSortingHashes < Minitest::Test
  def setup
    @users = [
      {name: "charlie", age: 25, city: "NYC"},
      {name: "alpha", age: 30, city: "LA"},
      {name: "Bravo", age: 20, city: "Chicago"},
      {name: "Delta", age: 35, city: "NYC"}
    ]
    @mixed_keys = [
      {"name" => "Bob", :age => 25},
      {"name" => "Alice", :age => 30}
    ]
  end

  # Test sorting by symbol keys
  def test_sorting_by_symbol_key
    input = @users.dup
  end

  # Test sorting by string keys
  def test_sorting_by_string_key
    input = @mixed_keys.dup
  end

  # Test sorting by non-existent key (should handle gracefully)
  def test_sorting_by_missing_key
    input = @users.dup
  end

  # Test sorting hashes with mixed key types
  def test_sorting_mixed_key_types
    input = @mixed_keys.dup
  end

  # Test sorting by numeric values
  def test_sorting_by_numeric_values
    input = @users.dup
  end
end
