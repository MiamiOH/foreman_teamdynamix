module ForemanTeamdynamix
  module HostsHelperExtensions
    extend ActiveSupport::Concern
    DEFAULT_ASSET_ATTRS = { 'Asset ID': 'ID'.freeze, 'Owner': 'OwningCustomerName'.freeze, 'Parent Asset': 'ParentID'.freeze }

    def td_tab_title
      SETTINGS[:team_dynamix][:title] || 'Team Dynamix'
    end

    def teamdynamix_tab_fields
      asset_attrs = SETTINGS[:team_dynamix][:asset_attributes] || DEFAULT_ASSET_ATTRS

      @asset = TdApi.get_asset(@host.asset_id)

      fields = []
      asset_attrs.each do |field_name, asset_attr|
        asset_attr_val = @asset[asset_attr]
        fields += [[_(field_name.to_s), asset_attr_val]] if asset_attr_val.present?
      end
      fields
    rescue StandardError => e
      raise "Error getting asset Data form Team Dynamix: #{e.message}"
    end
  end
end
