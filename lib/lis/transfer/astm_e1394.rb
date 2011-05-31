module LIS::Transfer

  module ASTM
  end

  # splits a stream into lis packets and only lets packets through
  # that are inside a session delimited by ENQ .. EOT
  #
  # check the checksum and do acknowledgement of messages
  #
  # forwards the following events:
  #
  # - :message, String :: when a message is received
  # - :idle            :: when a transmission is finished (after EOT is received)
  #
  class ASTM::E1394 < ::PacketIO::Base
    ACK = "\006"
    NAK = "\025"
    ENQ = "\005"
    EOT = "\004"

    # format of a message
    RX = /(?:
          \005 | # ENQ - start a transaction
          \004 | # EOT - ends a transaction
          \005 | # ACK
          \025 | # NAK
          (?:\002 (.) (.*?) \015 \003 (.+?) \015 \012) # a message with a checksum
                #  |   |               `-- checksum
                #  |   `------------------ message
                #  `---------------------- frame number
          )
        /xm

    def initialize(*args)
      super(*args)
      @memo = ""
      @inside_transmission = false
    end

    def receive(data)
      scanner = StringScanner.new(@memo + data)
      while scanner.scan_until(RX)
        match = scanner.matched
        case match
          when ENQ then transmission_start
          when EOT then transmission_end
          when ACK, NAK then nil
        else
          received_message(match)
          write :ack
        end
      end
      @memo = scanner.rest
      nil
    end

    def write(type, data = nil)
      str = case type
        when :ack then ACK
        when :nak then NAK
        when :begin then
          @frame_number = 0
          ENQ
        when :idle then EOT
        when :message then
          @frame_number = (@frame_number + 1) % 8
          self.class.wrap_message(data, @frame_number)
      else
        raise ArgumentError
      end
      super(str)
    end


    private

    def self.message_from_string(string)
      match = string.match(RX)

      frame_number, data, checksum = match[1 .. 3]

      expected_checksum = (frame_number + data).each_byte.inject(16) { |a,b| (a+b) % 0x100 }
      actual_checksum   = checksum.to_i(16)

      raise "checksum mismatch: expected %03x got %03x" % [expected_checksum, actual_checksum] unless expected_checksum == actual_checksum
      return [frame_number.to_i, data]
    end

    def self.wrap_message(string, frame_number)
      frame_number = (frame_number % 8).to_s
      checksum = (frame_number + string).each_byte.inject(16) { |a,b| (a+b) % 0x100 }
      checksum = checksum.to_s(16).upcase.rjust(2,"0")

      "\002#{frame_number}#{string}\015\003#{checksum}\015\012"
    end


    def received_message(message)
      return false unless @inside_transmission
      frame_number, message = *self.class.message_from_string(message)
      forward(:message, message)
    end

    def transmission_start
      return false if @inside_transmission
      write :ack
      forward :begin
      @inside_transmission = true
      true
    end

    def transmission_end
      return false unless @inside_transmission
      forward :idle
      @inside_transmission = false
      true
    end
  end
end

