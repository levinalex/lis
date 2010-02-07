require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'lib/mock_server'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'lis'

class Test::Unit::TestCase
end

