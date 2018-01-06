module ForemanTeamdynamix
  module HostsHelperExtensions
    extend ActiveSupport::Concern
    DEFAULT_TD_PANE_FIELDS = { 'Asset ID': 'ID', 'Owner': 'OwningCustomerName', 'Parent Asset': 'ParentID' }

    def td_tab_title
      SETTINGS[:team_dynamix][:title] ? SETTINGS[:team_dynamix][:title] : 'Team Dynamix'
    end

    def td_api
      @td_api || TeamDynamixApi.new
    end

    def teamdynamix_fields(host)
      return ["No TeamDynamix Asset is linked to this host"] unless host.td_asset_id

      td_pane_fields = SETTINGS[:team_dynamix][:fields] || DEFAULT_TD_PANE_FIELDS
      @asset = td_api.get_asset(host.td_asset_id)
      
      fields = []
      td_pane_fields.each do |field_name, asset_attr|
        asset_attr_val = @asset.has_key?(asset_attr) ? @asset[asset_attr] : get_nested_attrib_val(asset_attr)
        fields += [[_(field_name.to_s), asset_attr_val]]
      end
      fields
    rescue StandardError => e
      ["Error getting asset Data from Team Dynamix: #{e.message}"]
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
