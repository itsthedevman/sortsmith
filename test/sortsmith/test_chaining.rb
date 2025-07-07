# frozen_string_literal: true

require "test_helper"

class TestChaining < Minitest::Test
  def setup
    @complex_data = [
      {name: "Charlie Brown", score: 85, team: "Red"},
      {name: "alice jones", score: 92, team: "Blue"},
      {name: "BOB SMITH", score: 78, team: "Red"},
      {name: "diana prince", score: 95, team: "Blue"}
    ]
  end

  # Test multiple dig calls (equivalent to dig(:a, :b))
  def test_multiple_dig_calls
    input = [
      {user: {profile: {name: "Alice"}}},
      {user: {profile: {name: "Charlie"}}}
    ]

    result = input.sort_by.dig(:user).desc.dig(:profile, :name).to_a
    names = result.map { |i| i.dig(:user, :profile, :name) }

    assert_equal(["Charlie", "Alice"], names)
  end

  # Test complex chaining: dig + case + direction
  def test_complex_chaining
    input = @complex_data.dup

    result = input.sort_by.desc.upcase.dig(:name).to_a
    names = result.map { |i| i[:name] }

    assert_equal(["diana prince", "Charlie Brown", "BOB SMITH", "alice jones"], names)
  end

  # Test chaining with mixed data types
  def test_chaining_with_mixed_types
    input = [
      {value: "apple"},
      {value: 42},
      {value: "Banana"},
      {value: nil}
    ]

    result = input.sort_by.desc.downcase.dig(:value).to_a
    values = result.map { |i| i[:value] }

    assert_equal(["Banana", "apple", 42, nil], values)
  end
end
