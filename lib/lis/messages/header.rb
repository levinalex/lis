module LIS::Message
  class Header < Base
    type_id "H"
    has_field  2, :delimiter_definition, :default => "^&"
    has_field  4, :access_password
    has_field  5, :sender_name
    has_field  6, :sender_address
    has_field  7 # reserved
    has_field  8 # sender_telephone_number
    has_field  9, :sender_characteristics, :default => "8N1"
    has_field 10, :receiver_name
    has_field 11 # comments/special_instructions
    has_field 12, :processing_id, :default => "P"
    has_field 13, :version, :default => "1"
    has_field 14, :timestamp, :default => lambda { Time.now.strftime("%Y%m%d%H%M%S") }

    def initialize(sender_name = "SenderID", receiver_name = "ReceiverID")
      self.sender_name = sender_name
      self.receiver_name = receiver_name
    end
  end
end
