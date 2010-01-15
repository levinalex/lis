
module Diasorin
  module Liaison
    class MockInterface < PacketIO
      def initialize(read, write, options = {})
        super(SerialProtocol, read, write, options)

        add_sender( {
          :init => Packets::MessageHeaderRecord,
          :next_patient => Packets::NextPatient,
          :result => Packets::Result,
          :end => Packets::EndOfData
        } )

        add_receiver :end => Packets::EndOfData do |d|
          self.end_of_list
        end

        add_receiver :next_result => Packets::NextResult do |d|
        end

        run
      end

      def init
        send_packet :init
      end

      def result(pat_with_results)

      end

      def next_patient nr
        send_packet :next_patient, nr
      end

      def end_of_list
        send_packet :end
      end

    end
  end
end