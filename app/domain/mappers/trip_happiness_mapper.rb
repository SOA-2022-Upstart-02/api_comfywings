# frozen_string_literal: true

require_relative 'flight_happiness_mapper'

module ComfyWings
  module Mapper
    class TripHappiness

      attr_reader :no_of_flights, :flights
      
      def initialize(trip)
        @flights = trip.flights
        @no_of_flights = trip.flights.length
      end

      def build_entity
        flight_array = @flights.map do |flight|
          Mapper::FlightHappiness.new(flight).to_entity
        end

        Entity::TripHappiness.new(flight_array)
      end

    end
  end
end