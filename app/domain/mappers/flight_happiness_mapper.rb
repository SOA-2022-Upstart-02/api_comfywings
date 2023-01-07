# frozen_string_literal: true

module ComfyWings
  module Mapper
    # FlightHappiness Mapper
    class FlightHappiness
      def initialize(flight)
        @plane_model = flight.aircraft
        @cabin_class = flight.cabin_class
        @arrival_time = flight.arrival_time
        @duration = flight.duration_form
      end

      def to_entity
        Entity::FlightHappiness.new(
          @plane_model,
          @cabin_class,
          @arrival_time,
          @duration
        )
      end
    end
  end
end
