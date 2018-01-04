# This calls the main test_helper in Foreman-core
SETTINGS[:team_dynamix] || { api: { url: 'https://api.teamdynamix.com/TDWebApi/api',
                                    id: 'testAppID',
                                    username: 'a_valid_username',
                                    password: 'a_valid_pwd'
                                  },
                            fields: {} }
require 'test_helper'

# Add plugin to FactoryBot's paths
FactoryBot.definition_file_paths << File.join(File.dirname(__FILE__), 'factories')
FactoryBot.reload
