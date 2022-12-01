# frozen_string_literal: true

require 'dry/transaction'
require 'digest'

module ComfyWings
  module Service
    # Retrieves array of all listed project entities
    class SearchTrips
      include Dry::Transaction

      step :valid_trip_query
      step :find_or_create_trips

      private

      DB_ERR_MSG = 'Having trouble accessing the database'

      def valid_trip_query(query_code)
        trip_query = Repository::For.klass(Entity::TripQuery).find_code(query_code)
        Success(trip_query:)
      rescue StandardError => e
        Failure(Response::ApiResult.new(status: :not_found, message: e.to_s))
      end

      def find_or_create_trips(input)
        puts '====================================='
        puts input[:trip_query]
        trips = find_trips_from_database(input[:trip_query].id)
        puts 'Not Found' if trips.empty?
        # create_trips_from_amadeus(new_trip_query)
        Success(Response::ApiResult.new(status: :ok, message: trips))
      rescue StandardError => e
        puts e.backtrace.join("\n")
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR_MSG))
      end

      def create_trips_from_amadeus(trip_query)
        trips = Amadeus::TripMapper.new(App.config.AMADEUS_KEY, App.config.AMADEUS_SECRET).search(trip_query)
        ComfyWings::Repository::For.klass(Entity::Trip).create_many(trips)
      end

      def find_trips_from_database(query_id)
        ComfyWings::Repository::For.klass(Entity::Trip).find_query_id(query_id)
      end
    end
  end
end
