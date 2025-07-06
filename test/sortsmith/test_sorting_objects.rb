# frozen_string_literal: true

require "test_helper"

class TestSortingObjects < Minitest::Test
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
  end

  # Test sorting by method that doesn't exist
  def test_sorting_by_missing_method
    input = @users.dup
  end
end
