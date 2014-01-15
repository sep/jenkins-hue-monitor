#!/usr/bin/env ruby

require 'json'

class HueMonitor
  @@colors = {
    "blue" => 46920,
    "green" => 25717,
    "yellow" => 12750,
    "red" => 0
  }

  def initialize notifier
    @notifier = notifier
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

  def set_color color, url
    hue_url = url
    put_body = { 'hue' => @@colors[color] }.to_json
    options = { :content_type => :json }
    puts @notifier.put hue_url, put_body, options
  end

  def execute jenkins_url, hue_url
    jenkins_view = JSON.parse(@notifier.get jenkins_url)
    statuses = jenkins_view['jobs'].map {|j| j['color']}.uniq

    if is_failed_and_building? statuses
      set_color "yellow", hue_url
    elsif is_failed? statuses
      set_color "red", hue_url
    elsif is_building? statuses and !is_failed? statuses
      set_color "blue", hue_url
    elsif is_passed? statuses
      set_color "green", hue_url
    end
  end
end

