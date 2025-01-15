# frozen_string_literal: true

require "test_helper"

class TestByMethod < Minitest::Test
  def setup
    @object = Data.define(:key)

    input = [
      @object.new(key: "foo"),
      @object.new(key: "Foo"),
      @object.new(key: "bar")
    ].shuffle

    @sorter = Sortsmith::Sorter.new(input).by_method(:key)
  end

  def test_it_sorts_by_method
    assert_equal(
      [
        @object.new(key: "Foo"),
        @object.new(key: "bar"),
        @object.new(key: "foo")
      ],
      @sorter.sort
    )
  end
end
