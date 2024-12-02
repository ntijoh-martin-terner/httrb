# frozen_string_literal: true

require_relative '../../lib/httrb'
# require_relative '../../lib/response'

Httrb.before_route do
  @test = 'rest'
end

Httrb.after do
  if response.status == 404
    next Httrb::Response.json({ :error => "not Found" })
  end
end

Httrb.get('/foo/:variable/hello/:second-variable/:lastvariable') do |variable, second, last|
  Httrb::Response.json({ :name => 'Konata Izumi', 'age' => 16, 1 => 2, :variable => variable, :second => second,
                         :last => last, test: @test })
end

Httrb.get('/foo/') do
  Httrb::Response.json({ :name => 'Konata Izumi', 'age' => 16, 1 => 2, params: params })
end

Httrb.any('/help/') do |_params|
  Httrb::Response.from_file('absolute_path')
end

Httrb.start_blocking
