# frozen_string_literal: true

require "test_helper"

class TestImmutability < Minitest::Test
  def setup
    @original = ["charlie", "alpha", "bravo"]
  end

  # Test that building sorter chains doesn't modify steps
  def test_sorter_immutability
    base_sorter = @original.sort_by
    # This should create separate sorters without shared state
  end

  # Test that sort doesn't modify original
  def test_sort_immutability
    input = @original.dup
  end

  # Test multiple sorters from same base
  def test_multiple_sorters_independence
    base = @original.sort_by
    # Test that sorter_a and sorter_b are independent
  end
end
