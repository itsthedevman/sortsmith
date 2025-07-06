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
    nested = [
      {user: {profile: {name: "Charlie"}}},
      {user: {profile: {name: "Alice"}}}
    ]
  end

  # Test complex chaining: dig + case + direction
  def test_complex_chaining
    input = @complex_data.dup
  end

  # Test chaining with mixed data types
  def test_chaining_with_mixed_types
    mixed = [
      {value: "apple"},
      {value: 42},
      {value: "Banana"},
      {value: nil}
    ]
  end
end
