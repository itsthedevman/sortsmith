# frozen_string_literal: true

require "test_helper"

class TestDirectSyntax < Minitest::Test
  def setup
    @users = [
      {name: "Charlie", score: 85, team: "red"},
      {name: "Alice", score: 92, team: "blue"},
      {name: "bob", score: 78, team: "red"},
      {name: "Diana", score: 95, team: "blue"}
    ]

    @mixed_keys = [
      {name: "Charlie"},        # symbol key
      {"name" => "Alice"},      # string key
      {name: "Bob"},            # symbol key
      {"name" => "Diana"}       # string key
    ]

    struct = Struct.new(:name, :score)
    @objects = [
      struct.new("Charlie", 85),
      struct.new("Alice", 92),
      struct.new("bob", 78)
    ]
  end

  # Test basic direct syntax sorting
  def test_direct_syntax_basic_sorting
    result = @users.sort_by(:name).sort
    names = result.map { |u| u[:name] }

    assert_equal(["Alice", "Charlie", "Diana", "bob"], names)
  end

  # Test direct syntax with case insensitive
  def test_direct_syntax_case_insensitive
    result = @users.sort_by(:name).insensitive.sort
    names = result.map { |u| u[:name] }

    assert_equal(["Alice", "bob", "Charlie", "Diana"], names)
  end

  # Test direct syntax with descending order
  def test_direct_syntax_descending
    result = @users.sort_by(:score).desc.sort
    scores = result.map { |u| u[:score] }

    assert_equal([95, 92, 85, 78], scores)
  end

  # Test direct syntax with complex chaining
  def test_direct_syntax_complex_chaining
    result = @users.sort_by(:name).case_insensitive.desc.sort
    names = result.map { |u| u[:name] }

    assert_equal(["Diana", "Charlie", "bob", "Alice"], names)
  end

  # Test direct syntax with indifferent keys
  def test_direct_syntax_indifferent_keys
    result = @mixed_keys.sort_by(:name, indifferent: true).sort
    names = result.map { |item| item[:name] || item["name"] }

    assert_equal(["Alice", "Bob", "Charlie", "Diana"], names)
  end

  # Test direct syntax with indifferent keys and modifiers
  def test_direct_syntax_indifferent_with_modifiers
    mixed_case = [
      {name: "charlie"},
      {"name" => "Alice"},
      {name: "BOB"}
    ]

    result = mixed_case.sort_by(:name, indifferent: true).insensitive.sort
    names = result.map { |item| item[:name] || item["name"] }

    assert_equal(["Alice", "BOB", "charlie"], names)
  end

  # Test direct syntax with objects
  def test_direct_syntax_with_objects
    result = @objects.sort_by(:name).insensitive.sort
    names = result.map(&:name)

    assert_equal(["Alice", "bob", "Charlie"], names)
  end

  # Test direct syntax with missing field
  def test_direct_syntax_missing_field
    result = @users.sort_by(:missing_field).sort
    # Should preserve original order when field doesn't exist
    names = result.map { |u| u[:name] }

    assert_equal(["Charlie", "Alice", "bob", "Diana"], names)
  end

  # Test direct syntax with numeric sorting
  def test_direct_syntax_numeric_sorting
    numbers = [
      {value: 42},
      {value: 1},
      {value: 99},
      {value: 15}
    ]

    result = numbers.sort_by(:value).sort
    values = result.map { |n| n[:value] }

    assert_equal([1, 15, 42, 99], values)
  end

  # Test direct syntax returns Sorter instance for chaining
  def test_direct_syntax_returns_sorter
    sorter = @users.sort_by(:name)

    assert_instance_of(Sortsmith::Sorter, sorter)
  end

  # Test direct syntax with terminators
  def test_direct_syntax_with_terminators
    # sort
    result = @users.sort_by(:score).sort
    assert_instance_of(Array, result)

    # sort!
    input = @users.dup
    result = input.sort_by(:score).sort!
    assert_same(input, result)

    # reverse
    result = @users.sort_by(:score).reverse
    scores = result.map { |u| u[:score] }
    assert_equal([95, 92, 85, 78], scores)

    # to_a
    result = @users.sort_by(:name).to_a
    assert_instance_of(Array, result)
  end

  # Test direct syntax with delegated methods
  def test_direct_syntax_with_delegated_methods
    # first
    result = @users.sort_by(:score).desc.first
    assert_equal("Diana", result[:name])

    # first with count
    result = @users.sort_by(:score).desc.first(2)
    names = result.map { |u| u[:name] }
    assert_equal(["Diana", "Alice"], names)

    # take
    result = @users.sort_by(:name).take(2)
    names = result.map { |u| u[:name] }
    assert_equal(["Alice", "Charlie"], names)

    # map
    result = @users.sort_by(:score).map { |u| u[:name] }
    assert_equal(["bob", "Charlie", "Alice", "Diana"], result)

    # each (should return the sorted array)
    names = []
    result = @users.sort_by(:name).each { |u| names << u[:name] }
    assert_equal(["Alice", "Charlie", "Diana", "bob"], names)
    assert_instance_of(Array, result)
  end

  # Test that original behavior with blocks is preserved
  def test_direct_syntax_preserves_block_behavior
    # Traditional sort_by with block should work unchanged
    result = @users.sort_by { |u| u[:name].downcase }
    names = result.map { |u| u[:name] }

    assert_equal(["Alice", "bob", "Charlie", "Diana"], names)
    assert_instance_of(Array, result)
  end

  # Test direct syntax with nil values
  def test_direct_syntax_with_nil_values
    users_with_nil = [
      {name: "Charlie", email: "charlie@test.com"},
      {name: "Alice", email: nil},
      {name: "Bob", email: "bob@test.com"}
    ]

    # Should fail gracefully when trying to compare nil with string
    error = assert_raises(ArgumentError) do
      users_with_nil.sort_by(:email).sort
    end

    assert_match(/Cannot compare values during sort/, error.message)
    assert_match(/nil \(NilClass\)/, error.message)
    assert_match(/String/, error.message)
  end

  # Test direct syntax equivalent to dig
  def test_direct_syntax_equivalent_to_dig
    # These should produce identical results
    direct_result = @users.sort_by(:name).insensitive.sort
    dig_result = @users.sort_by.dig(:name).insensitive.sort

    assert_equal(dig_result, direct_result)
  end

  # Test direct syntax with indifferent equivalent to dig
  def test_direct_syntax_indifferent_equivalent_to_dig
    direct_result = @mixed_keys.sort_by(:name, indifferent: true).sort
    dig_result = @mixed_keys.sort_by.dig(:name, indifferent: true).sort

    assert_equal(dig_result, direct_result)
  end

  # Test edge case: empty field name
  def test_direct_syntax_empty_field
    # When no extraction criteria is provided, should fail with helpful message
    error = assert_raises(ArgumentError) do
      @users.sort_by(nil).sort
    end

    assert_match(/Cannot compare values during sort/, error.message)
    assert_match(/Hash.*\n.*<=>.*\n.*Hash/m, error.message)
    assert_match(/missing an extraction method/, error.message)
  end

  # Test direct syntax still works with sort_by without arguments
  def test_direct_syntax_nil_field_returns_plain_sorter
    sorter = @users.sort_by

    assert_instance_of(Sortsmith::Sorter, sorter)

    # Should still be chainable
    result = sorter.dig(:name).sort
    names = result.map { |u| u[:name] }
    assert_equal(["Alice", "Charlie", "Diana", "bob"], names)
  end

  # Test that extract method works directly on Sorter instances
  def test_extract_method_on_sorter
    sorter = @users.sort_by

    # Test basic extract
    result = sorter.extract(:name).sort
    names = result.map { |u| u[:name] }
    assert_equal(["Alice", "Charlie", "Diana", "bob"], names)

    # Test extract with indifferent keys
    sorter = @mixed_keys.sort_by
    result = sorter.extract(:name, indifferent: true).sort
    names = result.map { |item| item[:name] || item["name"] }
    assert_equal(["Alice", "Bob", "Charlie", "Diana"], names)

    # Test extract with chaining
    result = @users.sort_by.extract(:name).insensitive.desc.sort
    names = result.map { |u| u[:name] }
    assert_equal(["Diana", "Charlie", "bob", "Alice"], names)

    # Test extract returns Sorter for chaining
    extracted_sorter = sorter.extract(:name)
    assert_instance_of(Sortsmith::Sorter, extracted_sorter)
  end
end
