# frozen_string_literal: true

require "test_helper"

class TestSortingArray < Minitest::Test
  def setup
    @input_strings = ["Delta", "charlie", "Bravo", "alpha"]
    @input_hashes = [
      {name: "charlie", age: 25, city: "NYC"},
      {name: "alpha", age: 30, city: "LA"},
      {name: "Bravo", age: 20, city: "Chicago"},
      {name: "Delta", age: 35, city: "NYC"}
    ]
  end

  def test_it_sorts
    input = @input_strings.shuffle

    assert_equal(
      ["Bravo", "Delta", "alpha", "charlie"],
      input.sort_by.sort # IDK why you would do this...
    )
  end

  def test_it_sorts_insensitive
    input = @input_strings.shuffle

    assert_equal(
      ["alpha", "Bravo", "charlie", "Delta"],
      input.sort_by.insensitive.sort
    )
  end

  def test_it_sorts_descending
    input = @input_strings.shuffle
    result = ["charlie", "alpha", "Delta", "Bravo"]

    assert_equal(result, input.sort_by.desc.sort)
    assert_equal(result, input.sort_by.reverse.sort)
  end

  def test_it_sorts_descending_insensitive
    input = @input_strings.shuffle
    result = ["Delta", "charlie", "Bravo", "alpha"]

    assert_equal(result, input.sort_by.desc.insensitive.sort)
    assert_equal(result, input.sort_by.insensitive.reverse.sort)
  end

  def test_it_sorts_by_key
    input = @input_hashes.shuffle
    result = [
      {name: "Bravo", age: 20, city: "Chicago"},
      {name: "Delta", age: 35, city: "NYC"},
      {name: "alpha", age: 30, city: "LA"},
      {name: "charlie", age: 25, city: "NYC"}
    ]

    assert_equal(result, input.sort_by.dig(:name).sort)
  end
end
