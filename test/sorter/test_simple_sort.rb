# frozen_string_literal: true

require "test_helper"

class TestSimpleSort < Minitest::Test
  def setup_without_nil
    input = ["a", "b", "c", "d"].shuffle
    @sorter = Sortsmith::Sorter.new(input)
  end

  def setup_with_nil
    input = ["a", nil, "b", nil, "c"].shuffle
    @sorter = Sortsmith::Sorter.new(input)
  end

  def test_it_sorts
    setup_without_nil
    assert_equal(["a", "b", "c", "d"], @sorter.sort)
  end

  def test_it_handles_nil
    setup_with_nil
    assert_equal([nil, nil, "a", "b", "c"], @sorter.sort)
  end
end
