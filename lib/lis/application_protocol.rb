
module LIS::Transfer
  class ApplicationProtocol < Base
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
      @on_result_callback.call(patient, order, result)
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
      return if @patient_information_requests.nil?

      write :begin
      @patient_information_requests.each do |sequence_nr, data|
        p "sequence: #{sequence_nr.inspect}"
        p "data: #{data.inspect}"

        write :message, LIS::Message::Patient.new(sequence_nr,
                                                  data["patient"]["number"],
                                                  data["patient"]["last_name"],
                                                  data["patient"]["first_name"])
        data["types"].each do |request|
          write :message, LIS::Message::Order.new(sequence_nr, data["id"], request)
        end
      end
      @patient_information_requests = nil

      write :idle
    end

    def initialize(*args)
      super

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
  end
end
