module LIS::Transfer
  class ApplicationProtocol < Base
    def receive(message, &block)
      elements = message.split(/|/)
      sequence_number, header, data = message.scan(/^(.)(.)\|(.*)$/)[0]

      sequence_number = sequence_number.to_i

    end
  end

end