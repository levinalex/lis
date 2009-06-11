require 'rubygems'
require 'serial_interface'

module Diasorin
  module Liaison

    class Interface < PacketIO

      def initialize(read, write=read, options = {}, &blk)
        super(LiaisonProtocol, read, write, options)

        # define default handlers for import/export of patients
        # and results
        #
        @on_order_request = lambda { nil }

        # is called whenever a result is sent
        #
        @on_result = lambda { |patient, order, result| }

        yield self if block_given?

        add_sender( {
          :message_header => Packets::MessageHeaderRecord,
          :patient => Packets::PatientInformationRecord,
          :order => Packets::TestOrderRecord,
          :terminator => Packets::MessageTerminatorRecord
        } )

        add_receiver :message_header => Packets::MessageHeaderRecord do |p|
          # delete the list of patients
          @patient_information ||= {}
        end

        add_receiver :patient_record => Packets::PatientInformationRecord do |p|
          @last_order_packet = nil
          @last_result_record = nil

          @last_patient_packet = p
        end

        add_receiver :comment => Packets::CommentRecord do |p|
          @on_result.call(@last_patient_packet, @last_order_packet, @last_result_record, p)
        end

        add_receiver :order => Packets::TestOrderRecord do |p|
          @last_result_record = nil

          @last_order_packet = p
        end

        add_receiver :test_result => Packets::ResultRecord do |p|
          @last_result_record = p
          @on_result.call(@last_patient_packet, @last_order_packet, @last_result_record)
        end


        add_receiver :request_information => Packets::RequestInformationSegment do |p|
          puts "RequestInformation: #{p.inspect}"

          @patient_information ||= {}
          requests = @on_order_request.call(p.starting_range)
          @patient_information[p.sequence_number] = requests if requests

          @mode = :request_information
        end

        add_receiver :ack => Packets::Acknowledge do |p|
          if @mode == :request_information
            @mode = @transmitting
            send_packet(:message_header, "HOST", "Liaison")
            transmit_requests
          else
            # keep on sending
          end
        end

        add_receiver :nack => Packets::NotAcknowledge do |p|
          puts "Nack!"
          raise "NACK received"
        end

        add_receiver :message_terminator => Packets::MessageTerminatorRecord do |p|
          puts "got MessageTerminatorRecord"
          if @mode == :request_information
            puts "should now send information"
            # initiate transfer (ENQ)
            send_packet("\x05", :raw => true)
          end
        end

        run
      end

      def on_order_request(&blk)
        @on_order_request = blk
      end
      def on_result(&blk)
        @on_result = blk
      end

      def transmit_requests
        @patient_information.each do |sequence_nr, data|
          p "sequence: #{sequence_nr.inspect}"
          p "data: #{data.inspect}"
          send_packet(:patient, sequence_nr, data["patient"]["number"], data["patient"]["last_name"], data["patient"]["first_name"])
          data["types"].each do |request|
            send_packet(:order, sequence_nr, data["id"], request)
          end
        end
        send_packet(:terminator, "1")
        # EOT
        send_packet("\x04", :raw => true)

        @mode = :neutral
      end

    end


    class LiaisonProtocol
      STX = 0x02 # STX
      ETX = 0x03  # ETX
      NACK = 0x15 # NACK
      ACK = 0x06 # ACK
      ENQ = 0x05 # ENQ
      CR = 0x0d
      LF = 0x0a
      EOT = 0x04

      def initialize(send_callback, receive_callback, options = {})
        @send_callback, @receive_callback = send_callback, receive_callback
        @packet_buffer = ""
        @send_buffer = []
        @checksum = 0
        @frame_number = 1
        @state = :neutral
      end

      def self.checksum_valid?(string, expected)
        sum = string.to_enum(:each_byte).inject(ETX) { |s,v| s+v } % 0x100
        if sum == expected
          return true
        else
          raise ::SerialProtocol::ChecksumMismatch, "expected #{expected}, got #{sum}"
        end
      end

      def get_packet(str)
        @receive_callback.call(str)
      end

      def add_char_to_packet(char)

        case @state
        when :neutral
          if char == ENQ # establishment
            send_packet(ACK.chr, :raw => true)
            @state = :transfer_begin
          elsif char == ACK
            get_packet(ACK.chr)
          elsif char == NACK
            get_packet(NACK.chr)
          else
            # receive and ignore partial data
          end
        when :transfer_begin
          if char == STX
            # begin to receive a packet
            @packet_buffer = ""
            @state = :packet_data
          elsif char == EOT
            @state = :neutral
          else
            raise "unexpected data after ENQ, expected STX, got #{char.to_i}"
          end
        when :packet_data
          if char == ETX
            @state = :packet_checksum_1
          else
            @packet_buffer << char
          end
        when :packet_checksum_1
          @checksum_str = "" << char
          @state = :packet_checksum_2
        when :packet_checksum_2
          @checksum_str << char
          @state = :packet_cr
        when :packet_cr
          if char == CR
            @state = :packet_lf
          else
            raise "unexpected data after checksum, expected CR, got #{char.to_i}"
          end
        when :packet_lf
          if char == LF
            if self.class.checksum_valid?(@packet_buffer, @checksum_str.to_i(16))
              send_packet(ACK.chr, :raw => true)
              # cut the sequence ID
              get_packet(@packet_buffer[1..-1])
            else
              send_packet(NACK.chr, :raw => true)
            end
            @state = :transfer_begin
          else
            raise "unexpected data after checksum, expected LF, got #{char.to_i}"
          end
        end
      end

      def checksum(data)
        val = data.to_enum(:each_byte).inject(0) { |sum,b| sum+b } % 0x100
        val.to_s(16).rjust(2,'0')
      end

      def send_packet(data, options = {})
        warn "--> #{data.inspect}"
        if options[:raw]
          if data == ENQ.chr
            @frame_number = 1 # reset frame number on new transmission
          end
          @send_callback.call(data)
        else
          @frame_number ||= 1

          data = "" << @frame_number.to_s << data
          packet_str = "" << "\x02" << data << "\r" << "\x03" << checksum("" << data << "\r\x03") << "\r\n"
          p "--~> #{packet_str.inspect}"
          @send_callback.call(packet_str)

          @frame_number = (@frame_number + 1) % 8
        end
      end
    end
  end
end
