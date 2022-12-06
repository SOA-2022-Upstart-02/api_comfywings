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
        puts Date.today 
        puts trip_query.departure_date
        if trip_query.departure_date <= Date.today
          Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR_MSG))
        end
        Success(trip_query:)
      rescue StandardError => e
        puts e.backtrace.join("\n")
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR_MSG))
      end

      def find_or_create_trips(input)
        if input[:trip_query].is_new
          create_trips_from_amadeus(input[:trip_query])
        else
          find_trips_from_database(input[:trip_query].id)
        end
      rescue StandardError => e
        puts e.backtrace.join("\n")
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR_MSG))
      end

      def create_trips_from_amadeus(trip_query)
        new_trips = Amadeus::TripMapper.new(App.config.AMADEUS_KEY, App.config.AMADEUS_SECRET).search(trip_query)
        ComfyWings::Repository::For.klass(Entity::Trip).create_many(new_trips)
          .then { |trips| Response::TripsList.new(trips) }
          .then { |list| Response::ApiResult.new(status: :ok, message: list) }
          .then { |result| Success(result) }
      end

      def find_trips_from_database(query_id)
        ComfyWings::Repository::For.klass(Entity::Trip).find_query_id(query_id)
          .then { |trips| Response::TripsList.new(trips) }
          .then { |list| Response::ApiResult.new(status: :ok, message: list) }
          .then { |result| Success(result) }
      end
    end
  end
end
