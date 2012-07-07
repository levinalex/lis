require 'rubygems'
require 'test/unit'
require 'webmock/test_unit'
require 'shoulda'
require 'mocha'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'lis'

WebMock.disable_net_connect!

class Test::Unit::TestCase
end

