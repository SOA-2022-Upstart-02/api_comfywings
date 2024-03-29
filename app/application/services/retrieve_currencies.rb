# frozen_string_literal: true

require 'dry/transaction'
require 'digest'

module ComfyWings
  module Service
    # Retrieves array of all currencies
    class RetrieveCurrencies
      # Service object has only one step, we include result mixin instead
      include Dry::Monads::Result::Mixin

      step :retrieve_all

      private

      DB_ERR = 'We encountered an issue accessing the database.'

      # deliberately :reek:TooManyStatements calling method retrieve_all
      def retrieve_all
        Repository::For.klass(Entity::Currency).all
          .then { |currency| Response::CurrenciesList.new(currency) }
          .then { |list| Response::ApiResult.new(status: :ok, message: list) }
          .then { |result| Success(result) }
      rescue StandardError => e
        puts e.backtrace.join("\n")
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR))
      end
    end
  end
end
