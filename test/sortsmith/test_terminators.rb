# frozen_string_literal: true

require "test_helper"

class TestTerminators < Minitest::Test
  def setup
    @strings = ["charlie", "alpha", "bravo"]
  end

  # Test sort terminator returns new array
  def test_sort_returns_new_array
    input = @strings.dup

    result = input.sort_by.sort

    assert_equal(["alpha", "bravo", "charlie"], result)
    refute_same(input, result)
  end

  # Test sort! mutates original array
  def test_sort_bang_mutates_original
    input = @strings.dup

    result = input.sort_by.sort!

    assert_equal(["alpha", "bravo", "charlie"], result)
    assert_equal(["alpha", "bravo", "charlie"], input)
    assert_same(input, result)
  end

  # Test reverse terminator
  def test_reverse_terminator
    input = @strings.dup

    result = input.sort_by.reverse

    assert_equal(["charlie", "bravo", "alpha"], result)
    refute_same(input, result)
  end

  # Test reverse! terminator
  def test_reverse_bang_terminator
    input = @strings.dup

    result = input.sort_by.reverse!

    assert_equal(["charlie", "bravo", "alpha"], result)
    assert_equal(["charlie", "bravo", "alpha"], input)
    assert_same(input, result)
  end

  # Test to_a terminator
  def test_to_a_terminator
    input = @strings.dup

    result = input.sort_by.to_a

    assert_equal(["alpha", "bravo", "charlie"], result)
    refute_same(input, result)
  end
end
