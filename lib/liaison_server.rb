#!/usr/bin/env ruby

require 'optparse'
require 'net/http'
require 'yaml'

require 'rubygems'

require File.join(File.dirname(__FILE__),'liaison_labor.rb')

class Hash
  def symbolize_keys
    inject({}) do |options, (key, value)|
      options[(key.to_sym rescue key) || key] = value
      options
    end
  end

  def stringify_keys
    inject({}) do |options, (key, value)|
      options[key.to_s] = value
      options
    end
  end
end


module Diasorin
  ConfigFilename = ".liaison_server"
  ConfigFile = File.join(ENV['HOME'] || ENV['APPDATA'], ConfigFilename)

  # defaults are used when they are not overwritten in a config file
  # or with command line options
  #
  DefaultConfig = {
    :serial_port => "/dev/ttyUSB0",
    :baudrate => 9600,
    :endpoint => "http://localhost/liaison/"
  }

  class LiaisonServer

    # load configuration from configfile, merge with
    # default options
    #
    def load_configuration
     # try to read configuration from file
      @options_from_file = YAML.load_file(ConfigFile) || {} rescue {}
      @options_from_file = @options_from_file.symbolize_keys

      # if an option is not given on the command line
      # it is taken from the config file, or the default is used
      @options = DefaultConfig.merge(@options_from_file)
    end

    # parse command line options
    #
    def initialize
      load_configuration

      @opts = OptionParser.new do |opts|

        opts.separator ""
        opts.separator "liaison_labor is an interface between the Liaison device connected via "
        opts.separator "serial port, and a worklist_manager HTTP-server"
        opts.separator ""
        opts.separator "configuration can be given in '#{ConfigFile}' "
        opts.separator ""

        opts.on "-V","--version","Display version and exit" do
          puts "#{self.class} #{::LiaisonLabor::VERSION}"
          exit
        end
        opts.on "-s", "--serial-port DEVICE", "serial port, default is /dev/ttyUSB0"  do |arg|
          @options[:serial_port] = arg
        end
        opts.on "--baudrate BAUDRATE", "baudrate of the serial connection, default is 9600" do |arg|
          @options[:baudrate] = arg.to_i
        end
        opts.on "-u", "--uri URI", "URI of the HTTP-Endpoint where data is read or posted" do |arg|
          @options[:endpoint] = arg
        end
        opts.on_tail "-p", "--print-config", "Print the current configuration",
                                             "in a format that can be used as a configuration file" do
          puts @options_from_file.merge(@options).stringify_keys.to_yaml
          exit
        end
      end
    end


    # open the serial port for reading and writing
    #
    # make sure that output buffering is disabled so that data
    # is sent immediately
    #
    def open_port(portfile, speed)
      system("stty -echo raw ospeed #{speed} ispeed #{speed} < #{portfile}")
      port = File.open(portfile, "w+")
      port.sync = true
      port
    end

    def communicate!
      port = open_port(@options[:serial_port], @options[:baudrate])

      client = Liaison::Interface.new(port) do |liaison|

        # yields the barcode of a sample
        #
        # expects a hash consisting of patient information and a list
        # of requests for this patient
        #
        liaison.on_order_request do |barcode|
          begin
            uri = URI.join(@options[:endpoint],"find_requests/",barcode) 
            data = YAML.load(::Net::HTTP.get(uri)) 
          rescue Exception => e
            puts e
            puts e.backtrace
            data = nil
          end
          p data
          data
        end

        liaison.on_result do |patient, order, result, comment|
          if comment
            comment_str = comment.comment
          else
            comment_str = nil
          end

          barcode = order.specimen_id
          data = {
            "test_name" => order.test_id,
            "value" => result.value,
            "unit" => result.unit,
            "status" => result.result_status,
            "flags" => result.abnormal_flags,
            "comment" => comment_str,
            "result_timestamp" => result.timestamp
          }

          ::Net::HTTP.post_form(URI.join(@options[:endpoint], "result/", "#{URI.encode(barcode)}"), data.to_hash )
        end
      end

      client.run

      puts "Listening on #{File.expand_path(port.path)}"

      begin
        yield client if block_given?
        client.join
      rescue Interrupt => e
        puts "exiting"
        raise
      end
    end

    # run the application
    #
    def run!(args = ARGV)
      @opts.parse!(args)

      communicate!
    end
  end
end
