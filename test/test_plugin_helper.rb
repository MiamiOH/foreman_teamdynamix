def override_settings
  SETTINGS[:teamdynamix] = { api: { url: 'https://api.teamdynamix.com/TDWebApi/api',
                                    appId: '111',
                                    username: 'a_valid_username',
                                    password: 'a_valid_pwd' } }
end
override_settings

def get_direct_asset_attribs_val(config)
  direct_attrib_fields = []
  config.each do |tag, attr_name|
    direct_attrib_fields << [tag, sample_asset[attr_name]]
  end
  direct_attrib_fields
end

def get_nested_asset_attribs_val(config)
  nested_attrib_fields = []
  config.each do |tag, nested_attrib|
    parent_attrib, child_attrib = nested_attrib.split(".'")
    child_attrib.delete!("'")
    attrib_val = sample_asset[parent_attrib].select { |attrib| attrib['Name'] == child_attrib }[0]['Value']
    nested_attrib_fields << [tag, attrib_val]
  end
  nested_attrib_fields
end

def sample_asset_uri
  api_url = SETTINGS[:teamdynamix][:api][:url]
  asset_uri = api_url.split('api').first + sample_asset['Uri']
  [_('URI'), link_to(sample_asset['Uri'], asset_uri, target: '_blank')]
end

require 'webmock/minitest'
WebMock.disable_net_connect!(allow_localhost: true)

require 'fake_teamdynamix_api'
require 'test_helper'
