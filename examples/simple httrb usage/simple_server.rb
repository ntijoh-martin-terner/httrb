# frozen_string_literal: true

require_relative '../../lib/httrb'
require_relative '../../lib/response'

Httrb.before do |_request, _response|
  p 'hello'
end

Httrb.get('/foo/:variable/hello/:second-variable/:lastvariable') do |_params, variable, second, last|
  Httrb::Response.json({ :name => 'Konata Izumi', 'age' => 16, 1 => 2, :variable => variable, :second => second,
                         :last => last })
end
Httrb.get('/foo/') do |params|
  Httrb::Response.json({ :name => 'Konata Izumi', 'age' => 16, 1 => 2, params: params })
end

Httrb.start
