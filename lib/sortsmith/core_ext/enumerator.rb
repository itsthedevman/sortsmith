# frozen_string_literal: true

module Enumerable
  alias_method :og_sort_by, :sort_by

  def sort_by(&block)
    return Sortsmith::Sorter.new(self) if block.nil?

    og_sort_by(&block)
  end
end
