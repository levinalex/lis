module LIS::Message
  class Result < Base
    type_id "R"
    has_field  3, :universal_test_id_internal
    has_field  4, :result_value
    has_field  5, :unit
    has_field  6, :reference_ranges
    has_field  7, :abnormal_flags
    has_field  9, :result_status
    has_field 12, :test_started_at, :type => :timestamp
    has_field 13, :test_completed_at, :type => :timestamp

    def universal_test_id
      universal_test_id_internal.gsub(/\^/,"")
    end
    def universal_test_id=(val)
      universal_test_id_internal = "^^^#{val}"
    end
  end
end
