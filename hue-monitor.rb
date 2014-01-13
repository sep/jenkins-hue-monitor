#!/usr/bin/env ruby

require 'json'
require 'rest-client'

class HueThing
  def initialize
    @status_colors = {
      "blue" => 46920,
      "green" => 25717,
      "yellow" => 12750,
      "red" => 0
    }
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
    put_body = { 'hue' => @status_colors[color] }.to_json
    options = { :content_type => :json }
    puts RestClient.put hue_url, put_body, options
  end

  def execute
    jenkins_view = JSON.parse(RestClient.get "http://jenkins.net.sep.com/view/Visium/api/json")
    statuses = jenkins_view['jobs'].map {|j| j['color']}.uniq

    set_color "yellow" if is_failed_and_building? statuses
    set_color "red" if is_failed? statuses
    set_color "blue" if is_building? statuses and !is_failed? statuses
    set_color "green" if is_passed? statuses
  end
end

HueThing.new.execute
