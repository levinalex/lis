# encoding: UTF-8

require 'httparty'

class LIS::HTTPInterface
  class HTTP
    include HTTParty
    format :json
    headers 'Accept' => 'application/json', 'Content-Type' => 'application/json'
  end


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
      result = HTTP.get(uri(device_name, barcode))
      data = LIS::Data::Request.from_yaml(result.body, barcode)
    rescue Exception => e
      puts e
      puts e.backtrace
      data = nil
    end

    data
  end


  def set_request_status(device_name, data)
    # uri = URI.join(@endpoint, "result_status/#{[device_name, data.id].join('-')}")
    # Net::HTTP.post_form(uri, data.to_hash)
  end

  def send_result(device_name, order, result)
    barcode = order.specimen_id

    data = {
      "test_name" => order.universal_test_id,
      "value" => result.result_value,
      "unit" => result.unit,
      "status" => result.result_status,
      "flags" => result.abnormal_flags,
      "result_timestamp" => result.test_completed_at,
      "raw" => result.raw_data
    }

    HTTP.post(uri(device_name, barcode, order.universal_test_id), :body => data.to_json)
  end


  private

  def uri(device_name, barcode, test_name = nil)
    barcode = barcode.to_s.gsub(/[\s\/]+/,'_').gsub(/[^a-z0-9_-]/i,'')
    id = [device_name, URI.encode(barcode)].join("-")

    s = [@endpoint, id, test_name].compact.join("/")

    s
  end

end

