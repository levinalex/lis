require 'optparse'

module LIS
  class Options < Hash
    attr_reader :opts

    def initialize(args)
      super()

      default_options = { :port => "/dev/ttyUSB0", :uri => "http://localhost/lis/" }
      self.merge!(default_options)

      @opts = OptionParser.new do |o|
        appname = File.basename($0)
        o.banner = "Usage: #{appname} [options]"

        o.on('-l, --listen PORT', 'which port to listen on (default: "/dev/ttyUSB0")') do |port|
          self[:port] = port
        end
        o.on('-e, --endpoint URI', 'HTTP endpoint (default: "http://localhost/lis/")') do |endpoint|
          self[:uri] = endpoint
        end
        o.on("-v", "--[no-]verbose", "Run verbosely") do |v|
          $VERBOSE = v
          self[:verbose] = v
        end
      end

      begin
        @opts.parse!(args)
        self[:project_name] = args.shift
      rescue OptionParser::ParseError => e
        self[:invalid_argument] = e.message
      end
    end
  end

  class Application
    def initialize(opts)
      @options = Options.new(opts)

      if @options[:invalid_argument]
        warn @options.opts
        exit 1
      end
    end

    def run!
      warn "listening on: #{@options[:port]}"
      port = File.open(@options[:port], "w+")
      LIS::InterfaceServer.new(port, @options[:uri]).run!
    end
  end

end