# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'simplecov'
SimpleCov.start

require 'yaml'

require 'minitest/autorun'
require 'minitest/rg'
require 'vcr'
require 'webmock'

require_relative '../../require_app'
require_app

AMADEUS_KEY = ComfyWings::App.config.AMADEUS_KEY
AMADEUS_SECRET = ComfyWings::App.config.AMADEUS_SECRET

CORRECT = YAML.safe_load(File.read('spec/fixtures/flight_results.yml'))
CORRECT_AIRPORT = YAML.safe_load(File.read('spec/fixtures/airport_results.yml'))

QUERY_CODE = 'temp_for_test'