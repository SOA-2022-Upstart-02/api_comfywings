# frozen_string_literal: true

require_relative '../../helpers/spec_helper'
require_relative '../../helpers/vcr_helper'
require_relative '../../helpers/database_helper'
require 'rack/test'

def app
  ComfyWings::App
end

describe 'Test API routes' do
  include Rack::Test::Methods

  VcrHelper.setup_vcr

  before do
    VcrHelper.configure_vcr_for_amadeus
  end

  after do
    VcrHelper.eject_vcr
    DatabaseHelper.wipe_database
  end

  describe 'Search trips route' do
    it 'should be able to find trips' do
      ComfyWings::Database::TripQueryOrm
        .insert(currency_id: 2, code: QUERY_CODE, origin: 'TPE', destination: 'MAD',
                departure_date: Date.parse('2022-12-31'), arrival_date: Date.parse('2023-01-29'),
                adult_qty: 1, children_qty: 2, is_one_way: false, is_new: true)

      get "/api/trips/#{QUERY_CODE}"
      _(last_response.status).must_equal 200

      response = JSON.parse(last_response.body)
      trips = response['trips']
      _(trips.count).must_equal 58
      trip = trips.first
      _(trip['outbound_duration_form']['hours']).must_equal 47
      # _(trip['currency']['code']).must_equal 'USD'
      # _(trip['origin']['iata_code']).must_equal 'TPE'
      # _(trip['destination']['iata_code']).must_equal 'MAD'
      _(trip['outbound_duration_form']['hours']).must_equal 47
      _(trip['outbound_duration_form']['minutes']).must_equal 10
      _(trip['inbound_duration_form']['hours']).must_equal 18
      _(trip['inbound_duration_form']['minutes']).must_equal 50
      _(trip['price_form']).must_equal '2895.90'
      _(trip['outbound_departure_time']).must_equal '2022-12-31 21:15:00 +0800'
      _(trip['outbound_arrival_time']).must_equal '2023-01-02 13:25:00 +0800'
      _(trip['inbound_departure_time']).must_equal '2023-01-29 18:25:00 +0800'
      _(trip['inbound_arrival_time']).must_equal '2023-01-30 20:15:00 +0800'

      _(trip['outbound_flights'].count).must_equal 3
      _(trip['inbound_flights'].count).must_equal 3
    end

    it 'should report error for invalid query code' do
      get '/api/trips/code_not_exist'
      _(last_response.status).must_equal 404
      _(JSON.parse(last_response.body)['status']).must_include 'not'
    end
  end

  describe 'Currencies route' do
    it 'should be able to retrieve all available currencies' do
      get '/currency/all'
      _(last_response.status).must_equal 200
      currencies = JSON.parse(last_response.body)['currencies']
      _(currencies.count).must_equal 4
    end
  end

  describe 'single Airport route' do
    it 'should be able to retrieve information about an airport' do
      get "airport/#{IATA_CODE}"
      _(last_response.status).must_equal 200
      airport = JSON.parse(last_response.body)
      _(airport.count).must_equal 4 #  number of airport information returned
    end

    it 'should report error for invalid iata_code' do
      get "airport/#{QUERY_CODE}"
      _(last_response.status).must_equal 404
      _(JSON.parse(last_response.body)['status']).must_include 'not'
    end
  end

   describe 'multiple Airport route based on starting letter' do
    it 'should be able to retrieve a list airports' do
      get "airportlist/#{IATA_CODE_LETTER}"
      _(last_response.status).must_equal 200
      airport = JSON.parse(last_response.body)['airports']
      _(airport.count).wont_be_nil
    end

    it 'should report error for invalid iata_code letter' do
      get "airportlist/#{IATA_CODE_NUMBER}"
      _(last_response.status).must_equal 404
    end
  end
end
