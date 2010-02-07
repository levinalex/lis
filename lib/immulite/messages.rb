
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

      data.each_with_index do |val, index|
        if field = get_named_field_attributes(index+1)
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


    private

    def get_named_field_attributes(key)
      parent_field_names = superclass.respond_to?(:get_field_names) ? superclass.field_names : {}
      parent_field_names.merge(@field_names || {})[key]
    end

    def set_named_field_attributes(key, *val)
      @field_names ||= {}
      @field_names[key] = *val
    end
  end

  class Base
    extend ClassMethods

    attr_accessor :frame_number
    attr_accessor :type_id

    named_field 1, :sequence_number, :int
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
    named_field 2, :termination_code
  end

end