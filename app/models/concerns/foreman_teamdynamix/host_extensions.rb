module ForemanTeamdynamix
  module HostExtensions
    extend ActiveSupport::Concern

    def td_api
      @td_api ||= TeamdynamixApi.instance
    end

    included do
      before_create :create_teamdynamix_asset
      before_destroy :retire_teamdynamix_asset
      validates :teamdynamix_asset_id, uniqueness: { :allow_blank => true }
    end

    private

    def create_teamdynamix_asset
      # when the asset is already in teamdynamix
      assets = td_api.search_asset(SerialLike: name)

      if assets.empty?
        asset = td_api.create_asset(self)
        self.teamdynamix_asset_id = asset['ID']
      elsif assets.length > 1
        raise 'Found more than 1 existing asset'
      else
        self.teamdynamix_asset_id = assets.first['ID']
        td_api.update_asset(self)
      end
    rescue StandardError => e
      errors.add(:base, _("Could not create the asset for the host in TeamDynamix: #{e.message}"))
      false
    end

    def retire_teamdynamix_asset
      td_api.retire_asset(teamdynamix_asset_id) if teamdynamix_asset_id
    rescue StandardError => e
      errors.add(:base, _("Could not retire the asset for the host in TeamDynamix: #{e.message}"))
      false
    end
  end
end
