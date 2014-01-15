require 'trollop'
require_relative 'hue_monitor'

options = Trollop::options do
  opt :hue_url, "URL for the Hue light REST endpoint", :short => 'l'
  opt :jenkins_url, "URL for the Jenkins 'view'", :short => 'j'
end

HueMonitor.new.execute options[:jenkins_url], options[:hue_url]
# "http://jenkins.net.sep.com/view/Visium/api/json"
# "http://huebridge.net.sep.com/api/jenkinsuser/lights/2/state"
