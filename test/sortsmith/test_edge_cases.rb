# frozen_string_literal: true

require "test_helper"

class TestEdgeCases < Minitest::Test
  # Test sorting with completely nil hash values
  def test_sorting_nil_hash_values
    input = [
      {name: "Alice"},
      {name: nil},
      {name: "Bob"},
      {}
    ]

    # nil_last is default, and is independent of asc/desc
    # With desc: Charlie, Bob, Alice, nil, nil (values descending, nils still last)
    result = input.sort_by.dig(:name).reverse
    names = result.map { |i| i[:name] }

    # Non-nil values in descending order, then nils (nil_last is independent of desc)
    assert_equal("Bob", names[0])
    assert_equal("Alice", names[1])
    assert_nil(names[2])
    assert_nil(names[3])
  end

  # Test sorting mixed data types
  def test_sorting_mixed_data_types
    input = ["string", 42, :symbol, nil]

    assert_raises(ArgumentError, "comparison of String with 42 failed") do
      input.sort_by.reverse
    end
  end

  # Test sorting empty strings
  def test_sorting_empty_strings
    input = ["", "alice", "", "bob"]

    result = input.sort_by.to_a

    assert_equal(["", "", "alice", "bob"], result)
  end

  # Test very large arrays (performance check)
  def test_large_array_performance
    input = Array.new(10_000) { |i| {id: i, name: "user_#{rand(10_000)}"} }.shuffle

    result = input.sort_by.dig(:id).to_a
    ids = result.map { |i| i[:id] }

    assert_equal(0, ids.first)
    assert_equal(9999, ids.last)
  end
end
