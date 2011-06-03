# encoding: UTF-8

module LIS::Message

  # = Patient Message
  #
  # Contains patient information, patient ID, name.
  #
  # == Message Examples
  #
  #  2P|1|101|||Riker^Al||19611102|F|||||Bashere
  #
  #  2P|3|326829;AH|||Last 3^First 3|||F|||||
  #
  #  2P|1|119813;TGH|||Last 1^First 1|||F|||||
  #
  #  5P|2|66412558|||||||||||
  #
  # == Message Structure
  #
  # 1. Record Type (P)
  # 2. Sequence #
  # 3. Practice Assigned Patient ID
  # 4. Laboratory Assigned Patient ID
  # 5. Patient ID
  # 6. Patient Name
  #      (Last^First^Initial; maximum of 20 characters for Last Name; maximum of 15 characters for First Name)
  # 7. Mother's Maiden Name
  # 8. BirthDate
  #      (YYYYMMDD; maximum of 8 characters)
  # 9. Patient Sex
  #      (M or F; maximum of 1 character)
  # 10. Patient Race
  # 11. Patient Address
  # 12. Reserved
  # 13. Patient Phone #
  # 14. Attending Physician ID
  # 15. Special Field 1
  # 16. Special Field 2
  # 17. Patient Height
  # 18. Patient Weight
  # 19. Patients Known or Suspected Diagnosis
  # 20. Patient active medications
  # 21. Patients Diet
  # 22. Practice Field #1
  # 23. Practice Field #2
  # 24. Admission and Discharge Dates
  # 25. Admission Status
  # 26. Location
  # 27. Nature of Alternative Diagnostic Code and Classification
  # 28. Alternative Diagnostic Code and Classification
  # 29. Patient Religion
  # 30. Marital Status
  # 31. Isolation Status
  # 32. Language
  # 33. Hospital Service
  # 34. Hospital Institution
  # 35. Dosage Category
  #
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

