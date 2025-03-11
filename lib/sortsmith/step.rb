# frozen_string_literal: true

module Sortsmith
  #
  # Represents a single step in the sorting process pipeline.
  # Steps can be either filter or transformation steps.
  #
  # Filter steps extract data from items to be compared during sorting.
  # Transformation steps modify the extracted data before comparison.
  #
  # @api private
  #
  class Step < Data.define(:type, :block)
    #
    # Available step types
    #
    # @api private
    #
    TYPES = [
      #
      # A transformation step transforms data for comparison
      #
      TRANSFORMATION = :transformation,

      #
      # A filter step extracts data from items for comparison
      #
      FILTER = :filter
    ].freeze

    #
    # Execute the step's logic on the provided item
    #
    # @param item [Object] The item to process
    #
    # @return [Object] The result of applying the step's block to the item
    #
    # @api private
    #
    def perform(item)
      block.call(item)
    end
  end
end
