# frozen_string_literal: true

require_relative 'spec_helper'
require_relative '../lib/router_helper'

describe RouterHelper do
  include RouterHelper

  describe '#expand_directory_glob_patterns' do
    it 'expands directory glob patterns correctly' do
      example_content_path = File.expand_path(File.join(__dir__, '/example_content'))

      p example_content_path

      # Resolve paths
      result = expand_directory_glob_patterns(['./*'], example_content_path)

      # Get the expected paths and normalize them
      expected_patterns = {
        File.expand_path('./*',
                         example_content_path) => Dir[File.expand_path('./*', example_content_path)].map do |file|
                           File.expand_path(file)
                         end
      }

      # Normalize and compare
      result.each do |base_path, files|
        expect(File.expand_path(base_path)).to eq(File.expand_path(expected_patterns.keys.first))
        expect(files.map { |file| File.expand_path(file) }).to match_array(expected_patterns.values.first)
      end
    end
  end
end
