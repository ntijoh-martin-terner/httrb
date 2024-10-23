require_relative 'spec_helper'
require_relative '../lib/http_server'
require 'net/http'
require 'uri'  # Add this to use the URI class

describe 'serve' do
  before do
    @server = HTTPServer.new(4567)
  end

  after do 
    @server.stop()
  end

  it 'adding route works' do
    @server.router.add_route("/thing/") { "<h1>Thing!</h1>" }
    @server.start()

    uri = URI('http://localhost:4567/thing/')

    response = Net::HTTP.get_response(uri)

    # Check if the content is what we expect
    assert_equal "200", response.code  # Status code should be 200
    assert_equal "<h1>Thing!</h1>", response.body  # Body should match the content
  end
end