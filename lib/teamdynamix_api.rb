require 'net/http'
class TeamdynamixApi
  if SETTINGS[:teamdynamix].blank?
    raise('Missing configurations for the plugin see https://github.com/MiamiOH/foreman_teamdynamix')
  end
  API_CONFIG = SETTINGS[:teamdynamix][:api]

  if API_CONFIG[:id].blank?
    raise('Missing Team Dynamix AppID in plugin settings')
  end
  APP_ID = API_CONFIG[:id]

  if API_CONFIG[:url].blank?
    raise('Missing Team Dynamix API URL in plugin settings')
  end
  API_URL = API_CONFIG[:url]

  def get_asset(asset_id)
    uri = URI.parse(API_URL + "/#{APP_ID}/assets/#{asset_id}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    # set verb
    req = Net::HTTP::Get.new(uri)
    # set headers
    req.add_field('Authorization', 'Bearer ' + auth_token)
    # send request
    res = http.start do |http_handler|
      http_handler.request(req)
    end
    # return response
    parse_response(res)
  end

  def create_asset(host)
    uri = URI.parse(API_URL + "/#{APP_ID}/assets")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    # set verb
    req = Net::HTTP::Post.new(uri)
    # set headers
    req.add_field('Authorization', 'Bearer ' + auth_token)
    req.add_field('Content-Type', 'application/json')
    # set payload
    req.body = payload_to_create_asset(host)
    # send request
    res = http.start do |http_handler|
      http_handler.request(req)
    end
    # return response
    parse_response(res)
  end

  private

  def auth_token
    return @auth_token if @auth_token
    uri = URI.parse(API_URL + '/auth')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    # set verb
    req = Net::HTTP::Post.new(uri)
    # set headers
    req.add_field('Content-Type', 'application/json')
    # set payload
    req.body = { username: API_CONFIG[:username],
                 password: API_CONFIG[:password] }.to_json
    # send request
    res =  http.start do |http_handler|
      http_handler.request(req)
    end
    # return response
    token = parse_response(res)
    valid_auth_token?(token) ? @auth_token = token : raise("Invalid auth token #{token}")
  end

  def parse_response(res)
    begin
      res_body = JSON.parse(res.body)
    rescue JSON::ParserError
      res_body = res.body
    end
    case res.code
    when /20(.)/ then res.body
    else
      raise({ status: res.code, msg: res.msg, body: res_body }.to_json)
    end
  end

  def valid_auth_token?(token)
    token.match(/^[a-zA-Z0-9\.\-\_]*$/)
  end

  def payload_to_create_asset host
    # ToDo: OwningCustomerID, mu.ci.Lifecycle Status, mu.application.software.Type
    { AppID: APP_ID, StatusID: API_CONFIG[:status_id], SerialNumber: host.name }.to_json
  end
end
