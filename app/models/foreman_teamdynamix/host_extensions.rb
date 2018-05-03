module ForemanTeamdynamix
  module HostExtensions
    extend ActiveSupport::Concern

    included do
      include Orchestration::Teamdynamix
      before_destroy :retire_teamdynamix_asset
      validates :teamdynamix_asset_uid, uniqueness: { :allow_blank => true }
    end

    def td_api
      @td_api ||= TeamdynamixApi.instance
    end

    private

    def retire_teamdynamix_asset
      td_api.retire_asset(teamdynamix_asset_uid) if teamdynamix_asset_uid
    rescue StandardError => e
      errors.add(:base, _("Could not retire the asset for the host in TeamDynamix: #{e.message}"))
      false
    end
  end
end
