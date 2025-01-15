# frozen_string_literal: true

require "test_helper"

class TestSimpleSort < Minitest::Test
  def setup_without_case
    input = ["a", "b", "c", "d"].shuffle
    @sorter = Sortsmith::Sorter.new(input)
  end

  def setup_with_case
    input = ["a", "A", "b", "c", "C", "d", "E"].shuffle
    @sorter = Sortsmith::Sorter.new(input)
  end

  def setup_with_nil
    input = ["a", nil, "b", nil, "c"].shuffle
    @sorter = Sortsmith::Sorter.new(input)
  end

  def test_it_sorts
    setup_without_case
    assert_equal(@sorter.sort, ["a", "b", "c", "d"])
  end

  # When we sort insensitively, it will prioritize capital letters first,
  # followed by their lowercase counterparts
  def test_it_sorts_case_insensitively
    setup_with_case
    assert_equal(@sorter.case_insensitive.sort, ["A", "a", "b", "C", "c", "d", "E"])
  end

  def test_it_handles_nil
    setup_with_nil
    assert_equal(@sorter.sort, [nil, nil, "a", "b", "c"])
  end
end
