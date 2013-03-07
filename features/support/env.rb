$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../../lib')

require 'lis'

require 'mocha/setup'
require 'yaml'
require 'aruba/cucumber'

require 'packet_io/test/mock_server'
require 'test/unit/assertions'
require 'webmock/cucumber'

WebMock.disable_net_connect!

World(Test::Unit::Assertions)

