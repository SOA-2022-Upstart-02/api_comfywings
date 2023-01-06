# frozen_string_literal: true

module ComfyWings
  module Entity
    class TripHappiness
      attr_reader :flight_happiness_scores, :total_duration

      def initialize(flight_happiness_scores)
        @flight_happiness_scores = flight_happiness_scores
        @total_duration = @flight_happiness_scores.reduce(0.0) do |acc, flight|
          acc + flight.duration_to_hours
        end
      end

      def score
        @flight_happiness_scores.map { |flight| flight.score * (flight.duration_to_hours / total_duration) }.sum
      end
    end
  end
end