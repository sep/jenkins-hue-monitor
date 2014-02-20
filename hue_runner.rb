#!/usr/bin/env ruby

require 'rest-client'
require 'trollop'
require_relative 'hue_monitor'

options = Trollop::options do
  opt :hue_url, "URL for the Hue light REST endpoint", :short => 'l', :type => :string
  opt :jenkins_url, "URL for the Jenkins 'view'", :short => 'j', :type => :string
  opt :color_failed, "Color for 'failed' status", :short => 'f', :type => :string
  opt :color_failed_building, "Color for 'failed building' status", :short => 'w', :type => :string
  opt :color_building, "Color for 'building' status", :short => 'b', :type => :string
  opt :color_passed, "Color for 'passed' status", :short => 'p', :type => :string
end

puts options

HueMonitor
  .new(RestClient, {
    building: options[:color_building],
    passed: options[:color_passed],
    failed_building: options[:color_failed_building],
    failed: options[:color_failed]
  }.reject{|k,v| v.nil?})
  .execute(options[:jenkins_url], options[:hue_url])
