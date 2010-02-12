module LIS::Message
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
