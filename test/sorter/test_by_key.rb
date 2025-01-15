# frozen_string_literal: true

require "test_helper"

class TestByKey < Minitest::Test
  def setup
    input = [
      {key: "foo"},
      {key: "Foo"},
      {key: "bar"}
    ].shuffle

    @sorter = Sortsmith::Sorter.new(input).by_key(:key)
  end

  def test_it_sorts_by_key
    assert_equal(@sorter.sort, [{key: "Foo"}, {key: "bar"}, {key: "foo"}])
  end
end
