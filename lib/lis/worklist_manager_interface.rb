require 'net/http'
require 'yaml'

class WorklistManagerInterface
  def initialize(endpoint)
    @endpoint = endpoint
  end

  def load_requests(device_name, barcode)
    begin
      uri = URI.join(@endpoint,"find_requests/#{[device_name, barcode].join('-')}")
      result = fetch_with_redirect(uri.to_s)
      data = YAML.load(result.body)
      data["id"] = barcode
    rescue Exception => e
      puts e
      puts e.backtrace
      data = nil
    end

    data
  end

  def send_result(device_name, patient, order, result)
    barcode = order.specimen_id
    data = {
      "test_name" => order.universal_test_id,
      "value" => result.result_value,
      "unit" => result.unit,
      "status" => result.result_status,
      "flags" => result.abnormal_flags,
      "result_timestamp" => result.test_completed_at
    }

    p data
    begin
      res = Net::HTTP.post_form(URI.join(@endpoint, "result/#{[device_name, barcode].join('-')}"), data.to_hash)
    rescue Exception => e
      puts "EXCEPTION"
      p e
    end
  end


  private

  def fetch_with_redirect(uri_str, limit = 10)
    raise ArgumentError, 'too many HTTP redirects' if limit == 0

    response = Net::HTTP.get_response(URI.parse(uri_str))
    case response
      when Net::HTTPSuccess     then response
      when Net::HTTPRedirection then fetch_with_redirect(response['location'], limit - 1)
    else
      response.error!
    end
  end
end
