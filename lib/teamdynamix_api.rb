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

  # returns TeamDynamix.Api.Assets.Asset
  def get_asset(asset_id)
    uri = URI.parse(API_URL + "/#{APP_ID}/assets/#{asset_id}")
    rest(:get, uri)
  end

  def create_asset(host)
    uri = URI.parse(API_URL + "/#{APP_ID}/assets")
    rest(:post, uri, create_asset_payload(host))
  end

  # Gets a list of assets matching the specified criteria. (IEnumerable(Of TeamDynamix.Api.Assets.Asset))
  def search_asset(search_params)
    uri = URI.parse(API_URL + "/#{APP_ID}/assets/search")
    rest(:post, uri, search_params)
  end

  private

  def rest(method, uri, payload = nil)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    # set verb, payload and headers
    if method == :post
      req = Net::HTTP::Post.new(uri)
      req.add_field('Content-Type', 'application/json')
      req.body = payload.to_json
    else
      req = Net::HTTP::Get.new(uri)
    end
    # set headers
    req.add_field('Authorization', 'Bearer ' + auth_token)
    # send request
    res = http.start do |http_handler|
      http_handler.request(req)
    end
    # return response
    parse_response(res)
  end

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
    when /20(.)/ then res_body
    else
      raise({ status: res.code, msg: res.msg, body: res_body }.to_json)
    end
  end

  def valid_auth_token?(token)
    token.match(/^[a-zA-Z0-9\.\-\_]*$/)
  end

  def create_asset_payload host
    ensure_configured_create_params
    payload = { AppID: APP_ID, 
                SerialNumber: host.name
              }
    payload.merge!(API_CONFIG[:create])      
    payload.merge(Attributes: create_asset_attributes(host))
  end
  
  def create_asset_attributes(host)
    [
      {
        ID: 11632,
        Name: 'mu.ci.Description',
        Value: "Foreman host #{host.fqdn} created by ForemanTeamdynamix plugin"
      },
      {
        ID: 11634,
        Name: 'mu.ci.Lifecycle Status',
        Value: get_lifecycle_status
      }
    ]
  end

  def get_lifecycle_status
    case Rails.env.downcase
    when 'test' then 26190
    when 'development' then 26191
    when 'stage', 'pre-production' then 26192
    when 'early-life-support' then 26194
    when 'production' then 26193
    end
  end

  def must_configure_create_params
    [:StatusID]
  end

  def ensure_configured_create_params
    must_configure_create_params.each do |must_configure_param|
      raise("#{must_configure_param} is required. Set it as a configuration item.") unless API_CONFIG[:create].include?(must_configure_param)
    end
  end
end
