module ForemanTeamdynamix
  module HostsHelperExtensions
    extend ActiveSupport::Concern
    DEFAULT_TD_PANE_FIELDS = { 'Asset ID': 'ID', 'Owner': 'OwningCustomerName', 'Parent Asset': 'ParentID' }

    def td_tab_title
      SETTINGS[:team_dynamix][:title] || 'Team Dynamix'
    end

    def teamdynamix_fields(host)
      td_pane_fields = SETTINGS[:team_dynamix][:fields] || DEFAULT_TD_PANE_FIELDS
      return ["No TeamDynamix Asset is linked to this host"] unless host.td_asset_id
      @asset = TeamDynamixApi.new.get_asset(host.td_asset_id)
      fields = []
      td_pane_fields.each do |field_name, asset_attr|
        asset_attr_val = @asset[asset_attr]
        fields += [[_(field_name.to_s), asset_attr_val]] if asset_attr_val.present?
      end
      fields
    rescue StandardError => e
      ["Error getting asset Data from Team Dynamix: #{e.message}"]
    end
  end
end
