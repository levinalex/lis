module LIS::Message

  # = Terminator Message
  #
  # Last message sent in a transaction, contains termination codes.
  #
  # == Message Examples
  #
  #  5L|1|N
  #
  # == Message Structure
  #
  # 1. Record Type ID (L)
  # 2. Sequence Number
  # 3. Termination Code
  #
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

