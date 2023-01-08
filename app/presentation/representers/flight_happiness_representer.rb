# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

module ComfyWings
  module Representer
    # Represent Flight as Json
    class FlightHappiness < Roar::Decorator
      include Roar::JSON

      property :score
      property :plane_class
    end
  end
end
