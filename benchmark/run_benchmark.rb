# frozen_string_literal: true

require 'net/http'
require 'benchmark'

# Benchmark parameters
url_base = 'http://localhost:4567'
routes = ['/hello', '/json', '/test.html', '/jsonvar/variable1/variable2/variable3']
requests_per_route = 1000

puts "Starting benchmark for routes: #{routes.join(', ')}"
Benchmark.bm do |bm|
  routes.each do |route|
    uri = URI("#{url_base}#{route}")

    bm.report("Benchmarking #{route}") do
      requests_per_route.times do
        Net::HTTP.get(uri) # Send GET request
      end
    end
  end
end
