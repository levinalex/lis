require 'test/unit'
require 'mocha/api'
require 'aruba/cucumber'
require 'webmock/cucumber'

require 'lis'
require 'packet_io/test/mock_server'

WebMock.disable_net_connect!
World(Test::Unit::Assertions)

