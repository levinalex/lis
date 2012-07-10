module LIS
  module CLI
    extend GLI::App
    program_desc "LIS interface to Siemens Immulite 2000XPi or other similar analyzers"
    version LIS::VERSION

    flag ["config","c"], default_value: File.join(ENV['HOME'],'.lis'),
                   desc: "stores configuration and authentication data",
                   arg_name: "FILE"


    flag ["listen", "l"], arg_name: "PORT", desc: "which port to listen on", default_value: "/dev/ttyUSB0"
    flag ["endpoint", "e"], arg_name: "URI", desc: "HTTP endpoint", default_value: "http://localhost/api/lis"
    switch ["verbose", "v"], desc: "Increase verbosity"

    pre do |global_options,command,options,args|
      $VERBOSE = global_options[:verbose]
      true
    end

    desc "run the LIS server"
    command "server" do |c|
      c.action do |global_options,options,args|
        warn "listening on: #{global_options[:listen]}"
        port = File.open(global_options[:listen], "w+")
        LIS::InterfaceServer.listen(port, global_options[:endpoint]).run!
      end
    end


  end
end
