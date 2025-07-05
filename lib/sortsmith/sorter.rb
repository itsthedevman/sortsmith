# frozen_string_literal: true

module Sortsmith
  class Sorter
    def initialize(input)
      @input = input
    end

    # Extractors
    def dig(*t)
    end

    # Modifiers
    def downcase
    end

    def upcase
    end

    def insensitive
    end

    def desc
    end

    def asc
    end

    def reverse
    end

    # Terminators
    def sort
    end

    def sort!
    end
  end
end
