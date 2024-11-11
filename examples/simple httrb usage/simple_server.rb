# frozen_string_literal: true

require_relative '../../lib/httrb'
require_relative '../../lib/response'

Httrb.before do |_request, _response|
  p 'hello'
end

Httrb.get('/foo/bar/baz') do
  Response.json({ :name => 'Konata Izumi', 'age' => 16, 1 => 2 })
end

Httrb.start
