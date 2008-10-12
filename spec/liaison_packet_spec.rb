require 'lib/liaison_labor/packets.rb'

include Diasorin


def has_header(packet, char)
  specify "should be matched by packets stating with #{char}" do
    instance_variable_get("@#{packet}").matches?("#{char}...").should be_true
  end

  specify "different headers should not match" do
    instance_variable_get("@#{packet}").matches?("random garbage").should be_false
  end  
end

def has_example(packet, example_str)
  specify "example should parse without errors" do
    lambda {
      instance_variable_get("@#{packet}").from_str(example_str) 
      }.should_not raise_error
  end
end

context "checksum for packets" do
  setup do
    @full_packet = "\0021O|1|00000023||^^^FT4^|||||||||||||||||||||F\r\003EE\r\n"
  end

  specify "data should have a correct checksum" do
    LiaisonProtocol.checksum_valid?("1O|1|00000023||^^^FT4^|||||||||||||||||||||F\r","EE".to_i(16)).should be_true
  end

end


context "The MessageHeaderRecord packet from/to Liaison" do
  setup do
    @packet = Liaison::Packets::MessageHeaderRecord
    @str = "H|\^&|||LaborEDV|||||Liaison|||1|19971113154903"
  end
  
  has_header :packet, "H"
  
  specify "should have a sender_id" do
    @packet.from_str(@str).sender_id.should == "LaborEDV"
  end
  
  specify "should have a receiver_id" do
    @packet.from_str(@str).receiver_id.should == "Liaison"
  end
  
  specify "should have a timestamp" do
    @packet.from_str(@str).timestamp.should == DateTime.new(1997,11,13,15,49,03)
  end
end

context "Building a MessageHeaderRecord" do
  setup do
    @header = Liaison::Packets::MessageHeaderRecord
    @packet = @header.new("Sender","Receiver")
  end
  
  specify "should build a correct packet" do
    @packet.to_s.should == "H|\\^&|||Sender|||||Receiver"
  end
end

context "the MessageTerminatorRecord packet to Liaison" do
  setup do
    @terminator_record = Liaison::Packets::MessageTerminatorRecord
    @str = "L|1|N"
    @packet = @terminator_record.from_str(@str)
  end

  has_header :terminator_record, "L"
  
  specify "should have sequence number" do
    @packet.sequence_number.should == 1
  end
  specify "should have termination code" do
    @packet.termination_code.should == "N"
  end
end

context "the PatientInformationRecord from/to Liaison" do
  setup do
    @packet = Liaison::Packets::PatientInformationRecord
    @example = "P|1||PatID01||Meyer^Anna||19741001|F|||||MARTINEZ"
  end
  
  has_header :packet, "P"
  
  specify "should have a sequence number" do
    @packet.from_str(@example).sequence_number.should == 1
  end
  
  specify "should have a patient ID" do
    @packet.from_str(@example).patient_id.should == "PatID01"
  end
  specify "should have a patient name" do
    @packet.from_str(@example).patient_last_name.should == "Meyer"
    @packet.from_str(@example).patient_first_name.should == "Anna"
  end
  specify "should have a birthday" do
    @packet.from_str(@example).birthdate.should == Date.new(1974,10,01)
  end
  specify "should have sex" do
    @packet.from_str(@example).sex.should == "F"
  end
  specify "should have attending physician" do
    @packet.from_str(@example).physician.should == "MARTINEZ"
  end
end

context "building a PatientInformationRecord" do
  setup do
    @record = Liaison::Packets::PatientInformationRecord
    @packet = @record.new(1, "000204060", "Sierra", "Rudolph")
  end
  
  specify "should just work" do
    @packet.to_s.should == "P|1||000204060||Sierra^Rudolph"
  end
end

context "the RequestInformationSegment" do
  setup do
    @request_information = Liaison::Packets::RequestInformationSegment
    @str = "Q|1|Sample01||ALL||||||||O"
    @packet = @request_information.from_str(@str)
  end
  
  has_header :request_information, "Q"
  
  specify "should have a sequence number" do
    @packet.sequence_number.should == 1
  end
  
  specify "should have starting range id" do
    @packet.starting_range.should == "Sample01"
  end
end

context "the TestOrderRecord from/to Liaison" do
  setup do
    @order_record = Liaison::Packets::TestOrderRecord
    @example = "O|1|SampleID01||^^^AFP^1:10|N|19980506|||||||||S||||||||||X"
    @packet = @order_record.from_str(@example)
  end
  
  has_header :order_record, "O"
  
  specify "should have a sequence number" do
    @packet.sequence_number.should == 1
  end
  specify "should have a specimen id" do
    @packet.specimen_id.should == "SampleID01"
  end
  specify "should have a universal test id" do
    @packet.test_id.should == "AFP"
  end
  specify "should have a dilution" do
    @packet.dilution.should == "1:10"
  end
  specify "should have a priority" do
    @packet.priority.should == "N"
  end
  specify "should have timestamp" do
    @packet.timestamp.should == DateTime.new(1998,5,6,0,0,0)
  end
  specify "should have report type" do
    @packet.record_type.should == "X"
  end
end

context "building a TestOrderRecord" do
  setup do
    @order_record = Liaison::Packets::TestOrderRecord
  end

  specify "should generate a correct packet" do
    @packet = @order_record.new(17, "BarcodeID", "TSH")
    @packet.to_s.should == "O|17|BarcodeID||^^^TSH"
  end
end

context "the ResultRecord" do
  setup do
    @result_record = Liaison::Packets::ResultRecord
    @example = "R|1|^^^AFP|0.20|IU/ml||<||F||||19980506123145|Liaison"
    @packet = @result_record.from_str(@example)
  end
  
  has_header :result_record, "R"
  
  specify "should have sequence number" do
    @packet.sequence_number.should == 1
  end
  specify "should have test id" do
    @packet.test_id.should == "AFP"
  end
  specify "should have value" do
    @packet.value.should == "0.20"
  end
  specify "should have unit" do
    @packet.unit.should == "IU/ml"
  end
  specify "should have abnormal flags" do
    @packet.abnormal_flags.should == "<"
  end
  specify "should have result status" do
    @packet.result_status.should == "F"
  end
  specify "should have timestamp" do
    @packet.timestamp.should == DateTime.new(1998,05,06,12,31,45)
  end
  specify "should have instrument" do
    @packet.instrument.should == "Liaison"
  end
  
end

# TODO: empty result data should be allowed

context "the CommentRecord" do
  setup do
    @packet = Liaison::Packets::CommentRecord
  end
  has_header :packet, "C"
end




