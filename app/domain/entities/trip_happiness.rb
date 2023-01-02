# frozen_string_literal: true

module ComfyWings
  module Entity
    class TripHappiness
      def initialize(flight_happiness_scores)
        @flight_happiness_scores = flight_happiness_scores
      end

      def score
        final_score = @flight_happiness_scores.map { |flight| flight.score }.sum
        final_score / @flight_happiness_scores.length
      end
    end
  end
end