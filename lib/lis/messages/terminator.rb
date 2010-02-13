module LIS::Message
  class Terminator < Base
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
    has_field 3, :termination_code, :default => "N"
  end
end
