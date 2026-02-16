# frozen_string_literal: true

require "test_helper"

class TestNilHandling < Minitest::Test
  def setup
    @mixed_data = [
      {name: "Charlie", age: 30},
      {name: nil, age: 25},
      {name: "Alice", age: nil},
      {name: "Bob", age: 35},
      {name: nil, age: nil}
    ]
  end

  # Test default behavior: nil sorts last
  def test_nil_sorts_last_by_default
    input = @mixed_data.dup

    result = input.sort_by.dig(:name).sort
    names = result.map { |i| i[:name] }

    # Non-nil values come first, sorted, then nils
    assert_equal("Alice", names[0])
    assert_equal("Bob", names[1])
    assert_equal("Charlie", names[2])
    assert_nil(names[3])
    assert_nil(names[4])
  end

  # Test explicit nil_last (same as default)
  def test_nil_last_explicit
    input = @mixed_data.dup

    result = input.sort_by.dig(:name).nil_last.sort
    names = result.map { |i| i[:name] }

    assert_equal("Alice", names[0])
    assert_equal("Bob", names[1])
    assert_equal("Charlie", names[2])
    assert_nil(names[3])
    assert_nil(names[4])
  end

  # Test nil_first modifier
  def test_nil_first
    input = @mixed_data.dup

    result = input.sort_by.dig(:name).nil_first.sort
    names = result.map { |i| i[:name] }

    # Nils come first, then non-nil values sorted
    assert_nil(names[0])
    assert_nil(names[1])
    assert_equal("Alice", names[2])
    assert_equal("Bob", names[3])
    assert_equal("Charlie", names[4])
  end

  # Test nil_first with desc
  def test_nil_first_with_desc
    input = @mixed_data.dup

    result = input.sort_by.dig(:name).nil_first.desc.sort
    names = result.map { |i| i[:name] }

    # Nils first, then non-nil values in descending order
    assert_nil(names[0])
    assert_nil(names[1])
    assert_equal("Charlie", names[2])
    assert_equal("Bob", names[3])
    assert_equal("Alice", names[4])
  end

  # Test nil_last with desc
  def test_nil_last_with_desc
    input = @mixed_data.dup

    result = input.sort_by.dig(:name).nil_last.desc.sort
    names = result.map { |i| i[:name] }

    # Non-nil values in descending order, then nils
    assert_equal("Charlie", names[0])
    assert_equal("Bob", names[1])
    assert_equal("Alice", names[2])
    assert_nil(names[3])
    assert_nil(names[4])
  end

  # Test nil_first with case insensitive
  def test_nil_first_with_case_insensitive
    input = [
      {name: "charlie"},
      {name: nil},
      {name: "Alice"},
      {name: "BOB"}
    ]

    result = input.sort_by.dig(:name).insensitive.nil_first.sort
    names = result.map { |i| i[:name] }

    assert_nil(names[0])
    assert_equal("Alice", names[1])
    assert_equal("BOB", names[2])
    assert_equal("charlie", names[3])
  end

  # Test overriding: nil_first then nil_last should use nil_last
  def test_nil_first_then_nil_last
    input = @mixed_data.dup

    result = input.sort_by.dig(:name).nil_first.nil_last.sort
    names = result.map { |i| i[:name] }

    # Should use nil_last (last setting wins)
    assert_equal("Alice", names[0])
    assert_equal("Bob", names[1])
    assert_equal("Charlie", names[2])
    assert_nil(names[3])
    assert_nil(names[4])
  end

  # Test with numeric data
  def test_nil_first_with_numbers
    input = @mixed_data.dup

    result = input.sort_by.dig(:age).nil_first.sort
    ages = result.map { |i| i[:age] }

    assert_nil(ages[0])
    assert_nil(ages[1])
    assert_equal(25, ages[2])
    assert_equal(30, ages[3])
    assert_equal(35, ages[4])
  end

  # Test all nils
  def test_all_nils
    input = [{name: nil}, {name: nil}, {name: nil}]

    result = input.sort_by.dig(:name).nil_first.sort
    names = result.map { |i| i[:name] }

    assert_equal([nil, nil, nil], names)
  end

  # Test no nils
  def test_no_nils
    input = [{name: "Alice"}, {name: "Bob"}, {name: "Charlie"}]

    result = input.sort_by.dig(:name).nil_first.sort
    names = result.map { |i| i[:name] }

    assert_equal(["Alice", "Bob", "Charlie"], names)
  end

  # Test nil_first with in-place sort
  def test_nil_first_with_sort_bang
    input = @mixed_data.dup

    input.sort_by.dig(:name).nil_first.sort!
    names = input.map { |i| i[:name] }

    assert_nil(names[0])
    assert_nil(names[1])
    assert_equal("Alice", names[2])
    assert_equal("Bob", names[3])
    assert_equal("Charlie", names[4])
  end

  # Test nil_first with reverse terminator
  def test_nil_first_with_reverse
    input = @mixed_data.dup

    result = input.sort_by.dig(:name).nil_first.reverse
    names = result.map { |i| i[:name] }

    # nil_first.reverse same as nil_first.desc
    assert_nil(names[0])
    assert_nil(names[1])
    assert_equal("Charlie", names[2])
    assert_equal("Bob", names[3])
    assert_equal("Alice", names[4])
  end

  # Test with direct syntax
  def test_nil_first_with_direct_syntax
    input = @mixed_data.dup

    result = input.sort_by(:name).nil_first.sort
    names = result.map { |i| i[:name] }

    assert_nil(names[0])
    assert_nil(names[1])
    assert_equal("Alice", names[2])
    assert_equal("Bob", names[3])
    assert_equal("Charlie", names[4])
  end

  # Test with delegated methods
  def test_nil_first_with_delegated_first
    input = @mixed_data.dup

    result = input.sort_by.dig(:name).nil_first.first(3)

    # Should get the first 3 elements from nil-first sorted array
    assert_equal(3, result.length)
    assert_nil(result[0][:name])
    assert_nil(result[1][:name])
    assert_equal("Alice", result[2][:name])
  end
end
