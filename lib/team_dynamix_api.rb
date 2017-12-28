require 'net/http'

class TeamDynamixApi
  if SETTINGS[:team_dynamix].blank? || SETTINGS[:team_dynamix][:api].blank?
    raise('Missing configurations for the plugin see https://github.com/MiamiOH/foreman_teamdynamix')
  end
  API_CONFIG = SETTINGS[:team_dynamix][:api]

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
    req.add_field('Authorization', auth_token)
    # send request
    res = Net::HTTP.start(uri.host, uri.port) do |http|
      http.request(req)
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
    req.add_field('Authorization', auth_token)
    req.add_field('Content-Type', 'application/json')
    # set payload
    req.body = payload_to_create_asset(host)
    puts "\n\n req.body #{req.body}"
    # send request
    res = Net::HTTP.start(uri.host, uri.port) do |http|
      http.request(req)
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
    res =  http.start do |http|
      http.request(req)
    end
    # return response
    @auth_token = parse_response(res)
  end

  def parse_response res
    case res.code
    when '200' || '201' then
      return res.body
    else
      raise res.msg
    end
  end

  def payload_to_create_asset host
    {AppID: APP_ID, OwningCustomerID: 'test'}.to_json
  end
end
