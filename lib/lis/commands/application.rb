require 'optparse'

module LIS
  class Options < Hash
    attr_reader :opts

    def initialize(args)
      super()

      default_options = { :port => "/dev/null", :uri => "http://localhost:3000/lis" }
      self.merge!(default_options)

      @opts = OptionParser.new do |o|
        appname = File.basename($0)
        o.banner = "Usage: #{appname} [options]"

        o.on('--listen PORT', 'which port to listen on (default: "/dev/ttyUSB0")') do |port|
          self[:port] = port
        end
        o.on('--endpoint URI', 'HTTP endpoint (default: "http://localhost:3000/lis")') do |endpoint|
          self[:uri] = endpoint
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

      server  = LIS::Transfer::IOListener.new(File.open(@options[:port], "w+"))
      packets = LIS::Transfer::PacketizedProtocol.new(server)

      app_protocol = LIS::Transfer::ApplicationProtocol.new(packets)
      interface    = WorklistManagerInterface.new("http://localhost:3000/liaison/")

      app_protocol.on_request do |device_name, barcode|
        interface.load_requests(device_name, barcode)
      end
      app_protocol.on_result do |*args|
        interface.send_result(*args)
      end

      server.run!
    end
  end

end