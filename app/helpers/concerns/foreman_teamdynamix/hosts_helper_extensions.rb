module ForemanTeamdynamix
  module HostsHelperExtensions
    extend ActiveSupport::Concern
    DEFAULT_TD_PANE_FIELDS = { 'Asset ID': 'ID', 'Owner': 'OwningCustomerName', 'Parent Asset': 'ParentID' }

    def teamdynamix_title
      SETTINGS[:teamdynamix][:title] || 'Team Dynamix'
    end

    def teamdynamix_fields(host)
      td_pane_fields = SETTINGS[:teamdynamix][:fields] || DEFAULT_TD_PANE_FIELDS
      return [[_('Asset'), 'None Associated']] unless host.teamdynamix_asset_id
      @asset = host.td_api.get_asset(host.teamdynamix_asset_id)

      fields = []
      td_pane_fields.each do |field_name, asset_attr|
        asset_attr_val = @asset[asset_attr]
        fields += [[_(field_name.to_s), asset_attr_val]] if asset_attr_val.present?
      end
      fields
    rescue StandardError => e
      [[_('Error'), e.message]]
    end
  end
end
