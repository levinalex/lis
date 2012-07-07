require 'helper'

class TestWorklistManagerInterface < Test::Unit::TestCase

  def setup
    @interface = WorklistManagerInterface.new("http://localhost/lis/")
    @device_name = "LIS1"
  end


  context "posting a result" do
    setup do
      @patient = LIS::Message::Patient.new(12 ,89 ,"Sierra", "Rudolph")
      @order = LIS::Message::Order.new(13, 12345, "TSTID")
      @result = LIS::Message::Result.from_string("R|1|^^^LH|8.2|mIU/mL|.7\.7^400\400|N|N|F||test|19931011091233|19931011091233|DPCCIRRUS")
    end

    should "should post correct format to the HTTP endpoint" do
      result_stub = stub_request(:post, "http://localhost/lis/result/LIS1-12345").
        with(:body => { "flags"=>"N",
                        "result_timestamp"=>"1993-10-11T09:12:33+00:00",
                        "status"=>"F",
                        "test_name"=>"TSTID",
                        "unit"=>"mIU/mL",
                        "value"=>"8.2"}).
        to_return(:status => 200, :body => "", :headers => {})

      @interface.send_result(@device_name, @patient, @order, @result)
      assert_requested(result_stub)
    end
  end

  context "requesting test" do
    setup do
      @http_result = { "id" => "1234",
                        "patient" => { "id" => 98,
                                       "last_name" => "Sierra",
                                       "first_name" => "Rudolph" },
                        "types" => [ "TSH", "FT3", "FT4" ] }.to_yaml
    end


    should "return patient information and requests" do
      stub_request( :get, "http://localhost/lis/find_requests/LIS1-SOMETHING").to_return(:status => 301, :headers => { 'Location' => "http://localhost/lis/find_requests/LIS1-1234" } )

      result_stub = stub_request(:get, "http://localhost/lis/find_requests/LIS1-1234")
      result_stub.to_return( :status => 200, :body => @http_result, :headers => {})
      data = @interface.load_requests(@device_name, "SOMETHING")

      expected = { "id" => "SOMETHING",
                   "patient" => { "id" => 98,
                                  "last_name" => "Sierra",
                                  "first_name" => "Rudolph" },
                   "types" => [ "TSH", "FT3", "FT4" ] }

      assert_equal expected, data
    end
  end
end

