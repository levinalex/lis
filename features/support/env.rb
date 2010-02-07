$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../../lib')
require 'lis'

require 'test/unit/assertions'

World(Test::Unit::Assertions)
