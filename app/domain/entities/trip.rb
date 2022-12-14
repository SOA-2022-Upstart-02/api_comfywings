# frozen_string_literal: false

require 'dry-struct'
require 'dry-types'

module ComfyWings
  module Entity
    # class for trip entities
    class Trip < Dry::Struct
      include Dry.Types

      attribute :id,                  Integer.optional
      attribute :query_id,            Strict::Integer
      attribute :currency,            Currency
      attribute :origin,              Airport
      attribute :destination,         Airport
      attribute :inbound_duration,    Strict::String
      attribute :outbound_duration,   Strict::String
      attribute :price,               Strict::Decimal
      attribute :is_one_way,          Strict::Bool
      attribute :flights,             Strict::Array.of(Flight)

      def outbound_duration_form
        ActiveSupport::Duration.parse(outbound_duration).parts
      end

      def duration_minutes
        outbound_minutes = ActiveSupport::Duration.parse(outbound_duration).in_minutes
        is_one_way ? outbound_minutes : outbound_minutes + ActiveSupport::Duration.parse(inbound_duration).in_minutes
      end

      def outbound_flights
        flights.reject(&:is_return)
      end

      def outbound_departure_time
        outbound_flights.first.departure_time
      end

      def outbound_arrival_time
        outbound_flights.last.arrival_time
      end

      def inbound_duration_form
        is_one_way ? nil : ActiveSupport::Duration.parse(inbound_duration).parts
      end

      def inbound_flights
        flights.select(&:is_return)
      end

      def inbound_departure_time
        is_one_way ? nil : inbound_flights.first.departure_time
      end

      def inbound_arrival_time
        is_one_way ? nil : inbound_flights.last.arrival_time
      end

      def price_form
        "#{price.truncate}.#{format('%02d', (price.frac * 100).truncate)}"
      end

      def one_way?
        is_one_way
      end

      def to_attr_hash
        to_hash.except(:id, :currency, :flights, :origin, :destination)
      end

      def happiness
        Mapper::TripHappiness.new(self).build_entity
      end
    end
  end
end
