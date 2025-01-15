# frozen_string_literal: true

require "test_helper"

class TestSimpleSort < Minitest::Test
  def setup
    input = ["a", "b", "c", "d"].shuffle
    @sorter = Sortsmith::Sorter.new(input)
  end

  def test_it_sorts_asc
    assert_equal(@sorter.sort, ["a", "b", "c", "d"])
  end

  def test_it_sorts_desc
    assert_equal(@sorter.desc.sort, ["d", "c", "b", "a"])
  end
end
