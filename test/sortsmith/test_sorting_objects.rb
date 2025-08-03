# frozen_string_literal: true

require "test_helper"

class TestSortingObjects < Minitest::Test
  class TestObject
    attr_reader :name, :age, :city

    def initialize(name, age, city)
      @name = name
      @age = age
      @city = city
    end

    # Method with positional arguments
    def name_rotated(positions = 0)
      return @name if positions == 0
      chars = @name.chars
      chars.rotate(positions).join
    end

    # Method with keyword arguments
    def calculate_score(base: 100, age_bonus: true, city_bonus: 0)
      score = base
      score += @age if age_bonus
      score += city_bonus
      score
    end

    # Method with BOTH positional and keyword arguments
    def formatted_intro(greeting, excited: false, include_city: true)
      result = "#{greeting}, I'm #{@name}"
      result += " from #{@city}" if include_city
      result += "!" if excited
      result
    end
  end

  def setup
    @users = [
      TestObject.new("charlie", 25, "NYC"),
      TestObject.new("alpha", 30, "LA"),
      TestObject.new("Bravo", 20, "Chicago"),
      TestObject.new("Delta", 35, "NYC")
    ]
  end

  # Test sorting objects by method
  def test_sorting_by_method
    input = @users.dup

    result = input.sort_by.method(:name).insensitive.sort
    names = result.map(&:name)

    assert_equal(["alpha", "Bravo", "charlie", "Delta"], names)
  end

  # Test attribute alias
  def test_attribute_alias
    input = @users.dup

    result = input.sort_by.attribute(:name).insensitive.sort
    names = result.map(&:name)

    assert_equal(["alpha", "Bravo", "charlie", "Delta"], names)
  end

  # Test sorting by method that doesn't exist
  def test_sorting_by_missing_method
    input = @users.dup

    result = input.sort_by.method(:email).insensitive.sort
    names = result.map(&:name)

    # Preserves original order when method doesn't exist
    assert_equal(["charlie", "alpha", "Bravo", "Delta"], names)
  end

  # Test sorting by method with positional arguments
  def test_sorting_by_method_with_positional_arguments
    input = @users.dup

    # Rotate each name by 1 position - this should scramble the sort order!
    # charlie -> harlie, alpha -> lphaa, Bravo -> ravoB, Delta -> eltaD
    result = input.sort_by.method(:name_rotated, 1).insensitive.sort
    names = result.map(&:name)

    # After rotation: eltaD, harlie, lphaa, ravoB
    # So original names should be: Delta, charlie, alpha, Bravo
    assert_equal(["Delta", "charlie", "alpha", "Bravo"], names)

    # Test with different rotation to make sure argument is actually being used
    # Rotate by 2: charlie -> arlic, alpha -> haaal, Bravo -> avoB, Delta -> ltaDe
    result = input.sort_by.method(:name_rotated, 2).insensitive.sort
    names = result.map(&:name)

    # After rotation: arlic, avoB, haaal, ltaDe
    # So original names should be: charlie, Bravo, alpha, Delta
    assert_equal(["charlie", "Bravo", "Delta", "alpha"], names)
  end

  # Test sorting by method with keyword arguments
  def test_sorting_by_method_with_keyword_arguments
    input = @users.dup

    # Sort by calculated score (base 50, no age bonus, no city bonus)
    # This should give us: charlie=50, alpha=50, Bravo=50, Delta=50
    # So it should preserve original order since all scores are equal
    result = input.sort_by.method(:calculate_score, base: 50, age_bonus: false).sort
    names = result.map(&:name)

    assert_equal(["charlie", "alpha", "Bravo", "Delta"], names)

    # Now sort by age (base 0, with age bonus)
    # Scores: charlie=25, alpha=30, Bravo=20, Delta=35
    result = input.sort_by.method(:calculate_score, base: 0, age_bonus: true).sort
    names = result.map(&:name)

    assert_equal(["Bravo", "charlie", "alpha", "Delta"], names)
  end

  # Test sorting by method with both positional and keyword arguments
  def test_sorting_by_method_with_mixed_arguments
    input = @users.dup

    # Sort by formatted intro with greeting "Hello", not excited, include city
    # Results: "Hello, I'm charlie from NYC", "Hello, I'm alpha from LA", etc.
    result = input.sort_by
      .method(:formatted_intro, "Hello", excited: false, include_city: true)
      .insensitive
      .sort

    names = result.map(&:name)

    assert_equal(["alpha", "Bravo", "charlie", "Delta"], names)

    # Sort by formatted intro without city (should still be alphabetical by name)
    result = input.sort_by
      .method(:formatted_intro, "Hi", excited: true, include_city: false)
      .insensitive
      .sort

    names = result.map(&:name)

    assert_equal(["alpha", "Bravo", "charlie", "Delta"], names)
  end

  # Test method chaining with complex arguments
  def test_method_chaining_with_arguments
    input = @users.dup

    # Sort by calculate_score descending
    result = input.sort_by.method(:calculate_score, base: 0).desc.sort
    names = result.map(&:name)

    # Ages: charlie=25, alpha=30, Bravo=20, Delta=35
    # Descending: Delta(35), alpha(30), charlie(25), Bravo(20)
    assert_equal(["Delta", "alpha", "charlie", "Bravo"], names)
  end
end
