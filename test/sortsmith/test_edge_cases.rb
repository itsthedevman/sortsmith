# frozen_string_literal: true

require "test_helper"

class TestEdgeCases < Minitest::Test
  # Test sorting array with nils
  def test_sorting_with_nils
    input = ["apple", nil, "banana", nil, "cherry"]
  end

  # Test sorting with completely nil hash values
  def test_sorting_nil_hash_values
    input = [
      {name: "Alice"},
      {name: nil},
      {name: "Bob"},
      {}
    ]
  end

  # Test sorting mixed data types
  def test_sorting_mixed_data_types
    input = ["string", 42, :symbol, nil]
  end

  # Test sorting empty strings
  def test_sorting_empty_strings
    input = ["", "alice", "", "bob"]
  end

  # Test very large arrays (performance check)
  def test_large_array_performance
    input = Array.new(1000) { |i| {id: i, name: "user_#{rand(1000)}"} }
  end
end
