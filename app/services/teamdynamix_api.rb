require 'net/http'
class TeamdynamixApi
  include Singleton

  if SETTINGS[:teamdynamix].blank?
    raise('Missing configurations for the plugin see https://github.com/MiamiOH/foreman_teamdynamix')
  end
  API_CONFIG = SETTINGS[:teamdynamix][:api]

  raise('Missing Team Dynamix Api ID in plugin settings') if API_CONFIG[:appId].blank?
  APP_ID = API_CONFIG[:appId]

  raise('Missing Team Dynamix API URL in plugin settings') if API_CONFIG[:url].blank?
  API_URL = API_CONFIG[:url]

  def initialize
    @auth_token = request_token
    raise('Invalid authentication token') unless valid_auth_token?(@auth_token)
  end

  # returns TeamDynamix.Api.Assets.Asset
  def get_asset(asset_id)
    uri = URI.parse(API_URL + "/#{APP_ID}/assets/#{asset_id}")
    rest(:get, uri)
  end

  def asset_exist?(asset_id)
    get_asset(asset_id).present?
  end

  def create_asset(host)
    uri = URI.parse(API_URL + "/#{APP_ID}/assets")
    rest(:post, uri, create_asset_payload(host))
  end

  def update_asset(host)
    uri = URI.parse(API_URL + "/#{APP_ID}/assets/#{host.teamdynamix_asset_id}")
    rest(:post, uri, update_asset_payload(host))
  end

  def retire_asset(asset_id)
    uri = URI.parse(API_URL + "/#{APP_ID}/assets/#{asset_id}")
    rest(:post, uri, retire_asset_payload(asset_id))
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
    req.add_field('Authorization', 'Bearer ' + @auth_token)
    # send request
    res = http.start do |http_handler|
      http_handler.request(req)
    end
    # return response
    parse_response(res)
  end

  def request_token
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
    parse_response(res)
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

  def retire_asset_payload(asset_id)
    asset = get_asset(asset_id)
    asset.merge(API_CONFIG[:delete].stringify_keys)
  end

  def create_asset_payload(host)
    ensure_configured_create_params
    default_attrs = { AppID: APP_ID,
                      SerialNumber: host.name,
                      Name: host.fqdn }
    create_attrs = API_CONFIG[:create].symbolize_keys
    evaluate_attributes(host, create_attrs)
    default_attrs.merge(create_attrs)
  end

  def evaluate_attributes(host, create_attrs)
    if create_attrs[:Attributes].present?
      create_attrs[:Attributes].each do |attribute|
        attribute.transform_keys!(&:downcase)
        attribute['value'] = eval("\"#{attribute['value']}\"")
      end
    end
  end

  def must_configure_create_params
    [:StatusID]
  end

  def valid_auth_token?(token)
    token.match(/^[a-zA-Z0-9\.\-\_]*$/)
  end

  def update_asset_payload(host)
    payload = { ID: host.teamdynamix_asset_id }
    payload.merge(create_asset_payload(host))
  end

  def ensure_configured_create_params
    must_configure_create_params.each do |must_configure_param|
      unless API_CONFIG[:create].include?(must_configure_param)
        raise("#{must_configure_param} is required. Set it as a configuration item.")
      end
    end
  end
end
