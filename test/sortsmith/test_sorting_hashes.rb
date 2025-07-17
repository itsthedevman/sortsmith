# frozen_string_literal: true

require "test_helper"

class TestSortingHashes < Minitest::Test
  def setup
    @symbol_key_users = [
      {name: "charlie", age: 25, city: "NYC"},
      {name: "alpha", age: 30, city: "LA"},
      {name: "Bravo", age: 20, city: "Chicago"},
      {name: "Delta", age: 35, city: "NYC"}
    ]

    @string_key_users = [
      {"name" => "Bob", "age" => 25, "city" => "NYC"},
      {"name" => "Alice", "age" => 30, "city" => "LA"}
    ]

    @mixed_key_chaos = [
      {name: "Charlie", age: 25},
      {"name" => "Alice", "age" => 30},
      {:name => "Bob", "age" => 35},
      {"name" => "Diana", :age => 28}
    ]
  end

  # Test basic sorting by symbol keys
  def test_sorting_by_symbol_key
    input = @symbol_key_users.dup

    result = input.sort_by.key(:name).sort
    names = result.map { |u| u[:name] }

    assert_equal(["Bravo", "Delta", "alpha", "charlie"], names)
  end

  # Test basic sorting by string keys
  def test_sorting_by_string_key
    input = @string_key_users.dup

    result = input.sort_by.key("city").sort
    cities = result.map { |u| u["city"] }

    assert_equal(["LA", "NYC"], cities)
  end

  # Test sorting by non-existent key (should handle gracefully)
  def test_sorting_by_missing_key
    input = @symbol_key_users.dup

    result = input.sort_by.dig(:email).sort
    names = result.map { |u| u[:name] }

    # No sort
    assert_equal(["charlie", "alpha", "Bravo", "Delta"], names)
  end

  # Test sorting by numeric hash values
  def test_sorting_by_numeric_values
    input = @symbol_key_users.dup

    result = input.sort_by.dig(:age).sort
    ages = result.map { |u| u[:age] }

    assert_equal([20, 25, 30, 35], ages)
  end

  # Test mixed key types without any helpers
  def test_sorting_mixed_key_types_raw
    input = @mixed_key_chaos.dup

    assert_raises(ArgumentError, "comparison of Hash with Hash failed") do
      input.sort_by.dig(:age).sort
    end
  end

  # Test indifferent_keys modifier - the lazy developer's salvation!
  def test_indifferent_keys_with_mixed_types
    input = @mixed_key_chaos.dup

    result = input.sort_by.dig(:name, indifferent: true).sort
    names = result.map { |item| item[:name] || item["name"] }

    assert_equal(["Alice", "Bob", "Charlie", "Diana"], names)
  end

  # Test indifferent_keys with purely symbol-keyed hashes
  def test_indifferent_keys_with_symbol_hashes
    input = @symbol_key_users.dup

    result = input.sort_by.dig(:age, indifferent: true).sort
    ages = result.map { |u| u[:age] }

    assert_equal([20, 25, 30, 35], ages)
  end

  # Test indifferent_keys with purely string-keyed hashes
  def test_indifferent_keys_with_string_hashes
    input = @string_key_users.dup

    result = input.sort_by.dig(:name, indifferent: true).sort
    names = result.map { |u| u["name"] }

    assert_equal(["Alice", "Bob"], names)
  end
end
