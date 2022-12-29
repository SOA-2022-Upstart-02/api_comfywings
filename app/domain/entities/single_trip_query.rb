# frozen_string_literal: false

require 'date'
require 'dry-struct'
require 'dry-types'

module ComfyWings
  # ComfyWings Domain Modal
  module Entity
    # Domain entity for trip query arg
    class SingleTripQuery < Dry::Struct
      include Dry.Types

      attribute :id,             Integer.optional
      attribute :code,           Strict::String
      attribute :currency,       Currency
      attribute :origin,         Airport
      attribute :destination,    Airport
      attribute :departure_date, Strict::Date
      attribute :adult_qty,      Strict::Integer
      attribute :children_qty,   Strict::Integer
      attribute :is_one_way,     Strict::Bool
      attribute :is_new,         Strict::Bool

      def expired?
        departure_date <= Date.today
      end

      def create_amadeus_flight_offers
        {
          currencyCode: currency.code,
          originDestinations:
            is_one_way ? [create_outbound_destinations] : [create_outbound_destinations, create_inbound_destinations],
          travelers: create_travelers,
          sources: ['GDS']
        }
      end

      def to_attr_hash
        to_hash.except(:id, :currency, :origin, :destination)
      end

      private

      def create_outbound_destinations
        {
          id: 1,
          originLocationCode: origin.iata_code,
          destinationLocationCode: destination.iata_code,
          departureDateTimeRange: {
            date: departure_date
          }
        }
      end

      def create_inbound_destinations
        {
          id: 2,
          originLocationCode: destination.iata_code,
          destinationLocationCode: origin.iata_code,
          departureDateTimeRange: {
            date: arrival_date
          }
        }
      end

      def create_travelers
        create_adult_travelers + create_child_travelers
      end

      def create_adult_travelers
        (1..adult_qty).map { |num| { id: num, travelerType: 'ADULT' } }
      end

      def create_child_travelers
        (1..children_qty).map { |num| { id: num + adult_qty, travelerType: 'CHILD' } }
      end
    end

    def f1
      puts Date.today
    end
  end
end
