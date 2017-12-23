# This calls the main test_helper in Foreman-core
SETTINGS[:team_dynamix] = { apiUrl: 'https://api.teamdynamix.com/TDWebApi/api',
                            appID: 'testAppID',
                            fields: {} }
require 'fake_team_dynamix_api'

require 'test_helper'

class TeamDynamixApi
  def initialize
    FakeTeamDynamixApi.new
  end
  
  def create_asset(host)
    true
  end
  
  def get_asset(asset_id)
  end
end

# Add plugin to FactoryBot's paths
FactoryBot.definition_file_paths << File.join(File.dirname(__FILE__), 'factories')
FactoryBot.reload
