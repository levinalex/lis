# http://all-thing.net/fibers-via-continuations
#
# this is an implementation of Ruby 1.9 Fibers with continuations
# it transparently falls back to real Fibers when they exist

if Object.const_defined?("Fiber")

  # that's the native implementation of fibers from Ruby 1.9
  #
  class CFiber
    def initialize &block
      @fiber = Fiber.new do
        block.call(self)
      end
    end

    def resume
      @fiber.resume
    end

    def yield
      Fiber.yield
    end
  end

else

  # that's an implementation of Fibers that's api-compatible with the version in
  # ruby 1.9 but which uses continuations
  #
  class CFiber
    def initialize(&block)
      @block = block
      callcc do |cc|
        @inside = cc
        return
      end
      @var = @block.call self
      @inside = nil
      @outside.call
    end

    def resume
      raise "dead cfiber called!" unless @inside
      callcc do |cc|
        @outside = cc
        @inside.call
      end
      @var
    end

    def yield(var=nil)
      callcc do |cc|
        @var = var
        @inside = cc
        @outside.call
      end
    end
  end

end

