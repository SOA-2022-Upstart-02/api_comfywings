# frozen_string_literal: true

require 'dry/transaction'
require 'digest'

module ComfyWings
  module Service
    class AddTripQuery
      include Dry::Transaction

      step :validate_trip_query
      step :retrieve_trip_query

      private

      DB_ERR = 'Cannot access database'

      def validate_trip_query(input)
        new_trip_query = input.call
        if new_trip_query.success?
          Success(new_trip_query.value!)
        else
          Failure(list_request.failure)
        end
      end

      def retrieve_trip_query(input)
        unless (trip_query = query_in_database(input))
          trip_query = Repository::For.klass(Entity::TripQuery).create(create_trip_query_entity(input))
        end
        Success(Response::ApiResult.new(status: :ok, message: trip_query))
      rescue StandardError => e
        puts e.backtrace.join("\n")
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR))
      end

      def query_in_database(input)
        code = Digest::MD5.hexdigest input.to_s
        Repository::For.klass(Entity::TripQuery).find_code(code)
      end

      def create_trip_query_entity(trip_request) # rubocop:disable Metrics/MethodLength
        currency = ComfyWings::Repository::For.klass(ComfyWings::Entity::Currency).find_code(trip_request['currency'])
        code = Digest::MD5.hexdigest trip_request.to_s
        ComfyWings::Entity::TripQuery.new(
          id: nil,
          code:,
          currency:,
          origin: trip_request['origin'],
          destination: trip_request['destination'],
          departure_date: Date.parse(trip_request['departure_date']),
          arrival_date: Date.parse(trip_request['arrival_date']),
          adult_qty: trip_request['adult_qty'],
          children_qty: trip_request['children_qty'],
          is_one_way: trip_request['is_one_way'],
          is_new: true
        )
      end
    end
  end
end
