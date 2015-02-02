class RestClientAbstraction
  def get(jenkins_url)
    Net::HTTP.get(jenkins_url)
  end
    
  def put(hue_url, put_body, http_headers)
    http = Net::HTTP.new hue_url.host
    request = Net::HTTP::Put.new(hue_url.path)
    request.body = put_body.to_json
    http_headers.each {|header, value| request[header] = value }
    http.request(request)
  end
end
