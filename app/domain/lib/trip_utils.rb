# frozen_string_literal: true

module ComfyWings
  # Main controller class for ComfyWings
  # deliberately :reek:RepeatedConditional
  class TripUtils
    TIME = 'time'
    PRICE = 'price'

    def self.sort_trips(trips, sorting)
      case sorting
      when 'price'
        trips.sort_by(&:price)
      when 'time'
        trips.sort_by(&:duration_minutes)
      else
        trips
      end
    end
  end
end
