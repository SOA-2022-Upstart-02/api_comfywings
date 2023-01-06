# frozen_string_literal: true

require 'date'
require_relative 'currencies'
require_relative 'flights'
require_relative 'airports'

module ComfyWings
  module Repository
    # Repository for Trip Queries
    class TripQueries
      def self.find(entity)
        find_code(entity.code)
      end

      def self.find_code(code)
        rebuild_entity Database::TripQueryOrm.first(code:)
      end

      def self.update_searched(id)
        rebuild_entity Database::TripQueryOrm.first(id:).update(is_new: false)
      end

      def self.all
        rebuild_many Database::TripQueryOrm.all
      end

      def self.create(entity)
        raise 'Query already exists' if find(entity)

        currency = Currencies.db_find(entity.currency)
        origin = Airports.db_find(entity.origin)
        destination = Airports.db_find(entity.destination)

        db_trip_query = Database::TripQueryOrm.create(entity.to_attr_hash)

        db_trip_query.update(currency:)
        db_trip_query.update(origin:)
        db_trip_query.update(destination:)

        rebuild_entity(db_trip_query)
      end

      def self.delete(code)
        Database::TripQueryOrm.where(code:).delete
      end

      def self.rebuild_entity(db_record)
        return nil unless db_record

        Entity::TripQuery.new(
          db_record.to_hash.merge(
            origin: Airports.rebuild_entity(db_record.origin),
            destination: Airports.rebuild_entity(db_record.destination),
            currency: Currencies.rebuild_entity(db_record.currency)
          )
        )
      end

      def self.rebuild_many(db_records)
        db_records.map do |db_member|
          SingleTripQueries.rebuild_entity(db_member)
        end
      end
    end
  end
end
