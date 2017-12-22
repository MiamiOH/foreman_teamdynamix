require 'net/http'
class TeamDynamixApi
  if SETTINGS[:team_dynamix].blank?
    raise('Missing configurations for the plugin see https://github.com/MiamiOH/foreman_teamdynamix')
  end
  if SETTINGS[:team_dynamix][:appID].blank?
    raise('Missing Team Dynamix AppID in plugin settings')
  end
  TD_APP_ID = SETTINGS[:team_dynamix][:appID]
  if SETTINGS[:team_dynamix][:apiUrl].blank?
    raise('Missing Team Dynamix API URL in plugin settings')
  end
  TD_API_URL = SETTINGS[:team_dynamix][:apiUrl]    
  
  def get_asset(asset_id)
    url = TD_API_URL + "/#{TD_APP_ID}/assets/#{asset_id}" # URI.parse
    
    req = Net::HTTP::Get.new(url.to_s)
    res = Net::HTTP.start(url.host, url.port) do |http|
      http.request(req)
    end
    JSON.parse(res.body)
  end

  def create_asset(host)
    url = TD_API_URL + "/#{TD_APP_ID}/assets" # URI.parse
    
    req = Net::HTTP::Get.new(url.to_s)
    res = Net::HTTP.start(url.host, url.port) do |http|
      http.request(req)
    end
    JSON.parse(res.body)
  end
end
