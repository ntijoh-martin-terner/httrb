# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/reporters'
require 'simplecov'

SimpleCov.start

Minitest::Reporters.use! [Minitest::Reporters::SpecReporter.new, Minitest::Reporters::JUnitReporter.new]
