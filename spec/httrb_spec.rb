# frozen_string_literal: true

require_relative 'spec_helper'
# require_relative '../lib/httrb'
require 'net/http'
require 'uri'
load File.expand_path('../lib/httrb.rb', __dir__)

describe 'Httrb Framework' do
  before do
    Httrb.clear_routes

    # Define routes and filters before starting the server
    Httrb.before do
      @test = 'rest'
    end

    Httrb.after do
      # Optionally log or modify the response
    end

    Httrb.get('/foo/:variable/hello/:second-variable/:lastvariable') do |variable, second, last|
      Httrb::Response.json({ name: 'Konata Izumi', age: 16, variable: variable, second: second, last: last, test: @test })
    end

    Httrb.get('/foo/') do
      Httrb::Response.json({ name: 'Konata Izumi', age: 16, params: params })
    end

    Httrb.any('/help/') do |_params|
      Httrb::Response.new(200, { 'Content-Type' => 'text/html' }, 'Help content goes here')
    end

    # Start the server
    Httrb.start(4567, false)
    # sleep(0.5) # Allow the server to start
  end

  after do
    # Stop the server after tests
    Httrb.stop
    # sleep(0.5)
  end

  it 'executes the before filter' do
    uri = URI('http://localhost:4567/foo/variable/hello/second/last')

    response = Net::HTTP.get_response(uri)

    assert_equal '200', response.code
    body = JSON.parse(response.body)

    # Ensure the before filter was applied
    assert_equal 'rest', body['test']
  end

  it 'handles a GET route with variables' do
    uri = URI('http://localhost:4567/foo/variable/hello/second/last')

    response = Net::HTTP.get_response(uri)

    assert_equal '200', response.code
    body = JSON.parse(response.body)

    # Verify the response content
    assert_equal 'Konata Izumi', body['name']
    assert_equal 16, body['age']
    assert_equal 'variable', body['variable']
    assert_equal 'second', body['second']
    assert_equal 'last', body['last']
  end

  it 'handles a simple GET route without variables' do
    uri = URI('http://localhost:4567/foo/')

    response = Net::HTTP.get_response(uri)

    assert_equal '200', response.code
    body = JSON.parse(response.body)

    # Verify the response content
    assert_equal 'Konata Izumi', body['name']
    assert_equal 16, body['age']
    assert body['params'].is_a?(Hash)
  end

  it 'handles routes with any HTTP method' do
    uri = URI('http://localhost:4567/help/')
    response = Net::HTTP.get_response(uri)

    assert_equal '200', response.code
    assert_equal 'Help content goes here', response.body
  end

  it 'returns 404 for unknown routes' do
    uri = URI('http://localhost:4567/nonexistent')
    response = Net::HTTP.get_response(uri)

    assert_equal '404', response.code
  end
end
