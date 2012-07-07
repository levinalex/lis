module LIS
  class InterfaceServer
    def self.listen(port, http_endpoint)
      interface = PacketIO::IOListener.new(port)
      new(interface, http_endpoint)
    end

    def self.create(*args)
      new(*args)
    end


    def initialize(server, http_endpoint, protocol_stack = [LIS::Transfer::ASTM::E1394, LIS::Transfer::ApplicationProtocol])
      @server = server
      protocol = protocol_stack.inject(server) { |i,klass| klass.new(i) }
      interface = HTTPInterface.new(http_endpoint)


      protocol.on_request do |device_name, barcode|
        interface.load_requests(device_name, barcode)
      end
      protocol.on_result do |device_name, patient, order, result|
        interface.send_result(device_name, order, result)
      end
    end

    def run!
      warn "listener started" if $VERBOSE
      @server.run!
    end


    class << self
      private :new
    end
  end
end

