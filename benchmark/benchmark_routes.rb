# frozen_string_literal: true

# benchmark_routes.rb
require_relative '../lib/httrb'

Httrb.before_route do
  @test = 'rest'
end

# Define multiple routes for benchmarking
Httrb.get('/hello') { Httrb::Response.new(200, { 'Content-Type' => 'text/html' }, '<h1>Thing!</h1>') }
Httrb.get('/json') do
  Httrb::Response.json({ :name => 'Konata Izumi', 'age' => 16, 1 => 2, test: @test })
end
Httrb.get('/jsonvar/:variable/:test/:hello/') do |variable, test, hello|
  Httrb::Response.json({ :name => 'Konata Izumi', 'age' => 16, 1 => 2, :variable => variable, :second => test,
                         :last => hello, test: @test })
end

trap('INT') { Httrb.stop; exit }
trap('TERM') { Httrb.stop; exit }

Httrb.start_blocking(4567) # Start the server on port 4567
