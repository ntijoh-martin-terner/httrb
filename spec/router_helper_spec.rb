# frozen_string_literal: true

require_relative 'spec_helper'
require_relative '../lib/router_helper'

describe RouterHelper do
  include RouterHelper

  describe '#get_request_variables' do
    it 'gets request variables' do
      get_request_variables('/:test/:test2/', '/abc/bcd')
    end
  end
  describe '#expand_directory_glob_patterns' do
    it 'expands directory glob patterns correctly' do
      example_content_path = File.expand_path(File.join(__dir__, '/example_content'))

      # Resolve paths
      result = expand_directory_glob_patterns(['./*'], example_content_path)

      paths = result[File.join(example_content_path, '/*')]

      # Normalize and compare
      assert_equal File.join(example_content_path, '/frog.gif'), paths[0]
      assert_equal File.join(example_content_path, '/stuff'), paths[1]
      assert_equal File.join(example_content_path, '/sv.png'), paths[2]
      assert_equal File.join(example_content_path, '/test.txt'), paths[3]
    end
    it 'gets matching pattern' do
      example_content_path = File.expand_path(File.join(__dir__, '/example_content'))

      patterns = { File.join(example_content_path) => [File.join(example_content_path, '/frog.gif'),
                                                       File.join(example_content_path, '/stuff/test.html')] }

      # Resolve paths
      matching_pattern_frog = get_matching_pattern(patterns, '/', '/frog.gif')
      matching_pattern_stuff_html = get_matching_pattern(patterns, '/', '/stuff/test.html')

      # Normalize and compare
      assert_equal File.join(example_content_path, '/frog.gif'), matching_pattern_frog
      assert_equal File.join(example_content_path, '/stuff/test.html'), matching_pattern_stuff_html
    end
    it 'gets request variables' do
      assert_equal %w[hey that], get_request_variables('/:hello/:this/', '/hey/that/')
      assert_equal %w[hey that], get_request_variables('/notvar/:hello/:this/notvar/', '/notvar/hey/that/notvar/')
      assert_equal nil, get_request_variables('/notvar/:hello/:this/notvar/', '/notvar/hey/that/notvarw/')
    end
  end
end
