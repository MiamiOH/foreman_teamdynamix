# This calls the main test_helper in Foreman-core
SETTINGS[:team_dynamix] = { appID: 'testAppID',
                            asset_attributes: {} }
require 'fake_td_api'

require 'test_helper'
# Add plugin to FactoryBot's paths
FactoryBot.definition_file_paths << File.join(File.dirname(__FILE__), 'factories')
FactoryBot.reload
