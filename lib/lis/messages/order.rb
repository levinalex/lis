module LIS::Message
  class Order < Base
    type_id "O"

    has_field  3, :specimen_id
    has_field  5, :universal_test_id_internal
    has_field  6, :priority, :default => "R" # routine
    has_field  7, :requested_at
    has_field  8, :collected_at
    has_field 12 # :action_code

    has_field 14 # :relevant_clinical_information

    has_field 25 # :instrument_section_id

    has_field 29 # nosocomial_infection_flag
    has_field 30 # specimen_service
    has_field 31 # specimen_institution

    field_count 0

    def initialize(sequence_number, specimen_id, universal_test_id)
      self.sequence_number = sequence_number
      self.specimen_id = specimen_id
      self.universal_test_id = universal_test_id
    end

    def universal_test_id
      self.universal_test_id_internal.gsub(/\^/,"")
    end
    def universal_test_id=(val)
      self.universal_test_id_internal = "^^^#{val}"
    end
  end
end
