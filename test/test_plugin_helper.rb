def override_settings
  SETTINGS[:team_dynamix] = { api: {  url: 'https://api.teamdynamix.com/TDWebApi/api',
                                      id: 'testAppID',
                                      username: 'a_valid_username',
                                      password: 'a_valid_pwd' } }
end
override_settings unless SETTINGS[:team_dynamix]

def get_direct_asset_attribs_val config
  direct_attrib_fields = []
  config.each do |tag, attr_name|
    direct_attrib_fields << [tag, sample_asset[attr_name]]
  end
  direct_attrib_fields
end

def get_nested_asset_attribs_val config
  nested_attrib_fields = []
  config.each do |tag, nested_attrib|
    parent_attrib, child_attrib = nested_attrib.split(".'")
    child_attrib.delete!("'")
    attrib_val = sample_asset[parent_attrib].select { |attrib| attrib['Name'] == child_attrib }[0]['Value']
    nested_attrib_fields << [tag, attrib_val]
  end
  nested_attrib_fields
end
# This calls the main test_helper in Foreman-core
require 'test_helper'
