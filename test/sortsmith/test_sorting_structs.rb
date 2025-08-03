# frozen_string_literal: true

require "test_helper"

class TestSortingStructs < Minitest::Test
  def setup
    user = Struct.new(:name, :age, :city)

    @users = [
      user.new("charlie", 25, "NYC"),
      user.new("alpha", 30, "LA"),
      user.new("Bravo", 20, "Chicago"),
      user.new("Delta", 35, "NYC")
    ]
  end

  # Test sorting objects by method
  def test_sorting_by_method
    input = @users.dup

    result = input.sort_by.dig(:name).insensitive.sort
    names = result.map(&:name)

    assert_equal(["alpha", "Bravo", "charlie", "Delta"], names)
  end

  # Test sorting by method that doesn't exist
  def test_sorting_by_missing_method
    input = @users.dup

    result = input.sort_by.dig(:email).insensitive.sort
    names = result.map(&:name)

    # No sort
    assert_equal(["charlie", "alpha", "Bravo", "Delta"], names)
  end
end
