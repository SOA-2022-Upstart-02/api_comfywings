# frozen_string_literal: true

module ComfyWings
  # Main controller class for ComfyWings
  # deliberately :reek:RepeatedConditional
  class TripUtils
    TIME = 'time'
    PRICE = 'price'
    HAPPYINESS = 'happiness'

    def self.sort_trips(trips, sorting)
      case sorting
      when PRICE
        trips.sort_by(&:price)
      when TIME
        trips.sort_by(&:duration_minutes)
      when HAPPYINESS
        trips.sort_by { |trip| trip.happiness.score }
      else
        trips
      end
    end
  end
end
