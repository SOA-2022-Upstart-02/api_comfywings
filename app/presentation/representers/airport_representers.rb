# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

module ComfyWings
  module Representer
    # Representer for airport
    class Airport < Roar::Decorator
      include Roar::JSON

      # TODO: update to latest airport database attributes

      property :iata_code
      property :city_name
    end
  end
end
