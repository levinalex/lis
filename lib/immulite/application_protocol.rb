
module LIS::Transfer
  class ApplicationProtocol < Base
    def receive(message, &block)
      p message
      @message = LIS::Message::Base.from_string(message)
      p @message
      forward(message)
    end
  end

end