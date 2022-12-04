# frozen_string_literal: true

require 'dry/transaction'
require 'digest'

module ComfyWings
  module Service
    # Obtain airport information
    class SearchAirport
      include Dry::Transaction

      step :search_airport

      private

      DB_ERR_MSG = 'Having trouble accessing the database'
      NOT_FOUND_ERR = 'Airport code incorrect'

      def search_airport(input)
        # TODO: update to search_airport_by_code and return all data attributes

        airport_info = Repository::For.klass(Entity::Currency).find_code(input)

        if airport_info
          Success(Response::ApiResult.new(status: :ok, message: airport_info))
        else
          Failure(Response::ApiResult.new(status: :incorrect_airport_code, message: NOT_FOUND_ERR))
        end
      rescue StandardError => e
        puts e.backtrace.join("\n")
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR_MSG))
      end
    end
  end
end