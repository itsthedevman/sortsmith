# frozen_string_literal: true

require "test_helper"

class TestSortingArrays < Minitest::Test
  def test_it_sorts_arrays_alphabetically
    input = ["Delta", "charlie", "Bravo", "alpha"]

    assert_equal(
      ["Bravo", "Delta", "alpha", "charlie"],
      input.sort_by.sort # IDK why you would do this...
    )
  end

  def test_it_sorts_arrays_alphabetically_case_insensitive
    input = ["Delta", "charlie", "Bravo", "alpha"]

    assert_equal(
      ["alpha", "Bravo", "charlie", "Delta"],
      input.sort_by.insensitive.sort
    )
  end
end
