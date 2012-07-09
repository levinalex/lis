module LIS
  module Data
    class Request
      def initialize(data={})
        @data = data
      end

      def patient_id
        @data["patient"]["id"]
      end
      def patient_last_name
        @data["patient"]["last_name"]
      end
      def patient_first_name
        @data["patient"]["first_name"]
      end

      def each_type
        @data["types"].each do |t|
          yield @data["id"], t
        end
      end

      def to_hash
        @data
      end

      def self.from_yaml(text, barcode)
        data = YAML.load(text)
        data["id"] = barcode

        new(data)
      end
    end
  end
end

