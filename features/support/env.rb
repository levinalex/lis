$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../../lib')
require 'lis'

require 'packet_io/test/mock_server'
require 'test/unit/assertions'
require 'webmock/cucumber'

World(Test::Unit::Assertions)

