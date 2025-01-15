# frozen_string_literal: true

require "test_helper"

class TestCaseInsensitivity < Minitest::Test
  def setup
    input = %w[
      Ab
      aa
      bA
      BB
      Ca
      ca
    ].shuffle

    @sorter = Sortsmith::Sorter.new(input).case_insensitive
  end

  # When we sort insensitively, it will prioritize capital letters first,
  # followed by their lowercase counterparts
  def test_it_sorts_case_insensitively
    assert_equal(
      %w[
        Ab
        aa
        BB
        bA
        Ca
        ca
      ],
      @sorter.sort
    )
  end
end
