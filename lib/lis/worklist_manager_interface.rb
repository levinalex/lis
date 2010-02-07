class WorklistManagerInterface
  def initialize(endpoint)
    @endpoint = endpoint
  end

  def load_requests(barcode)
    begin
      uri = URI.join(@endpoint,"find_requests/#{barcode}")
      result = fetch_with_redirect(uri.to_s)
      data = YAML.load(result.body)
      data["id"] = barcode
    rescue Exception => e
      puts e
      puts e.backtrace
      data = nil
    end
  end

  def send_result(patient, order, result)
    barcode = order.specimen_id
    data = {
      "test_name" => order.test_id,
      "value" => result.value,
      "unit" => result.unit,
      "status" => result.result_status,
      "flags" => result.abnormal_flags,
      "result_timestamp" => result.timestamp
    }

    Net::HTTP.post_form(URI.join(@endpoint, "result/#{URI.encode(barcode)}"), data.to_hash)
  end


  private

  def fetch_with_redirect(uri_str, limit = 10)
    raise ArgumentError, 'HTTP redirect too deep' if limit == 0

    response = Net::HTTP.get_response(URI.parse(uri_str))
    case response
      when Net::HTTPSuccess     then response
      when Net::HTTPRedirection then fetch_with_redirect(response['location'], limit - 1)
    else
      response.error!
    end
  end
end