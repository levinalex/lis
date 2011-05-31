module LIS::Message

  # = Comment Message
  #
  class Comment < Base
    type_id "C"
    has_field 3, :message
  end
end
