# This calls the main test_helper in Foreman-core
SETTINGS[:teamdynamix] = { apiUrl: 'https://api.teamdynamix.com/TDWebApi/api',
                           appID: 'testAppID',
                           fields: {} }
require 'test_helper'
# Add plugin to FactoryBot's paths
FactoryBot.definition_file_paths << File.join(File.dirname(__FILE__), 'factories')
FactoryBot.reload
