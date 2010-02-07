
module LIS::Transfer
  class ApplicationProtocol < Base

    def on_result(&block)
      @on_result_callback = block
    end

    def on_request(&block)
      @on_request_callback = block
    end


    def received_header(message)
      @patient_information ||= {} # delete the list of patients
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
      @patient_information ||= {}
      requests = @on_request_callback.call(p.starting_range)
      @patient_information[p.sequence_number] = requests if requests
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
        when :message
          @message = LIS::Message::Base.from_string(message)
          handler = @handlers[@message.class]
          send(handler, @message) if handler
      end
    end
  end

end