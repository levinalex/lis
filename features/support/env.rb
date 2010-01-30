$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../../lib')
require 'immulite'

require 'test/unit/assertions'

World(Test::Unit::Assertions)
