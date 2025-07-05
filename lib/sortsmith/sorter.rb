# frozen_string_literal: true

module Sortsmith
  class Sorter
    def initialize(input)
      @input = input
    end

    # Extractors
    def dig(*t)
      self
    end

    # Modifiers
    def downcase
      self
    end

    def upcase
      self
    end

    def insensitive
      self
    end

    def desc
      self
    end

    def asc
      self
    end

    def reverse
      self
    end

    # Terminators
    def sort
    end

    def sort!
    end
  end
end
