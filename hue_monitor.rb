require 'json'

class HueMonitor
  @@color_defaults = {
    building: 46920,
    passed: 25717,
    failed_building: 12750,
    failed: 0,
    unstable: 6000
  }

  @@saturation_default = 255
  @@brightness_default = 255

  def initialize(notifier, options = {})
    @colors = @@color_defaults.dup.merge(options[:colors] || {})
    @colors.keys.each{|k| @colors[k] = @colors[k].to_i}

    @brightness = (options[:brightness] || @@brightness_default).to_i
    @saturation = (options[:saturation] || @@saturation_default).to_i
    @notifier = notifier
  end

  def self.colors
    @@color_defaults
  end

  def is_building? statuses
    statuses.any? {|status| status =~ /_anime/}
  end

  def has_failure? statuses
    statuses.include? "red" or statuses.include? "red_anime"
  end

  def is_passed? statuses
    !has_failure? statuses and !has_unstable? statuses
  end

  def has_unstable? statuses
    statuses.include? "yellow" or statuses.include? "yellow_anime"
  end

  def set_color color, url
    hue_url = URI(url)
    put_body = { 'hue' => @colors[color], 'bri' => @brightness, 'sat' => @saturation }
    http_headers = { 'Content-Type' => 'application/json' }

    @notifier.put hue_url, put_body, http_headers
  end

  def execute jenkins_url, hue_url
    jenkins_view = JSON.parse(@notifier.get URI(jenkins_url))
    statuses = jenkins_view['jobs'].map {|j| j['color']}.uniq

    if is_building? statuses
      if has_failure? statuses
        set_color :failed_building, hue_url
      else
        set_color :building, hue_url
      end
    else
      if has_failure? statuses
        set_color :failed, hue_url
      elsif has_unstable? statuses
        set_color :unstable, hue_url
      elsif is_passed? statuses
        set_color :passed, hue_url
      end
    end
  end
end
