# frozen_string_literal: true

require_relative '../../lib/httrb'
require 'erb'

Httrb.get('/home/') do
  file_path = File.join(__dir__, 'home.erb') # Ensure path is correct
  file = File.open(file_path)
  file_contents = file.read

  rhtml = ERB.new(file_contents)

  @test = 'test'
  
  result = rhtml.result(binding)
  
  Httrb::Response.new(200, { 'Content-Type' => 'text/html' }, result)
end

Httrb.start_blocking
