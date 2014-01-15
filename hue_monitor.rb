#!/usr/bin/env ruby

require 'json'
require 'rest-client'

class HueMonitor
  @@colors = {
    "blue" => 46920,
    "green" => 25717,
    "yellow" => 12750,
    "red" => 0
  }

  def initialize notifier
    @notifier = notifier || RestClient
  end

  def self.colors
    @@colors
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

  def set_color color
    hue_url = "http://huebridge.net.sep.com/api/jenkinsuser/lights/2/state"
    put_body = { 'hue' => @@colors[color] }.to_json
    options = { :content_type => :json }
    puts @notifier.put hue_url, put_body, options
  end

  def execute url
    jenkins_view = JSON.parse(@notifier.get url)
    statuses = jenkins_view['jobs'].map {|j| j['color']}.uniq

    if is_failed_and_building? statuses
      set_color "yellow"
    elsif is_failed? statuses
      set_color "red"
    elsif is_building? statuses and !is_failed? statuses
      set_color "blue"
    elsif is_passed? statuses
      set_color "green"
    end
  end
end

# HueMonitor.new.execute "http://jenkins.net.sep.com/view/Visium/api/json"
