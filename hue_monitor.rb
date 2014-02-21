#!/usr/bin/env ruby

require 'json'

class HueMonitor
  @@color_defaults = {
    building: 46920,
    passed: 25717,
    failed_building: 12750,
    failed: 0
  }

  @@brightness_default = 100

  def initialize(notifier, colors = nil, brightness = nil)
    @colors = @@color_defaults.dup.merge(colors || {})
    @brightness ||= brightness
    @notifier = notifier
  end

  def self.colors
    @@color_defaults
  end

  def is_building? statuses
    statuses.include? "red_anime" or statuses.include? "blue_anime"
  end

  def is_failed_and_building? statuses
    statuses.include? "red_anime" or (statuses.include? "red" and statuses.include? "blue_anime")
  end

  def is_failed? statuses
    statuses.include? "red" and !is_building? statuses
  end

  def is_passed? statuses
    statuses.include? "blue" and statuses.size == 1
  end

  def set_color color, url
    hue_url = url
    put_body = { 'hue' => @colors[color], 'bri' => @brightness }.to_json
    options = { :content_type => :json }
    puts @notifier.put hue_url, put_body, options
  end

  def execute jenkins_url, hue_url
    jenkins_view = JSON.parse(@notifier.get jenkins_url)
    statuses = jenkins_view['jobs'].map {|j| j['color']}.uniq

    if is_failed_and_building? statuses
      set_color :failed_building, hue_url
    elsif is_failed? statuses
      set_color :failed, hue_url
    elsif is_building? statuses and !is_failed? statuses
      set_color :building, hue_url
    elsif is_passed? statuses
      set_color :passed, hue_url
    end
  end
end

