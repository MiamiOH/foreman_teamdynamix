require 'net/http'
class TeamDynamixApi
  if SETTINGS[:teamdynamix].blank?
    raise('Missing configurations for the plugin see https://github.com/MiamiOH/foreman_teamdynamix')
  end
  if SETTINGS[:teamdynamix][:appID].blank?
    raise('Missing AppID in plugin settings')
  end
  TD_APP_ID = SETTINGS[:teamdynamix][:appID]
  TD_API_URL = SETTINGS[:teamdynamix][:apiUrl] || 'https://api.teamdynamix.com/TDWebApi/api'

  def self.get_asset(asset_id)
    url = TD_API_URL + "/#{TD_APP_ID}/assets/#{asset_id}" # URI.parse
    req = Net::HTTP::Get.new(url.to_s)
    res = Net::HTTP.start(url.host, url.port) do |http|
      http.request(req)
    end
    JSON.parse(res.body)
  end
end
