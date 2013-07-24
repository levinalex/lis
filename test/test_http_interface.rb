require 'helper'

class TestHTTPInterface < Test::Unit::TestCase

  def setup
    @interface = LIS::HTTPInterface.new("http://localhost/lis")
    @device_name = "LIS1"
  end


  context "posting a result" do
    setup do
      @order = LIS::Message::Order.new(13, 12345, "TSTID")
      @string = "R|1|^^^LH|8.2|mIU/mL|.7\.7^400\400|N|N|F||test|19931011091233|19931011091233|DPCCIRRUS"
      @result = LIS::Message::Result.from_string(@string)
    end

    should "should post correct format to the HTTP endpoint" do
      result_stub = stub_request(:post, "http://localhost/lis/LIS1-12345/TSTID").
        with(:body => { "flags"=>"N",
                        "result_timestamp"=>"1993-10-11T09:12:33+00:00",
                        "status"=>"F",
                        "test_name"=>"TSTID",
                        "unit"=>"mIU/mL",
                        "value"=>"8.2",
                        "raw" => Base64.encode64(@string)
                      },
              :headers => { 'Accept' => 'application/json',
                            'Content-Type' => 'application/json' }).
        to_return(:status => 200, :body => "", :headers => {})

      @interface.send_result(@device_name, @order, @result)
      assert_requested(result_stub)
    end
  end

  context "posting a result" do
    setup do
      @order = LIS::Message::Order.from_string("O|1|RV-3/13 A||^^^TSH|R|||||||||||||||||||DPCCIRRUS")
      @string = %q(R|1|^^^TSH|1,14|mIU/L|0,400\0,004^4,00\75,0|N|N|F|||19931011091233|19931011091233|DPCCIRRUS)
      @result = LIS::Message::Result.from_string(@string)
    end

    should "post correct data to the HTTP endpoint" do
      result_stub = stub_request(:post, "http://localhost/lis/LIS1-RV-313A/TSH").
        with(:body => { "flags"=>"N",
                        "result_timestamp"=>"1993-10-11T09:12:33+00:00",
                        "status"=>"F",
                        "test_name"=>"TSH",
                        "unit"=>"mIU/L",
                        "value"=>"1,14",
                        "raw" => Base64.encode64(@string)
                      },
              :headers => { 'Accept' => 'application/json',
                            'Content-Type' => 'application/json' }).
        to_return(:status => 200, :body => "", :headers => {})

      @interface.send_result(@device_name, @order, @result)
      assert_requested(result_stub)
    end

  end


  context "requesting test" do
    setup do
      @http_result = { "id" => "1234",
                        "patient" => { "number" => 98,
                                       "last_name" => "Sierra",
                                       "first_name" => "Rudolph" },
                        "types" => [ "TSH", "FT3", "FT4" ] }.to_yaml
    end


    should "return patient information and requests" do
      stub_request( :get, "http://localhost/lis/LIS1-SOMETHING").to_return(:status => 301, :headers => { 'Location' => "http://localhost/lis/LIS1-1234" } )

      result_stub = stub_request(:get, "http://localhost/lis/LIS1-1234")
      result_stub.to_return( :status => 200, :body => @http_result, :headers => {})
      data = @interface.load_requests(@device_name, "SOMETHING")

      expected = { "id" => "SOMETHING",
                   "patient" => { "number" => 98,
                                  "last_name" => "Sierra",
                                  "first_name" => "Rudolph" },
                   "types" => [ "TSH", "FT3", "FT4" ] }

      assert_equal expected, data.to_hash
    end
  end
end

