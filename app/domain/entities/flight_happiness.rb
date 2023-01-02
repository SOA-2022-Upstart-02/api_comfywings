# frozen_string_literal: true\

require 'dry-types'
require 'dry-struct'

module ComfyWings
  module Entity
    class FlightHappiness
      WIDEBODY_PLANES = Regexp.union([/787/, /777/, /767/, /747/, /A33\d/, /A35\d/, /A38\d/].freeze)
      NARROWBODY_PLANES = Regexp.union([/737/, /757/, /A32\d/, /EMBRAER.*/].freeze)
      COMFORTABLE_CLASSES = ['PREMIUM ECONOMY', 'BUSINESS', 'FIRST'].freeze

      attr_reader :plane_model, :arrival_time, :departure_time, :arrival_date
    
      def initialize(plane_model, cabin_class, arrival_time)
        @plane_model = plane_model
        @cabin_class = cabin_class
        @arrival_time = arrival_time
      end

      def widebody?
        WIDEBODY_PLANES === @plane_model
      end

      def narrowbody?
        NARROWBODY_PLANES === @plane_model
      end

      def score
        # Add score if there is legroom, larger planes are assumed to have more legroom
        # 1 score if plane is unknown
        if widebody?
          final_score = 5
        elsif narrowbody?
          final_score = 3
        else
          final_score = 1
        end

        # Higher classes are thought to offer more amenities and better services
        final_score += (COMFORTABLE_CLASSES.include?(@cabin_class) ? 2 : 1)

        final_score
      end
    end
  end
end