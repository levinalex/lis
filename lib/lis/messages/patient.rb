module LIS::Message
  class Patient < Base
    type_id "P"

    has_field  3, :practice_assigned_patient_id
    has_field  4, :laboratory_assigned_patient_id
    has_field  5, :patient_id
    has_field  6, :name
    has_field  7 # :mothers_maiden_name
    has_field  8, :birthdate
    has_field  9, :sex
    has_field 10, :race
    has_field 14, :attending_physician

    def initialize(sequence_number, patient_id, last_name = "", first_name = "")
      self.sequence_number = sequence_number
      self.practice_assigned_patient_id = patient_id
      self.patient_id = patient_id
      self.name = [last_name.force_encoding("UTF-8"), first_name.force_encoding("UTF-8")].join("^")
    end

  end
end
