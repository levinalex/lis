require 'rubygems'
require 'test/unit'
require 'webmock/test_unit'
require 'shoulda'
require 'mocha/setup'

require 'lis'

$VERBOSE = true

WebMock.disable_net_connect!

class Test::Unit::TestCase
end

