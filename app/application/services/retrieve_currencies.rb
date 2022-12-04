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

      NOT_FOUND_ERR = 'Currencies not found.'
      DB_ERR = 'We encountered an issue accessing the database.'

      def retrieve_all
        currency_list = Repository::For.klass(Entity::Currency).all

        if currency_list
          Success(Response::ApiResult.new(status: :ok, message: currency_list))
        else
          Failure(Response::ApiResult.new(status: :not_found, message: NOT_FOUND_ERR))
        end
      rescue StandardError => e
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR))
      end
    end
  end
end
