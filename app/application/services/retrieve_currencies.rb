# frozen_string_literal: true

require 'dry/transaction'
require 'digest'

module ComfyWings
  module Service
    # Retrieves array of all currencies
    class RetrieveCurrencies
      include Dry::Transaction

      step :retrieve_all

      private

      NOT_FOUND_ERR = "Currencies not found."
      DB_ERR = "We encountered an issue accessing the database."

      def retrieve_all
        currency_list = Repository::For.klass(Entity::Currency).all
                        .then { |currency| Response::CurrenciesList.new(currency) }
                        .then { |list| Response::ApiResult.new(status: :ok, message: list) }
                        .then { |result| Success(result) }
      rescue StandardError => e
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR))
      end

    end
  end
end