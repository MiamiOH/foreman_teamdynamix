module ForemanTeamdynamix
  module HostExtensions
    extend ActiveSupport::Concern

    def td_api
      @td_api ||= TeamdynamixApi.instance
    end

    included do
      after_validation :create_teamdynamix_asset, on: :create
      before_destroy :retire_teamdynamix_asset
      validates :teamdynamix_asset_id, uniqueness: { :allow_blank => true }
    end

    private

    def create_teamdynamix_asset
      asset = td_api.create_asset(self)
      self.teamdynamix_asset_id = asset['ID']
    rescue StandardError => e
      errors.add(:base, _("Could not create the asset for the host in TeamDynamix: #{e.message}"))
      return false
    end

    def retire_teamdynamix_asset
      td_api.retire_asset(self.teamdynamix_asset_id) if self.teamdynamix_asset_id
    rescue StandardError => e
      errors.add(:base, _("Could not retire the asset for the host in TeamDynamix: #{e.message}"))
      return false
    end
  end
end
