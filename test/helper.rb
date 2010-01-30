require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'ruby-debug'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'immulite'

class Test::Unit::TestCase
end


module Mock
  class Immulite
    def initialize(read, write)
      @read, @write = read, write
      @queue = Queue.new
      @thread = Thread.new do
        loop do
          action, data = @queue.pop

          case action
            when :close
              @write.close
              break
            when :write
              @write.write(data)
              @write.flush
            when :wait
              sleep data
          end
        end
      end
    end

    def write(string)
      @queue.push [:write, string]
      self
    end

    def wait(seconds = 0.02)
      @queue.push [:wait, seconds]
      self
    end

    def eof
      @queue.push [:close]
    end
  end

end