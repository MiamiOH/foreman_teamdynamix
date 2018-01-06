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
        asset_attr_val = @asset.has_key?(asset_attr) ? @asset[asset_attr] : get_nested_attrib_val(asset_attr)
        fields += [[_(field_name.to_s), asset_attr_val]]
      end
      fields
    rescue StandardError => e
      [[_('Error'), e.message]]
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
