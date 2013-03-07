# encoding: UTF-8

module LIS::Message

  # = Result Message
  #
  # Contains test results and additional information, such as Test Code and the units in which the results are delivered. This message is sent to the LIS.
  #
  # == Message Examples
  #
  #  4R|1|^^^LH|8.2|mIU/mL|.7\.7^400\400|N|N|F||test|19931011091233|19931011091233|DPCCIRRUS
  #
  # == Message Structure
  #
  # 1. Record Type (R)
  # 2. Sequence #
  # 3. Universal Test ID
  # 4. Data (result)
  # 5. Units
  # 6. ReferenceRanges
  # 7. Result abnormal flags
  # 8. Nature of Abnormality Testing
  # 9. Result Status
  # 10. Date of change in instruments normal values or units
  # 11. Operator ID
  # 12. Date/Time Test Started
  # 13. Date/Time Test Completed
  # 14. Instrument ID
  #
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

    def raw_data
      Base64.encode64(to_message)
    end

    def universal_test_id
      universal_test_id_internal.gsub(/\^/,"")
    end
    def universal_test_id=(val)
      universal_test_id_internal = "^^^#{val}"
    end
  end
end

