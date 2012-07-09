# encoding: UTF-8

module LIS::Transfer
  class ApplicationProtocol < ::PacketIO::Base
    attr_reader :device_name

    def on_result(&block)
      @on_result_callback = block
    end

    def on_request(&block)
      @on_request_callback = block
    end

    def received_header(message)
      @patient_information_requests ||= {} # delete the list of patients
      @device_name = message.sender_name
    end

    def result_for(patient, order, result)
      @on_result_callback.call(@device_name, patient, order, result)
    end

    def received_patient_information(message)
      @last_order = nil
      @last_patient = message
    end

    def received_order_record(message)
      @last_order = message
    end

    def received_result(message)
      result_for(@last_patient, @last_order, message)
    end

    def received_request_for_information(message)
      @patient_information_requests ||= {}
      requests = @on_request_callback.call(@device_name, message.starting_range_id)
      @patient_information_requests[message.sequence_number] = requests if requests
    end

    def send_pending_requests
      sending_session(@patient_information_requests) do |patient_information|
        patient_information.each do |sequence_nr, request_data|
          write :message, LIS::Message::Patient.new(sequence_nr,
                                                    request_data.patient_id,
                                                    request_data.patient_last_name,
                                                    request_data.patient_first_name).to_message
          request_data.each_type do |id, request|
            write :message, LIS::Message::Order.new(sequence_nr, id, request).to_message
          end
        end
      end
      @patient_information_requests = {}
    end

    def initialize(*args)
      super

      @patient_information_requests = {}
      @last_patient = nil
      @last_order = nil
      @handlers = {
        LIS::Message::Header => :received_header,
        LIS::Message::Patient => :received_patient_information,
        LIS::Message::Order => :received_order_record,
        LIS::Message::Result => :received_result,
        LIS::Message::Query => :received_request_for_information
      }
    end

    def receive(type, message = nil)
      warn "[R] #{message}" if type == :message and $VERBOSE
      case type
        when :begin
          @last_patient = nil
          @last_order = nil
        when :idle
          send_pending_requests
        when :message
          @message = LIS::Message::Base.from_string(message)
          handler = @handlers[@message.class]
          send(handler, @message) if handler
      end
    end

    def write(type, message=nil)
      warn "[S] #{message}" if type == :message and $VERBOSE
      super
    end

    # @yield data
    def sending_session(data)
      # don't send anything if there are no pending requests
      return if data.nil? or data.empty?

      write :begin
      write :message, LIS::Message::Header.new("LIS", @device_name).to_message
      yield data
      write :message, LIS::Message::Terminator.new.to_message
      write :idle
    end
  end
end
