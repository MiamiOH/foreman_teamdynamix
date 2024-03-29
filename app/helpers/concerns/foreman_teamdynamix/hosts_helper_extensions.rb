module ForemanTeamdynamix
  module HostsHelperExtensions
    extend ActiveSupport::Concern
    DEFAULT_TD_PANE_FIELDS = { 'Asset ID' => 'ID',
                               'Owner' => 'OwningCustomerName',
                               'Parent Asset' => 'ParentID' }.freeze

    def teamdynamix_title
      SETTINGS[:teamdynamix][:title] || 'TeamDynamix'
    end

    def teamdynamix_fields
      td_pane_fields = SETTINGS[:teamdynamix][:fields] || DEFAULT_TD_PANE_FIELDS
      return [[_('Asset'), 'None Associated or error from Team Dynamix']] unless @host.teamdynamix_asset

      @asset = @host.teamdynamix_asset

      # display a link to the asset if url set
      fields = asset_uri(td_pane_fields)

      td_pane_fields.except(:url).each do |field_name, asset_attr|
        asset_attr_val = @asset.key?(asset_attr) ? @asset[asset_attr] : get_nested_attrib_val(asset_attr)
        fields += [[_(field_name.to_s), asset_attr_val]] if asset_attr_val.present?
      end
      fields
    rescue StandardError => e
      [[_('Error'), e.message]]
    end

    private

    def asset_uri(td_pane_fields)
      if td_pane_fields[:url]
        uri = "#{td_pane_fields[:url]}/#{@asset['AppID']}/Assets/AssetDet?AssetID=#{@asset['ID']}"
        [[_('URI'), link_to(@asset['Name'], uri, target: '_blank', rel: 'noopener')]]
      else
        []
      end
    end

    def get_nested_attrib_val(nested_attrib)
      nested_attrib_tokens = nested_attrib.split('.')
      parent_attrib = nested_attrib_tokens.first
      child_attrib = nested_attrib_tokens[1..nested_attrib_tokens.length].join('.')
      return '' if parent_attrib.blank? || child_attrib.blank?

      child_attrib.delete!("'")
      parent_attrib_val = @asset[parent_attrib]
      return '' if parent_attrib_val.blank?

      nested_attrib_val = parent_attrib_val.find { |attrib| attrib['Name'] == child_attrib }
      return '' if nested_attrib_val.blank?

      nested_attrib_val['Value']
    end
  end
end
