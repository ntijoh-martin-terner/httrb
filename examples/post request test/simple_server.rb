# frozen_string_literal: true

require_relative '../../lib/httrb'
# require_relative '../../lib/response'

Httrb.get('/main') do
  test_html_path = File.expand_path(File.join(__dir__, '/test.html'))
  Httrb::Response.from_file(test_html_path)
  # Httrb::Response.json({ :name => 'Konata Izumi', 'age' => 16, 1 => 2, params: params })
end
Httrb.post('/login') do
  p params
  Httrb::Response.json({ :name => 'Konata Izumi', params: params })
end

Httrb.start_blocking
