# frozen_string_literal: true

require 'minitest/autorun'

require_relative '../lib/response'

class TestResponse < Minitest::Test
  def test_initialize
    response = Httrb::Response.new(200, { 'Content-Type' => 'text/plain' }, 'Hello, world!')

    assert_equal 200, response.status

    assert_equal({ 'Content-Type' => 'text/plain' }, response.headers)

    assert_equal 'Hello, world!', response.body
  end

  def test_to_s
    response = Httrb::Response.new(200, { 'Content-Type' => 'text/plain' }, 'Hello, world!')

    expected = "HTTP/1.1 200\r\nContent-Type: text/plain\r\nContent-Length: 13\r\n\r\nHello, world!"

    assert_equal expected, response.to_s
  end

  def test_redirect
    response = Httrb::Response.redirect('/new_location')

    assert_equal 302, response.status

    assert_equal({ 'Location' => '/new_location', 'Content-Length' => '0' }, response.headers)

    assert_equal '', response.body

    assert_match(%r{HTTP/1.1 302\r\nLocation: /new_location\r\nContent-Length: 0\r\n\r\n}, response.to_s)
  end

  def test_not_found
    response = Httrb::Response.not_found

    assert_equal 404, response.status

    assert_equal({ 'Content-Type' => 'text/html' }, response.headers)

    assert_equal '404 Not Found', response.body

    assert_match(%r{HTTP/1.1 404\r\nContent-Type: text/html\r\nContent-Length: 13\r\n\r\n404 Not Found}, response.to_s)
  end

  def test_from_file_success
    path = 'test_file.txt'

    File.write(path, 'File content')

    response = Httrb::Response.from_file(path)

    assert_equal 200, response.status

    assert_equal({ 'Content-Type' => 'text/plain' }, response.headers)

    assert_equal 'File content', response.body
  ensure
    File.delete(path)
  end

  def test_from_file_not_found
    response = Httrb::Response.from_file('nonexistent_file.txt')

    assert_equal 404, response.status

    assert_equal({ 'Content-Type' => 'text/html' }, response.headers)

    assert_equal '404 Not Found', response.body
  end

  def test_json
    data = { message: 'Hello, world!' }

    response = Httrb::Response.json(data)

    assert_equal 200, response.status

    assert_equal({ 'Content-Type' => 'application/json' }, response.headers)

    assert_equal({ message: 'Hello, world!' }.to_json, response.body)
  end

  def test_json_custom_status
    data = { error: 'Something went wrong' }

    response = Httrb::Response.json(data, 500)

    assert_equal 500, response.status

    assert_equal({ 'Content-Type' => 'application/json' }, response.headers)

    assert_equal({ error: 'Something went wrong' }.to_json, response.body)
  end
end
