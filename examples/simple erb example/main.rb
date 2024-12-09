# frozen_string_literal: true

require_relative '../../lib/httrb'
require 'erb'

Httrb.get('/home/') do
  file_path = File.join(__dir__, 'home.erb') # Ensure path is correct

  @test = 'test'

  Httrb::Response.erb(file_path, binding)
end

Httrb.start_blocking
