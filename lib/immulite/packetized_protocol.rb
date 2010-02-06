
module LIS::Transfer

  # splits a stream into immulite packets and only lets packets through
  # that are inside a session delimited by ENQ .. EOT
  #
  # check the checksum and acknowledgement of messages
  #
  # forwards everything else to higher layers
  #
  class PacketizedProtocol < Base
    ACK = "\006"
    NAK = "\025"
    ENQ = "\005"
    EOT = "\004"

    RX = /(?:
          \005 | # ENQ - start a transaction
          \004 | # EOT - ends a transaction
          (?:\002 (.*?) \015 \003 (.+?) \015 \012)) # a message with a checksum
        /xm

    def initialize(*args)
      super(*args)
      @memo = ""
      @inside_transmission = false
      @on_transmission_start = lambda {}
      @on_transmission_end = lambda {}
    end

    def start_of_transmission(&block)
      @on_transmission_start = block
    end

    def end_of_transmission(&block)
      @on_transmission_end = block
    end

    def receive(data)
      scanner = StringScanner.new(@memo + data)
      while match = scanner.scan(RX)
        case match
          when ENQ then transmission_start
          when EOT then transmission_end
        else
          received_message(match)
        end
      end
      @memo = scanner.rest
      nil
    end


    private

    def self.message_from_string(string)
      match = string.match(RX)
      data = match[1]
      checksum = match[2]

      expected_checksum = data.to_enum(:each_byte).inject(16) { |a,b| (a+b) % 0x100 }
      actual_checksum   = checksum.to_i(16)

      raise "checksum mismatch" unless expected_checksum == actual_checksum
      return data
    end

    def received_message(message)
      return false unless @inside_transmission
      forward(self.class.message_from_string(message))
    end

    def transmission_start
      return false if @inside_transmission
      @on_transmission_start.call if @on_transmission_start
      write ACK
      @inside_transmission = true
      true
    end

    def transmission_end
      return false unless @inside_transmission
      @on_transmission_end.call
      @inside_transmission = false
      true
    end
  end

end