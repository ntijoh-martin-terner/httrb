# frozen_string_literal: true

require_relative 'spec_helper'
require_relative '../lib/http_server'
require 'net/http'
require 'uri' # Add this to use the URI class

describe 'serve' do # rubocop:disable Metrics/BlockLength
  before do
    @server = Httrb::HTTPServer.new(4567)
  end

  after do
    @server.stop
  end

  it 'adding route works' do
    @server.router.add_route('/thing/', 'GET') do
      Httrb::Response.new(200, { 'Content-Type' => 'text/html' }, '<h1>Thing!</h1>')
    end
    @server.start

    uri = URI('http://localhost:4567/thing/')

    response = Net::HTTP.get_response(uri)

    # Check if the content is what we expect
    assert_equal '200', response.code # Status code should be 200
    assert_equal '<h1>Thing!</h1>', response.body # Body should match the content
  end
  it 'serves static txt files' do
    @server.router.add_directory_route('/content/', 'GET', ['./example_content/'])
    @server.start

    uri = URI('http://localhost:4567/content/test.txt')

    response = Net::HTTP.get_response(uri)

    file = File.open('./spec/example_content/test.txt', 'r')
    file_content = file.read

    # Check if the content is what we expect
    assert_equal '200', response.code # Status code should be 200
    assert_equal file_content, response.body # Body should match the content
  end
  it 'serves static gif files' do
    @server.router.add_directory_route('/content/', 'GET', ['./example_content/'])
    @server.start

    uri = URI('http://localhost:4567/content/frog.gif')

    response = Net::HTTP.get_response(uri)

    file = File.open('./spec/example_content/frog.gif', 'rb')
    file_content = file.read

    # Check if the content is what we expect
    assert_equal '200', response.code # Status code should be 200
    assert_equal file_content, response.body # Status code should be 200
  end
  it 'serves static html files' do
    @server.router.add_directory_route('/content/', 'GET', ['./example_content/'])
    @server.start

    uri = URI('http://localhost:4567/content/stuff/test.html')

    response = Net::HTTP.get_response(uri)

    file = File.open('./spec/example_content/stuff/test.html', 'r')
    file_content = file.read

    # file_content.gsub!(/\r?\n/, "\r\n")

    # Check if the content is what we expect
    assert_equal '200', response.code # Status code should be 200
    assert_equal file_content, response.body # Status code should be 200
  end
  it 'returns 404 for nonexistent file' do
    @server.router.add_directory_route('/content/', 'GET', ['./example_content/'])
    @server.start

    uri = URI('http://localhost:4567/content/nonexistent.txt')

    response = Net::HTTP.get_response(uri)

    # Check if the content is what we expect
    assert_equal '404', response.code # Status code should be 200
  end
end
