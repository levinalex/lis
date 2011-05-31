module LIS::Message

  # = Query Message
  #
  # A request to the LIS for patient information and test orders. Contains the primary tube accession number.
  #
  # == Message Examples
  #
  #  2Q|1|^1234ABC||ALL|||||||O
  #
  # == Message Structure
  #
  # 1. Record Type ID (Q)
  # 2. Sequence #
  # 3. Starting Range
  # 4. Ending Range
  # 5. Test ID
  # 6. Request Time Limits
  # 7. Beginning request results date and time
  # 8. Ending request results date and time
  # 9. Physician name
  # 10. Physician Phone Number
  # 11. User Field 1
  # 12. User Field 2
  # 13. Status Codes
  #      C - Correction of previous results
  #      P - Preliminary Results
  #      F - Final Results
  #      X - Results cannot be done, cancel
  #      I - Request Results Pending
  #      S - Request partial results
  #      M - Result is a MIC level
  #      R - Result previously transmitted
  #      A - Abort/cancel last request
  #      N - Requesting new results only
  #      O - Requesting orders and demographics
  #      D - Requesting demographics only
  #
  class Query < Base
    type_id "Q"
    has_field 3, :starting_range_id_internal

    def starting_range_id
      starting_range_id_internal.gsub(/\^/,"")
    end
    def starting_range_id=(val)
      starting_range_id_internal = "^#{val}"
    end
  end
end

