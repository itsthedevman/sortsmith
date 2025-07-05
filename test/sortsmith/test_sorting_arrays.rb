# frozen_string_literal: true

require "test_helper"

class TestSortingArrays < Minitest::Test
  def test_it_sorts
    input = ["Delta", "charlie", "Bravo", "alpha"]

    assert_equal(
      ["Bravo", "Delta", "alpha", "charlie"],
      input.sort_by.sort # IDK why you would do this...
    )
  end

  def test_it_sorts_insensitive
    input = ["Delta", "charlie", "Bravo", "alpha"]

    assert_equal(
      ["alpha", "Bravo", "charlie", "Delta"],
      input.sort_by.insensitive.sort
    )
  end

  def test_it_sorts_descending
    input = ["alpha", "Delta", "Bravo", "charlie"]
    result = ["charlie", "alpha", "Delta", "Bravo"]

    assert_equal(result, input.sort_by.desc.sort)
    assert_equal(result, input.sort_by.reverse.sort)
  end

  def test_it_sorts_descending_insensitive
    input = ["alpha", "Delta", "Bravo", "charlie"]
    result = ["Delta", "charlie", "Bravo", "alpha"]

    assert_equal(result, input.sort_by.desc.insensitive.sort)
    assert_equal(result, input.sort_by.insensitive.reverse.sort)
  end
end
