# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:trip_queries) do
      primary_key :id
      foreign_key :currency_id,    :currencies
      String      :code,           unique: true, null: false # generate by 8 bit uuid
      foreign_key :origin_id,      :airports
      foreign_key :destination_id, :airports
      Date        :departure_date
      Date        :arrival_date
      Integer     :adult_qty
      Integer     :children_qty
      TrueClass   :is_one_way
      TrueClass   :is_new
    end
  end
end
