# frozen_string_literal: true

require "test_helper"

class TestNonStringTypes < Minitest::Test
  def setup
    input = ["Ab", "aa", 1, 2, 3.0, [], {}, nil].shuffle

    @sorter = Sortsmith::Sorter.new(input)
  end

  def test_it_sorts
    assert_equal(
      [nil, 1, 2, 3.0, "Ab", "aa", [], {}],
      @sorter.sort
    )
  end

  def test_it_sorts_with_insensitive
    assert_equal(
      [nil, 1, 2, 3.0, "Ab", "aa", [], {}],
      @sorter.case_insensitive.sort
    )
  end
end
