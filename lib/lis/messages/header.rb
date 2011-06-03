# encoding: UTF-8

module LIS::Message

  # = Header Message
  #
  # First message sent in any transaction, contains system information such as sender ID, receiver ID, address, etc.
  #
  # == Message Examples
  #
  #  1H|\^&||PASSWORD|DPC CIRRUS||Flanders^New^Jersey^07836||973-927-2828|N81|Your System||P|1|19940407120613
  #
  # == Message Structure
  #
  # 1. Record Type (H)
  # 2. Delimiter Def.
  # 3. Message Control ID
  # 4. Password
  # 5. Sending systems company name
  # 6. Sending Systems address
  # 7. Reserved
  # 8. Senders Phone#
  # 9. Communication parameters
  # 10. Receiver ID
  # 11. Comments/special instructions
  # 12. Processing ID
  # 13. Version#
  # 14. Message Date + Time
  #
  class Header < Base
    type_id "H"
    has_field  2, :delimiter_definition, :default => "\\^&"
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

    def initialize(sender_name = "SenderID", receiver_name = "ReceiverID", password = "")
      self.sender_name = sender_name
      self.receiver_name = receiver_name
      self.access_password = password
    end
  end
end

