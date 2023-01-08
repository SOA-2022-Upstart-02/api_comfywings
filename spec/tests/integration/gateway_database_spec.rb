# frozen_string_literal: true

require_relative '../../helpers/spec_helper'
require_relative '../../helpers/vcr_helper'
require_relative '../../helpers/database_helper'
require 'securerandom'
require 'active_support'
require 'active_support/core_ext/date/calculations'

describe 'Integration Tests of AMADEUS API and Database' do
  VcrHelper.setup_vcr

  before do
    # Check request body as token and secret are not included in headers
    VcrHelper.configure_vcr_for_amadeus
  end

  after do
    VcrHelper.eject_vcr
    DatabaseHelper.wipe_database
  end

  describe 'Retrieve Currency By Currency Code' do
    it 'HAPPY: should be able to save currencies to database' do
      currency = ComfyWings::Repository::For.klass(ComfyWings::Entity::Currency).find_code('TWD')

      _(currency.code).must_equal('TWD')
      _(currency.name).must_equal('New Taiwan dollar')
    end

    it 'HAPPY: there should be 4 currencies: TWD USD EUR GBP' do
      reposit = ComfyWings::Repository::For.klass(ComfyWings::Entity::Currency)
      currencies = reposit.all
      _(currencies.size).must_equal(4)
    end
  end

  describe 'Retrive Airport by iata code' do
    it 'HAPPY: should be able to retrieve airports from database' do
      airport = ComfyWings::Repository::For.klass(ComfyWings::Entity::Airport).find_code('MAG')

      _(airport.airport_name).must_equal('Madang')
      _(airport.city_airport_name).must_equal('Madang')
      _(airport.country).must_equal('Papua New Guinea')
      _(airport.iata_code).must_equal('MAG')
    end

    it 'HAPPY: there should be a total of  5879 airports' do
      reposit = ComfyWings::Repository::For.klass(ComfyWings::Entity::Airport)
      airports = reposit.all
      _(airports.size).must_equal(5879)
    end

    it 'HAPPY: should be able to retrieve group of airports' do
      airport_list = ComfyWings::Repository::For.klass(ComfyWings::Entity::Airport).find_from_start_letter('M')
      _(airport_list[0].airport_name).must_equal('Madang')
      _(airport_list[0].city_airport_name).must_equal('Madang')
      _(airport_list[0].country).must_equal('Papua New Guinea')
      _(airport_list[0].iata_code).must_equal('MAG')
    end
  end

  describe 'Test TripQuery Repository' do
    it 'Test Save new TripQuery and find TripQuery code' do
      code = SecureRandom.uuid
      currency = ComfyWings::Repository::For.klass(ComfyWings::Entity::Currency).find_code('TWD')
      origin = ComfyWings::Repository::For.klass(ComfyWings::Entity::Airport).find_code('TPE')
      destination = ComfyWings::Repository::For.klass(ComfyWings::Entity::Airport).find_code('MAD')

      trip_query = ComfyWings::Entity::TripQuery.new(
        id: nil,
        code:,
        currency:,
        origin:,
        destination:,
        departure_date: Date.parse('2001-02-03'),
        arrival_date: Date.parse('2001-03-03'),
        adult_qty: 1,
        children_qty: 1,
        is_one_way: true,
        is_new: false
      )

      repository = ComfyWings::Repository::For.klass(ComfyWings::Entity::TripQuery)

      repository.create(trip_query)
      trip_query = repository.find_code(code)
      _(trip_query.origin.iata_code).must_equal('TPE')
      _(trip_query.currency.name).must_equal('New Taiwan dollar')
    end
  end

  describe 'Test Trip information' do
    it 'HAPPY: should provide correct trip attributes' do
      ComfyWings::Database::TripQueryOrm
        .insert(currency_id: 2, code: QUERY_CODE, origin_id: 1592, destination_id: 902,
                departure_date: Date.parse('2023-02-11'), arrival_date: Date.parse('2023-02-28'),
                adult_qty: 1, children_qty: 2, is_one_way: false, is_new: true)

      repository = ComfyWings::Repository::For.klass(ComfyWings::Entity::TripQuery)
      trip_query = repository.find_code(QUERY_CODE)
      trips = ComfyWings::Amadeus::TripMapper.new(AMADEUS_KEY, AMADEUS_SECRET)
        .search(trip_query)

      trip = trips[0]
      rebuilt_trips = ComfyWings::Repository::For.entity(trip).create_many(trips)
      rebuilt_trip = rebuilt_trips[0]
      _(rebuilt_trips.size).must_equal 59

      _(rebuilt_trip.currency.code).must_equal 'USD'
      _(rebuilt_trip.origin.iata_code).must_equal 'TPE'
      _(rebuilt_trip.destination.iata_code).must_equal 'MAD'
      _(rebuilt_trip.outbound_duration_form[:hours]).must_equal 28
      _(rebuilt_trip.outbound_duration_form[:minutes]).must_equal 25
      _(rebuilt_trip.inbound_duration_form[:hours]).must_equal 18
      _(rebuilt_trip.inbound_duration_form[:minutes]).must_equal 50
      _(rebuilt_trip.price).must_equal BigDecimal('3007')
      _(rebuilt_trip.outbound_departure_time).must_equal Time.parse('2023-02-11 13:55:00')
      _(rebuilt_trip.outbound_arrival_time).must_equal Time.parse('2023-02-12 11:20:00')
      _(rebuilt_trip.inbound_departure_time).must_equal Time.parse('2023-02-28 18:25:00')
      _(rebuilt_trip.inbound_arrival_time).must_equal Time.parse('2023-03-01 20:15:00')

      outbound_flight = rebuilt_trip.outbound_flights[0]
      _(outbound_flight.origin.iata_code).must_equal 'TPE'
      _(outbound_flight.destination.iata_code).must_equal 'BKK'
      _(outbound_flight.aircraft).must_equal 'BOEING 777-200/300'
      _(outbound_flight.number).must_equal 'LH-9729'
      _(outbound_flight.departure_time).must_equal Time.parse('2023-02-11 13:55:00')
      _(outbound_flight.arrival_time).must_equal Time.parse('2023-02-11 16:50:00')
      _(outbound_flight.cabin_class).must_equal 'ECONOMY'
      _(outbound_flight.duration_form[:hours]).must_equal 3
      _(outbound_flight.duration_form[:minutes]).must_equal 55
      refute(outbound_flight.is_return)

      inbound_flight = rebuilt_trip.inbound_flights[0]
      _(inbound_flight.origin.iata_code).must_equal 'MAD'
      _(inbound_flight.destination.iata_code).must_equal 'MUC'
      _(inbound_flight.aircraft).must_equal 'AIRBUS A321'
      _(inbound_flight.number).must_equal 'LH-1805'
      _(inbound_flight.departure_time).must_equal Time.parse('2023-02-28 18:25:00"')
      _(inbound_flight.arrival_time).must_equal Time.parse('2023-02-28 21:05:00')
      _(inbound_flight.cabin_class).must_equal 'ECONOMY'
      _(inbound_flight.duration_form[:hours]).must_equal 2
      _(inbound_flight.duration_form[:minutes]).must_equal 40
      assert(inbound_flight.is_return)
    end
  end
end
