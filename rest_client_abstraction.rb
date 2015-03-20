class RestClientAbstraction
  def get(url, options)
    request = Net::HTTP::Get.new(url.path)

    if !options[:user].nil? && !options[:password].nil?
      request.basic_auth(options[:user], options[:password])
    end

    response = Net::HTTP.new(url.host, url.port).start do |http|
      http.request(request)
    end

    response.body
  end
    
  def put(url, put_body, http_headers)
    http = Net::HTTP.new url.host
    request = Net::HTTP::Put.new(url.path)
    request.body = put_body.to_json
    http_headers.each {|header, value| request[header] = value }
    http.request(request)
  end
end
