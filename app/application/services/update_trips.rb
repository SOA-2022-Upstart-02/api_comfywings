# frozen_string_literal: true

require 'dry/transaction'

module ComfyWings
  module Service
    # Update Trips from not expired TripQuery
    class UpdateTrip
      include Dry::Transaction

      step :remove_old_trips
      step :get_new_trips
      step :create_new_trips 

      private

      DB_ERR = 'Having trouble accessing the database'
      UPDATE_ERR = 'Failed to get the data from api'

      def remove_old_trips(code)
        trip_query = Repository::For.klass(Entity::TripQuery).find_code(code)
        Repository::For.klass(Entity::Trip).delete_query_id(trip_query.id)
        Success(trip_query)
      rescue StandardError => e
        print_error(e)
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR))
      end

      # Helper methods for steps
      def get_new_trips(trip_query)
        new_trips = Amadeus::TripMapper.new(App.config.AMADEUS_KEY, App.config.AMADEUS_SECRET).search(trip_query)
        update_query_status(trip_query.id)
        Success(new_trips)
      rescue StandardError => e
        print_error(e)
        Failure(Response::ApiResult.new(status: :internal_error, message: UPDATE_ERR))
      end

      def create_new_trips(new_trips)
        ComfyWings::Repository::For.klass(Entity::Trip).create_many(new_trips)        
        Success(Response::ApiResult.new(status: :ok, message: 'update trips success!'))
      end

      def print_error(error)
        App.logger.error [error.inspect, error.backtrace].flatten.join("\n")
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR))
      end

      def update_query_status(id)
        ComfyWings::Repository::For.klass(Entity::TripQuery).update_searched(id)
      end
    end
  end
end
