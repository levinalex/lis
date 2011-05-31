module LIS
  class InterfaceServer
    def initialize(port, http_endpoint)
      @server  = PacketIO::IOListener.new(port)
      @packets = LIS::Transfer::ASTM::E1394.new(@server)

      app_protocol = LIS::Transfer::ApplicationProtocol.new(@packets)
      interface    = WorklistManagerInterface.new(http_endpoint)

      app_protocol.on_request do |device_name, barcode|
        interface.load_requests(device_name, barcode)
      end
      app_protocol.on_result do |*args|
        interface.send_result(*args)
      end
    end

    def run!
      warn "listener started" if $VERBOSE
      @server.run!
    end
  end
end
