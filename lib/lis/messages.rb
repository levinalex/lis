require 'date'

module LIS::Message
  module ClassMethods
    CONVERSION_WRITER = {
      :string => lambda { |s| s },
      :int => lambda { |s| s.to_i },
      :timestamp => lambda { |s| DateTime.strptime(s, "%Y%m%d%H%M%S") }
    }

    def from_string(message)
      type, data = parse(message)
      klass = (@@messages_by_type || {})[type]
      raise "unknown message type #{type.inspect}" unless klass

      obj = klass.allocate
      obj.type_id = type

      # populate named fields
      data.each_with_index do |val, index|
        klass.get_named_field_attributes(index + 2)
        field = klass.get_named_field_attributes(index+2)
        if field
          converter = CONVERSION_WRITER[field[:type]]
          obj.send(:"#{field[:name]}=", converter.call(val))
        end
      end

      obj
    end

    def initialize_from_message(*list_of_fields)
    end

    def named_field(idx, name, type = :string)
      set_named_field_attributes(idx, :name => name, :type => type)
      attr_accessor name
    end


    protected

    def parse(string)
      type, data = string.scan(/^(.)\|(.*)$/)[0]
      data = data.split(/\|/)

      return [type, data]
    end

    def type_id(char)
      @@messages_by_type ||= {}
      @@messages_by_type[char] = self
    end

    def get_named_field_attributes(key)
      @field_names ||= {}
      val = (@field_names || {})[key]
      val ||= superclass.get_named_field_attributes(key) if superclass.respond_to?(:get_named_field_attributes)
      val
    end

    private

    def set_named_field_attributes(key, hash)
      @field_names ||= {}
      @field_names[key] = hash
    end
  end

  class Base
    extend ClassMethods
    attr_accessor :frame_number
    attr_accessor :type_id

    named_field 2, :sequence_number, :int
  end


  class Header < Base
    type_id "H"
    named_field  2, :delimiter_definition
    named_field  4, :access_password
    named_field  5, :sender_name
    named_field 10, :receiver_id
  end

  class Order < Base
    type_id "O"
    named_field 3, :specimen_id
    named_field 5, :universal_test_id
    named_field 6, :priority
    named_field 7, :requested_at
    named_field 8, :collected_at
  end

  class Result < Base
    type_id "R"
    named_field  3, :universal_test_id
    named_field  4, :result_value
    named_field  5, :unit
    named_field  6, :reference_ranges
    named_field  7, :abnormal_flags
    named_field  9, :result_status
    named_field 12, :test_started_at, :timestamp
    named_field 13, :test_completed_at, :timestamp
  end

  class Patient < Base
    type_id "P"
  end

  class Query < Base
    type_id "Q"
  end


  class TerminatorRecord < Base
    TERMINATION_CODES = {
      "N" => "Normal termination",
      "T" => "Sender Aborted",
      "R" => "Receiver Abort",
      "E" => "Unknown system error",
      "Q" => "Error in last request for information",
      "I" => "No information available from last query",
      "F" => "Last request for information Processed"
    }

    type_id "L"
    named_field 3, :termination_code
  end

end