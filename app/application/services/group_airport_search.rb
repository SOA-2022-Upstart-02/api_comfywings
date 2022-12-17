# frozen_string_literal: true

require 'dry/transaction'
require 'digest'

module ComfyWings
  module Service
    # Retrieves array of all currencies
    class GroupAirports
      include Dry::Transaction

      step :group_all

      private

      DB_ERR = 'We encountered an issue accessing the database.'

      def group_all(iata_code_letter)
        Repository::For.klass(Entity::Airport).find_from_start_letter(iata_code_letter)
          .then { |airport| Response::AirportsList.new(airport) }
          .then { |list| Response::ApiResult.new(status: :ok, message: list) }
          .then { |result| Success(result) }
      rescue StandardError => e
        puts e.backtrace.join("\n")
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR))
      end
    end
  end
end
