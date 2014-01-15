#!/usr/bin/env ruby

require 'rest-client'
require 'trollop'
require_relative 'hue_monitor'

options = Trollop::options do
  opt :hue_url, "URL for the Hue light REST endpoint", :short => 'l', :type => :string
  opt :jenkins_url, "URL for the Jenkins 'view'", :short => 'j', :type => :string
end

puts options

HueMonitor.new(RestClient).execute options[:jenkins_url], options[:hue_url]
