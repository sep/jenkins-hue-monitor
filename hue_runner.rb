#!/usr/bin/env ruby

require 'net/http'
require 'trollop'
require_relative 'hue_monitor'
require_relative 'rest_client_abstraction'

options = Trollop::options do
  opt :hue_url, "URL for the Hue light REST endpoint", :short => 'l', :type => :string
  opt :jenkins_url, "URL for the Jenkins 'view'", :short => 'j', :type => :string
  opt :color_failed, "Color for 'failed' status", :short => 'f', :type => :string
  opt :color_failed_building, "Color for 'failed building' status", :short => 'w', :type => :string
  opt :color_building, "Color for 'building' status", :short => 'b', :type => :string
  opt :color_passed, "Color for 'passed' status", :short => 'p', :type => :string
  opt :color_unstable, "Color for 'unstable' status", :short => 'u', :type => :string
  opt :brightness, "Brightness for the light (0-lowest, 255-highest)", :short => 'r', :type => :string
  opt :saturation, "Saturation for the light (0-lowest, 255-highest)", :short => 's', :type => :string
  opt :credentials, "User credentials for Jenkins access", :short => 'c', :type => :string
end

puts options

colors = {
  building: options[:color_building],
  passed: options[:color_passed],
  failed_building: options[:color_failed_building],
  failed: options[:color_failed],
  unstable: options[:color_unstable]
}.reject{|k,v| v.nil?}

runner_options = {
  brightness: options[:brightness],
  saturation: options[:saturation],
  credentials: options[:credentials]
}

jenkins_url = options[:jenkins_url]
hue_url = options[:hue_url]

HueMonitor
  .new(RestClientAbstraction.new, runner_options)
  .execute(jenkins_url, hue_url)
