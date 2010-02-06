
module LIS::Transfer

  # splits a stream into immulite packets and only lets packets through
  # that are inside a session delimited by ENQ .. EOT
  #
  # forwards everything else to higher layers
  #
  class PacketizedProtocol < LIS::Transfer::BaseProtocol
    RX = /(:?
          \004 | # ENQ - start a transaction
          \005 | # EOT - ends a transaction
          (:?\002 .*? \015 \003 .+? \015 \012)) # a message with a checksum
        /xm

    def start_of_transmission(&block)
      @on_transmission_start = block
    end

    def end_of_transmission(&block)
      @on_transmission_end = block
    end

    def receive(data, &block)
      scanner = StringScanner.new(@memo + data)
      while match = scanner.scan(RX)
        transmission_start if match == "\004"
        transmission_end if match == "\005"
      end
      @memo = scanner.rest
      nil
    end


    private

    def transmission_start
      return false if @inside_transmission
      @on_transmission_start.call if @on_transmission_start
      @inside_transmission = true
    end

    def transmission_end
      return false unless @inside_transmission
      @on_transmission_end.call
      @inside_transmission = false
    end
  end

end