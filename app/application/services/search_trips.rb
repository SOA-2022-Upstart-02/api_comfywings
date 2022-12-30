# frozen_string_literal: true

require 'dry/transaction'
require 'digest'

module ComfyWings
  module Service
    # Retrieves array of trips by tripQuery code
    class SearchTrips
      include Dry::Transaction

      step :valid_trip_query_exist
      step :valid_trip_query_status
      step :request_update_worker
      step :find_or_create_trips

      private

      DB_ERR_MSG = 'Having trouble accessing the database'
      EXPIRED_MSG = 'This query is expired'
      NOT_FOUND_MSG = 'Undefined query'

      # deliberately :reek:TooManyStatements calling method valid_trip_query_exist
      def valid_trip_query_exist(query_code)
        trip_query = Repository::For.klass(Entity::TripQuery).find_code(query_code)
        if trip_query
          Success(trip_query)
        else
          Failure(Response::ApiResult.new(status: :not_found, message: NOT_FOUND_MSG))
        end
      rescue StandardError => e
        puts e.backtrace.join("\n")
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR_MSG))
      end

      # deliberately :reek:TooManyStatements calling method valid_trip_query_status
      def valid_trip_query_status(trip_query)
        if trip_query.departure_date <= Date.today
          Failure(Response::ApiResult.new(status: :bad_request, message: EXPIRED_MSG))
        else
          Success(trip_query)
        end
      rescue StandardError => e
        puts e.backtrace.join("\n")
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR_MSG))
      end

      def request_update_worker(trip_query)
        queue = Messaging::Queue.new(App.config.UPDATE_QUEUE_URL, App.config)
        queue.send(trip_query.code)
        Success(trip_query)
      rescue StandardError => e
        puts e.backtrace.join("\n")
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR_MSG))
      end

      def find_or_create_trips(trip_query)
        if trip_query.is_new
          create_trips_from_amadeus(trip_query)
        else
          find_trips_from_database(trip_query.id)
        end
      rescue StandardError => e
        puts e.backtrace.join("\n")
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR_MSG))
      end

      # deliberately :reek:TooManyStatements calling method create_trips_from_amadeus
      # deliberately :reek:DuplicateMethodCall calling method create_trips_from_amadeus
      def create_trips_from_amadeus(trip_query)
        new_trips = Amadeus::TripMapper.new(App.config.AMADEUS_KEY, App.config.AMADEUS_SECRET).search(trip_query)
        update_query_status(trip_query.id)
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

      def update_query_status(id)
        ComfyWings::Repository::For.klass(Entity::TripQuery).update_searched(id)
      end
    end
  end
end
