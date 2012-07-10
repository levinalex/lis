$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../../lib')

require 'lis'

require 'mocha'
require 'yaml'
require 'aruba/cucumber'

require 'packet_io/test/mock_server'
require 'test/unit/assertions'
require 'webmock/cucumber'

World(Test::Unit::Assertions)

