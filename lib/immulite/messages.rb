
module LIS::Message
  module ClassMethods
    FIELD_TYPES = {
      :string => lambda { |s| s },
      :int => lambda { |s| s.to_i }
    }

    def from_string(message)
      frame_number, type, data = parse(message)
      klass = (@@messages_by_type || {})[type]
      raise "unknown message type #{type.inspect}" unless klass

      obj = klass.allocate
      obj.frame_number = frame_number
      obj.type_id = type

      # populate named fields
      data.each_with_index do |val, index|
        klass.get_named_field_attributes(index + 2)
        if field = klass.get_named_field_attributes(index+2)
          obj.send(:"#{field[:name]}=", FIELD_TYPES[field[:type]].call(val))
        end
      end

      obj
    end

    def initialize_from_message(*list_of_fields)
    end

    protected

    def parse(string)
      frame_number, type, data = string.scan(/^(.)(.)\|(.*)$/)[0]
      data = data.split(/\|/)

      return [frame_number.to_i, type, data]
    end

    def type_id(char)
      @@messages_by_type ||= {}
      @@messages_by_type[char] = self
    end

    def named_field(idx, name, type = :string)
      set_named_field_attributes(idx, :name => name, :type => type)
      attr_accessor name
    end

    def get_named_field_attributes(key)
      @field_names ||= {}
      val = (@field_names || {})[key]
      val ||= superclass.get_named_field_attributes(key) if superclass.respond_to?(:get_named_field_attributes)
      val
    end

    private

    def set_named_field_attributes(key, *val)
      @field_names ||= {}
      @field_names[key] = *val
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
    named_field 3, :universal_test_id
    named_field 4, :result_value
    named_field 5, :unit
    named_field 6, :reference_ranges
    named_field 7, :abnormal_flags
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