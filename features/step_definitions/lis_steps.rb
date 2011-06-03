# encoding: UTF-8

require 'mocha'
require 'yaml'


Given /^LIS Interface listening for messages$/ do
  @client, @r, @w = PacketIO::Test::MockServer.build
  @io = PacketIO::IOListener.new(@r, @w)
  @server = LIS::InterfaceServer.create(@io, "http://localhost/lis/")

  stub_request(:post, /http:\/\/localhost\/lis\/result\/.*/).
    with(:body => /.*/, :headers => {'Accept'=>'*/*', 'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'Ruby'}).
    to_return(:status => 200, :body => "", :headers => {})

  @t = Thread.new do
    @server.run!
  end
  @t.abort_on_exception = true
end

When /^receiving data$/ do |string|
  @client.wait(0.2)
  @client.write("\005")
  string.each_line do |l|
    line, checksum = l.strip.split(/\s*,\s*/)
    checksum = line.each_byte.inject(16) { |a,b| (a+b) % 0x100 }.to_s(16) if checksum.nil?

    @client.write("\002#{line}\015\003#{checksum}\015\012")
  end
  @client.write("\004")
  @client.eof
  @t.join
end

Then /^should have posted results:$/ do |table|
  table.hashes.each do |row|
    expected_body = ["test_name", "value", "unit", "status", "flags", "result_timestamp"].inject({}) { |h,k| h[k] = row[k]; h }
    assert_requested(:post, "http://localhost/lis/result/#{row["id"]}", :times => 1, :body => expected_body)
  end
end

Then /^the server should have acknowledged (\d+) packets$/ do |packet_count|
  @data = @client.read_all
  assert_equal packet_count.to_i, @data.split(//).length
  assert @data.match(/^\006{#{packet_count}}$/), "should contain #{packet_count.to_i} ACKs, was #{@data.inspect}"
end


# FIXME: test following redirects
#
Given /^the following requests are pending for (\w+):$/ do |device_name, table|
  table.hashes.each do |patient|
    p patient

    body = { "patient" => { "last_name" => patient["last_name"],
                            "first_name" => patient["first_name"],
                            "id" => patient["patient_id"]},
             "id" => patient["id"],
             "types" => patient["test_names"].strip.split(/\s+/) }
    p body

    stub_request(:get, "http://localhost/lis/find_requests/#{device_name}-#{patient["id"]}").
      with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
      to_return(:status => 200, :body => body.to_yaml, :headers => {})

  end

end


Then /^LIS should have sent test orders to client:$/ do |text|
  @data = @client.read_all
  @packets = @data.split("\002").select { |s| s =~ /^\d[A-Z]/ }
  @packets.zip(text.lines) do |actual, expected|
    rx =  Regexp.new("^" + Regexp.escape(expected.strip))
    assert_match(rx, actual.gsub(/\r\003.*$/, "").strip)
  end
end



