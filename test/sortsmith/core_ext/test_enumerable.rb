# frozen_string_literal: true

require "test_helper"

class TestEnumerable < Minitest::Test
  def test_it_returns_sorter
    assert_instance_of(Sortsmith::Sorter, [].sort_by)
  end

  def test_it_does_not_return_sorter
    assert_instance_of(Array, [].sort_by {})
  end
end
