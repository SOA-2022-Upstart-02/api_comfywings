# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module ComfyWings
  module Entity
    # Flight Happiness Entity
    class FlightHappiness
      WIDEBODY_PLANES = Regexp.union([/787/, /777/, /767/, /747/, /A33\d/, /A35\d/, /A38\d/].freeze)
      NARROWBODY_PLANES = Regexp.union([/737/, /757/, /A32\d/, /EMBRAER.*/].freeze)
      COMFORTABLE_CLASSES = ['PREMIUM ECONOMY', 'BUSINESS', 'FIRST'].freeze
      ONE_HOUR = 60.0

      attr_reader :plane_model, :cabin_class, :arrival_time, :duration

      def initialize(plane_model, cabin_class, arrival_time, duration)
        @plane_model = plane_model
        @cabin_class = cabin_class
        @arrival_time = arrival_time
        @duration = duration
      end

      def widebody?
        WIDEBODY_PLANES === @plane_model
      end

      def narrowbody?
        NARROWBODY_PLANES === @plane_model
      end

      def duration_to_hours
        duration[:minutes] ? (duration[:hours] + (duration[:minutes] / ONE_HOUR)) : duration[:hours]
      end

      def score
        # Add score if there is legroom, larger planes are assumed to have more legroom
        # 1 score if plane is unknown
        final_score = if widebody?
                        5
                      elsif narrowbody?
                        3
                      else
                        1
                      end

        # Higher classes are thought to offer more amenities and better services
        final_score += (COMFORTABLE_CLASSES.include?(@cabin_class) ? 2 : 1)

        final_score
      end
    end
  end
end
