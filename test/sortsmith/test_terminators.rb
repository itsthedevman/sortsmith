# frozen_string_literal: true

require "test_helper"

class TestTerminators < Minitest::Test
  def setup
    @strings = ["charlie", "alpha", "bravo"]
  end

  # Test sort terminator returns new array
  def test_sort_returns_new_array
    input = @strings.dup
  end

  # Test sort! mutates original array
  def test_sort_bang_mutates_original
    input = @strings.dup
  end

  # Test reverse terminator
  def test_reverse_terminator
    input = @strings.dup
  end

  # Test reverse! terminator
  def test_reverse_bang_terminator
    input = @strings.dup
  end
end
