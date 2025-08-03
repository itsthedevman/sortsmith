# frozen_string_literal: true

require "test_helper"

class TestDelegatedMethods < Minitest::Test
  def setup
    @users = [
      {name: "Charlie", score: 85, team: "red"},
      {name: "Alice", score: 92, team: "blue"},
      {name: "Bob", score: 78, team: "red"},
      {name: "Diana", score: 95, team: "blue"}
    ]
    @numbers = [3, 1, 4, 1, 5, 9, 2, 6]
  end

  # Test first method without arguments
  def test_first_without_args
    result = @users.sort_by.dig(:name).first

    assert_equal({name: "Alice", score: 92, team: "blue"}, result)
  end

  # Test first method with count argument
  def test_first_with_count
    result = @users.sort_by.dig(:score).desc.first(2)
    scores = result.map { |u| u[:score] }

    assert_equal([95, 92], scores)
    assert_equal(2, result.length)
  end

  # Test last method without arguments
  def test_last_without_args
    result = @users.sort_by.dig(:name).last

    assert_equal({name: "Diana", score: 95, team: "blue"}, result)
  end

  # Test last method with count argument
  def test_last_with_count
    result = @users.sort_by.dig(:score).last(2)
    scores = result.map { |u| u[:score] }

    assert_equal([92, 95], scores)
    assert_equal(2, result.length)
  end

  # Test array access with []
  def test_array_access
    sorted = @users.sort_by.dig(:score).desc

    assert_equal({name: "Diana", score: 95, team: "blue"}, sorted[0])
    assert_equal({name: "Alice", score: 92, team: "blue"}, sorted[1])
    assert_equal({name: "Bob", score: 78, team: "red"}, sorted[-1])
  end

  # Test array access with range
  def test_array_access_with_range
    result = @users.sort_by.dig(:score).desc[1..2]
    scores = result.map { |u| u[:score] }

    assert_equal([92, 85], scores)
  end

  # Test take method
  def test_take
    result = @numbers.sort_by.sort.take(3)

    assert_equal([1, 1, 2], result)
  end

  # Test take with more than available
  def test_take_more_than_available
    result = @numbers.sort_by.sort.take(20)

    assert_equal([1, 1, 2, 3, 4, 5, 6, 9], result)
  end

  # Test drop method
  def test_drop
    result = @numbers.sort_by.sort.drop(3)

    assert_equal([3, 4, 5, 6, 9], result)
  end

  # Test drop with more than available
  def test_drop_more_than_available
    result = @numbers.sort_by.sort.drop(20)

    assert_equal([], result)
  end

  # Test each method
  def test_each
    names = []
    result = @users.sort_by.dig(:name).each { |user| names << user[:name] }

    assert_equal(["Alice", "Bob", "Charlie", "Diana"], names)
    assert_equal(@users.sort_by.dig(:name).to_a, result)
  end

  # Test each without block returns enumerator
  def test_each_without_block
    result = @users.sort_by.dig(:name).each

    assert_instance_of(Enumerator, result)
    assert_equal(4, result.count)
  end

  # Test map method
  def test_map
    result = @users.sort_by.dig(:name).map { |user| user[:name].upcase }

    assert_equal(["ALICE", "BOB", "CHARLIE", "DIANA"], result)
  end

  # Test map without block returns enumerator
  def test_map_without_block
    result = @users.sort_by.dig(:name).map

    assert_instance_of(Enumerator, result)
  end

  # Test select method
  def test_select
    result = @users.sort_by.dig(:score).select { |user| user[:score] > 80 }
    scores = result.map { |u| u[:score] }

    assert_equal([85, 92, 95], scores)
  end

  # Test select without block returns enumerator
  def test_select_without_block
    result = @users.sort_by.dig(:name).select

    assert_instance_of(Enumerator, result)
  end

  # Test count method without arguments
  def test_count_without_args
    result = @users.sort_by.dig(:name).count

    assert_equal(4, result)
  end

  # Test count method with block
  def test_count_with_block
    result = @users.sort_by.dig(:name).count { |user| user[:team] == "blue" }

    assert_equal(2, result)
  end

  # Test size method
  def test_size
    result = @users.sort_by.dig(:name).size

    assert_equal(4, result)
  end

  # Test length method
  def test_length
    result = @users.sort_by.dig(:name).length

    assert_equal(4, result)
  end

  # Test chaining multiple delegated methods
  def test_chaining_delegated_methods
    # This is a bit contrived but tests the concept
    sorted_users = @users.sort_by.dig(:score).desc
    top_scores = sorted_users.first(3).map { |u| u[:score] }

    assert_equal([95, 92, 85], top_scores)
  end

  # Test with empty array
  def test_delegated_methods_with_empty_array
    empty = []

    assert_nil(empty.sort_by.first)
    assert_equal([], empty.sort_by.first(5))
    assert_nil(empty.sort_by.last)
    assert_equal(0, empty.sort_by.sort.count)
    assert_equal(0, empty.sort_by.sort.size)
  end

  # Test with complex chaining before delegation
  def test_complex_chaining_before_delegation
    result = @users.sort_by.dig(:name).insensitive.desc.take(2)
    names = result.map { |u| u[:name] }

    assert_equal(["Diana", "Charlie"], names)
  end

  # Test that original array is not modified
  def test_original_array_unchanged
    original_first_user = @users.first
    @users.sort_by.dig(:score).first(2)

    assert_equal(original_first_user, @users.first)
  end

  # Test delegation with method extraction
  def test_delegation_with_method_extraction
    user = Struct.new(:name, :score)
    objects = [
      user.new("Charlie", 85),
      user.new("Alice", 92),
      user.new("Bob", 78)
    ]

    result = objects.sort_by.method(:score).desc.first
    assert_equal("Alice", result.name)
    assert_equal(92, result.score)
  end
end
