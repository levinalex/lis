module LIS::Message

  # = Order Message
  #
  # Defines which test, such as TSH or HCG, should be performed on the sample for a particular accession number.
  #
  # == Message Examples
  #
  #  3O|1|1550623||^^^LH|R|19931011091233|19931011091233
  #
  #  6O|1|130000724||^^^E2|||19950118122000
  #
  #  6O|1|66412558||^^^HCG|||200011081530||||||Normal|||||||||||E0872
  #
  #  1O|1|09861081||^^^TSH|R|||||||||||||||||||E0872
  #
  # == Message Structure
  #
  # 1. Record Type (O)
  # 2. Sequence#
  # 3. Specimen ID (Accession#)
  # 4. Instrument Specimen ID
  # 5. Universal Test ID
  # 6. Priority
  # 7. Order Date/Time
  # 8. Collection Date/Time
  # 9. Collection End Time
  # 10. Collection Volume
  # 11. Collector ID
  # 12. Action Code
  # 13. Danger Code
  # 14. Relevant Clinical Info
  # 15. Date/Time Specimen Received
  # 16. Specimen Descriptor,Specimen Type,Specimen Source
  # 17. Ordering Physician
  # 18. Physician's Telephone Number
  # 19. User Field No.1
  # 20. User Field No.2
  # 21. Lab Field No.1
  # 22. Lab Field No.2
  # 23. Date/Time results reported or last modified
  # 24. Instrument Charge to Computer System
  # 25. Instrument Section ID
  # 26. Report Types
  # 27. Reserved Field
  # 28. Location or ward of Specimen Collection
  # 29. Nosocomial Infection Flag
  # 30. Specimen Service
  # 31. Specimen Institution
  #

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

