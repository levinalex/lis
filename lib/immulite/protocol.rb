
module LIS::Transfer

  # splits a tream into separate packets
  #
  class PacketizedProtocol < LIS::Transfer::BaseProtocol
    RX = /(:?
          \004 | # ENQ - start a transaction
          \005 | # EOT - ends a transaction
          (:?\002 .*? \015 \003 .+? \015 \012)) # a message with a checksum
        /xm
  end

  # passes everything between ENQ .. EOT to higher layers
  #
  class TransmissionSession < LIS::Transfer::BaseProtocol
    def initialize(parent)
      @parent = parent
      @in = false
    end


    def receive(memo, data, &block)
      text = memo + data

      start = @in ? "^" : "E"


      /#{@in ? "^" : "E"}/

      if @inside_transmission
        inside, outside = text.split
        if match
          @memo = parent.receive(@memo, match)
        else
          @memo = parent.receive(@memo, text, &block)
        end
      else

      end
    end
  end
end