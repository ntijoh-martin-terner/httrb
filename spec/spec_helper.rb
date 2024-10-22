require 'minitest/autorun'
require "minitest/reporters"
require 'webmock/minitest'

Minitest::Reporters.use! [Minitest::Reporters::SpecReporter.new, Minitest::Reporters::JUnitReporter.new]