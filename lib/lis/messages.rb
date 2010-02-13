require 'date'

module LIS::Message
  module ClassMethods
    CONVERSION_WRITER = {
      :string => lambda { |s| s },
      :int => lambda { |s| s.to_i },
      :timestamp => lambda { |s| DateTime.strptime(s, "%Y%m%d%H%M%S") }
    }

    def field_count(val = nil)
      @field_count = val if val
      @field_count
    end

    def from_string(message)
      type, data = parse(message)
      klass = (@@messages_by_type || {})[type]
      raise "unknown message type #{type.inspect}" unless klass

      obj = klass.allocate

      data = data.to_enum(:each_with_index).inject({}) do |h,(elem,idx)|
        h[idx+2] = elem; h
      end

      obj.instance_variable_set("@fields", data)
      obj
    end

    def default_fields
      arr = Array.new(@field_count)
      (0 .. @field_count).inject(arr) do |a,i|
        default = (get_field_attributes(i) || {})[:default]
        if default
          default = default.call if default.respond_to?(:call)
          a[i-1] = default
        end
        arr
      end
    end

    def has_field(idx, name = nil, opts={})
      set_index_for(name, idx) if name
      set_field_attributes(idx, { :name => name,
                                  :type => opts[:type] || :string,
                                  :default => opts[:default]})

      @field_count ||= 0
      @field_count = [@field_count, idx].max

      return unless name

      define_method :"#{name}=" do |val|
        @fields ||= {}
        @fields[idx] = val
      end

      define_method :"#{name}" do
        field_attrs = self.class.get_field_attributes(idx)
        val = (@fields || {})[idx]
        converter = CONVERSION_WRITER[field_attrs[:type]] if field_attrs
        val = converter.call(val) if converter
        val
      end
    end

    def parse(string)
      type, data = string.scan(/^(.)\|(.*)$/)[0]
      data = data.split(/\|/)

      return [type, data]
    end

    def type_id(char = nil)
      return @@messages_by_type.find {|c,klass| klass == self }.first unless char
      @@messages_by_type ||= {}
      @@messages_by_type[char] = self
    end

    def set_index_for(field_name, idx)
      @field_indices ||= {}
      @field_indices[field_name] = idx
    end

    def get_index_for(field_name)
      val = @field_index[field_name]
      val ||= superclass.get_index_for(field_name) if superclass.respond_to?(:get_index_for)
      val
    end

    def get_field_attributes(index)
      @field_names ||= {}
      val = (@field_names || {})[index]
      val ||= superclass.get_field_attributes(index) if superclass.respond_to?(:get_field_attributes)
      val
    end

    def set_field_attributes(index, hash)
      @field_names ||= {}
      @field_names[index] = hash
    end
  end

  class Base
    extend ClassMethods
    attr_accessor :frame_number

    has_field 2, :sequence_number, :type => :int, :default => 1

    def type_id
     self.class.type_id
    end

    def to_message
      @fields ||= {}
      arr = Array.new(self.class.default_fields)
      type_id + @fields.inject(arr) { |a,(k,v)| a[k-1] = v; a }.join("|")
    end
  end

end
