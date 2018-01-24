module ForemanTeamdynamix
  module HostsHelperExtensions
    extend ActiveSupport::Concern
    DEFAULT_TD_PANE_FIELDS = { 'Asset ID': 'ID', 'Owner': 'OwningCustomerName', 'Parent Asset': 'ParentID' }

    def teamdynamix_title
      SETTINGS[:teamdynamix][:title] || 'Team Dynamix'
    end

    def teamdynamix_fields
      td_pane_fields = SETTINGS[:teamdynamix][:fields] || DEFAULT_TD_PANE_FIELDS
      return [[_('Asset'), 'None Associated']] unless @host.teamdynamix_asset_id

      get_teamdynamix_asset(@host.teamdynamix_asset_id)

      # always display a link to the asset
      fields = [ get_asset_uri ]

      td_pane_fields.each do |field_name, asset_attr|
        asset_attr_val = @asset.has_key?(asset_attr) ? @asset[asset_attr] : get_nested_attrib_val(asset_attr)
        fields += [[_(field_name.to_s), asset_attr_val]] if asset_attr_val.present?
      end
      fields
    rescue StandardError => e
      [[_('Error'), e.message]]
    end

    private
    def get_asset_uri
      api_url = SETTINGS[:teamdynamix][:api][:url]
      asset_uri = api_url.split('api').first + @asset['Uri']
      [_('URI'), link_to(@asset['Uri'], asset_uri, {target: '_blank'})]
    end

    def get_teamdynamix_asset(asset_id)
      @asset = @host.td_api.get_asset(asset_id)
    rescue StandardError => e
      raise "Error getting asset Data from Team Dynamix: #{e.message}"
    end

    def get_nested_attrib_val nested_attrib
      nested_attrib_tokens = nested_attrib.split(".")
      parent_attrib = nested_attrib_tokens.first
      child_attrib = nested_attrib_tokens[1..nested_attrib_tokens.length].join('.')
      return '' if (parent_attrib.blank? || child_attrib.blank?)
      child_attrib.delete!("'")
      parent_attrib_val = @asset[parent_attrib]
      return '' unless parent_attrib_val.present?
      nested_attrib_val = parent_attrib_val.select { |attrib| attrib['Name'] == child_attrib }
      return '' unless nested_attrib_val.present?
      nested_attrib_val[0]['Value']
    end
  end
end
