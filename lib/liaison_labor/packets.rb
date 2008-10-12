require 'date'
require 'serial_interface'

module Diasorin
  module Liaison
    module Packets
      class LiaisonPacket < SerialPacket
        FieldDelimiter = '|'
        RepeatDelimiter = '\\'
        ComponentDelimiter = '^'
        EscapeDelimiter = "&"
        
        header_format "A"
        
        def sequence_number=(val)
          @sequence_number = val.to_i    
        end

        def to_str
          to_s
        end
      end

      class Acknowledge < LiaisonPacket
        def self.matches?(str)
          str == "\x06" ? true : false
        end
        def to_s; "\x06"; end
      end

      class NotAcknowledge < LiaisonPacket
        def self.matches?(str)
          str == "\x15" ? true : false
        end
        def to_s; "\x15"; end
      end
      
      class MessageHeaderRecord < LiaisonPacket
        header_format "A"
        header_filter "H"
        header ["H"]
        
        attr_reader :sender_id
        attr_reader :receiver_id
        attr_reader :timestamp
        
        def initialize(sender_id, receiver_id)
          @sender_id = sender_id
          @receiver_id = receiver_id
        end
        
        def to_s
          arr = []
          arr[1] = "H"
          arr[2] = "\\^&"
          arr[5] = @sender_id
          arr[10] = @receiver_id
          arr.shift
          
          arr.join("|")
        end
        
        def initialize_from_packet(str)
          records = str.split(FieldDelimiter)
          
          @sender_id = records[4]
          @receiver_id = records[9]
          @timestamp = DateTime.new(*records[13].scan(/(....)(..)(..)(..)(..)(..)/)[0].map {|x| x.to_i })
          
          @version = records[12]
          raise "Version is not supported" unless @version == '1'
          
        end
      end
      
      class MessageTerminatorRecord < LiaisonPacket
        header_format "A"
        header_filter "L"
        header ["L"]
        
        attr_reader :sequence_number
        attr_reader :termination_code
        
        def initialize_from_packet(str)
          records = str.split(FieldDelimiter)
          _, self.sequence_number, @termination_code = records
        end

        def initialize(sequence_number, termination_code = "N")
          @sequence_number = sequence_number
          @termination_code = termination_code
        end

        def to_s
          arr = []
          arr[1] = "L"
          arr[2] = @sequence_number
          arr[3] = @termination_code
          arr.shift
          
          arr.join("|")
        end
      end
      
      class PatientInformationRecord < LiaisonPacket
        header_format "A"
        header_filter "P"
        header ["P"]
        
        attr_reader :sequence_number
        attr_reader :patient_id
        attr_reader :patient_last_name
        attr_reader :patient_first_name
        attr_reader :birthdate
        attr_reader :sex
        attr_reader :physician
        
        def patient_name=(val)
          @patient_last_name, @patient_first_name = val.split(ComponentDelimiter)
        end
        def birthdate=(val)
          @birthdate = case val
                       when String
                         DateTime.new(*val.scan(/(....)(..)(..)/)[0].map {|x| x.to_i }) rescue nil
                       end  
        end
        
        def initialize(sequence_nr, patient_id, lastname = "", firstname = "")
          @sequence_number = sequence_nr.to_i
          @patient_id = patient_id
          @patient_last_name, @patient_first_name = lastname, firstname
        end
        
        def to_s
          arr = []
          arr[1] = "P"
          arr[2] = @sequence_number
          arr[4] = @patient_id.to_s
          arr[6] = [@patient_last_name, @patient_first_name].join("^")
          arr.shift
          
          arr.join("|")
        end
        
        def initialize_from_packet(str)
          records = str.split(FieldDelimiter)
         
          _1, 
          self.sequence_number, 
          _3, 
          @patient_id, 
          _5, 
          self.patient_name,
          _7, 
          self.birthdate, 
          @sex,
          _10, 
          _11, 
          _12, 
          _13,
          @physician, 
          _rest = records
        end
      end
      
      class RequestInformationSegment < LiaisonPacket
        header_format "A"
        header_filter "Q"
        header ["Q"]
        
        attr_reader :sequence_number
        attr_reader :starting_range
        
        def initialize_from_packet(str)
          records = str.split(FieldDelimiter)
           
          _1, self.sequence_number, @starting_range, _rest = records
        end
      end
      
      class TestOrderRecord < LiaisonPacket
        header_format "A"
        header_filter "O"
        header ["O"]
        
        attr_reader :sequence_number
        attr_reader :specimen_id
        attr_reader :test_id
        attr_reader :dilution
        attr_reader :priority
        attr_reader :timestamp
        attr_reader :record_type
        
        def sequence_number=(val)
          @sequence_number = val.to_i    
        end
        def test_order=(data)
          _1, _2, _3, @test_id, @dilution = data.split(ComponentDelimiter)
        end  
        def timestamp=(val)
            @timestamp = case val
                         when String
                           DateTime.new(*val.scan(/(....)(..)(..)/)[0].map {|x| x.to_i  }) rescue nil
                         end  
        end
        def initialize_from_packet(str)
          records = str.split(FieldDelimiter)
          
          _1,
          self.sequence_number, 
          @specimen_id,
          _4,
          self.test_order,
          @priority,
          self.timestamp, _, _, _10, _, _, _, _, _, _, _, _, _, _20, _, _, _, _, _, @record_type,
          _rest = records
        end

        def initialize(sequence_number, specimen_id, test_id)
          @sequence_number = sequence_number
          @specimen_id = specimen_id
          @test_id = test_id
        end


        def to_s
          arr = []
          arr[1] = "O"
          arr[2] = @sequence_number
          arr[3] = @specimen_id
          arr[5] = [nil,nil,nil,@test_id].join("^")
          arr.shift

          arr.join("|")
        end
      end
     
      class ResultRecord < LiaisonPacket
        header_format "A"
        header_filter "R"
        header ["R"]
        
        attr_reader :sequence_number
        attr_reader :test_id
        attr_reader :value
        attr_reader :unit
        attr_reader :abnormal_flags
        attr_reader :result_status
        attr_reader :timestamp
        attr_reader :instrument
        
        def test_result=(data)
          _1, _2, _3, @test_id = data.split(ComponentDelimiter)
        end
        def timestamp=(val)
            @timestamp = case val
                         when String
                           DateTime.new(*val.scan(/(....)(..)(..)(..)(..)(..)/)[0].map {|x| x.to_i }) rescue nil
                         end  
        end
        
        def initialize_from_packet(str)
          records = str.split(FieldDelimiter)
          
          _1,
          self.sequence_number,
          self.test_result,
          @value,
          @unit,
          _6,
          @abnormal_flags,
          _7,
          @result_status,
          _10, _11, _12, 
          self.timestamp,
          @instrument,
          rest  = records
        end
      end
      
      class CommentRecord < LiaisonPacket
        header_format "A"
        header_filter "C"
        header ["C"]

        attr_reader :comment

        def initialize_from_packet(str)
          records = str.split(FieldDelimiter)

          _1,
          self.sequence_number,
          _3,
          @comment,
          rest = records
        end
      end
        

    end
  end
end
