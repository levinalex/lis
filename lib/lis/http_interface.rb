# encoding: UTF-8

require 'rest-client'

class LIS::HTTPInterface
  def initialize(endpoint)
    @endpoint = endpoint
  end

  # expects all pending requests for the given device and barcode
  #
  #   { "id" => "1234",
  #     "patient" => { "id" => 98,
  #                    "last_name" => "Sierra",
  #                    "first_name" => "Rudolph" },
  #     "types" => [ "TSH", "FT3", "FT4" ] }
  #
  def load_requests(device_name, barcode)
    begin
      uri = URI.join(@endpoint,"find_requests/#{[device_name, barcode].join('-')}")
      result = RestClient.get(uri.to_s)
      data = LIS::Data::Request.from_yaml(result.body, barcode)
    rescue Exception => e
      puts e
      puts e.backtrace
      data = nil
    end

    data
  end


  def set_request_status(device_name, data)
  end

  def send_result(device_name, order, result)
    barcode = order.specimen_id

    data = {
      "test_name" => order.universal_test_id,
      "value" => result.result_value,
      "unit" => result.unit,
      "status" => result.result_status,
      "flags" => result.abnormal_flags,
      "result_timestamp" => result.test_completed_at
    }

    # FIXME: WTF: should not just catch everything
    begin
      res = RestClient.post(URI.join(@endpoint, "result/#{[device_name, barcode].join('-')}").to_s, data.to_hash)
    rescue Exception => e
      puts "EXCEPTION"
      p e
    end
  end

end

