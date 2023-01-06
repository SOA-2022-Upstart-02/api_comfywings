# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

module ComfyWings
  module Representer
    # Represent Flight as Json
    class TripHappiness < Roar::Decorator
      include Roar::JSON

      property :score
    end
  end
end
