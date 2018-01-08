module ForemanTeamdynamix
  module HostsHelperExtensions
    extend ActiveSupport::Concern
    DEFAULT_TD_PANE_FIELDS = { 'Asset ID': 'ID', 'Owner': 'OwningCustomerName', 'Parent Asset': 'ParentID' }

    def td_tab_title
      SETTINGS[:team_dynamix][:title] ? SETTINGS[:team_dynamix][:title] : 'Team Dynamix'
    end

    def teamdynamix_fields
      td_pane_fields = SETTINGS[:team_dynamix][:fields] || DEFAULT_TD_PANE_FIELDS      
      fields = []
      td_pane_fields.each do |field_name, asset_attr|
        asset_attr_val = @asset.has_key?(asset_attr) ? @asset[asset_attr] : get_nested_attrib_val(asset_attr)
        fields += [[_(field_name.to_s), asset_attr_val]]
      end
      fields
    rescue StandardError => e
      [e.message]
    end

    def td_asset_uri
      config_api_url = SETTINGS[:team_dynamix][:api][:url]
      config_api_url.split('api').first + @asset['Uri']
    end

    def get_nested_attrib_val nested_attrib
      parent_attrib, child_attrib = nested_attrib.split(".'")
      child_attrib.gsub!(/'/, '')
      asset_attrib = @asset[parent_attrib].select { |attrib| attrib['Name'] == child_attrib }
      return '' unless asset_attrib.present?
      asset_attrib[0]['Value']
    end
  end
end
