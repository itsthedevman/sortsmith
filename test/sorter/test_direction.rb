# frozen_string_literal: true

require "test_helper"

class TestSimpleSort < Minitest::Test
  def setup
    input = ["a", "b", "c", "d"].shuffle
    @sorter = Sortsmith::Sorter.new(input)
  end

  def test_it_sorts_asc
    assert_equal(["a", "b", "c", "d"], @sorter.sort)
  end

  def test_it_sorts_desc
    assert_equal(["d", "c", "b", "a"], @sorter.desc.sort)
  end
end
