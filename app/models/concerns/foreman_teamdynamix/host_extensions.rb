module ForemanTeamdynamix
  module HostExtensions
    extend ActiveSupport::Concern

    included do
      before_create :create_or_update_teamdynamix_asset
      before_destroy :retire_teamdynamix_asset
      validates :teamdynamix_asset_uid, uniqueness: { :allow_blank => true }
    end

    def td_api
      @td_api ||= TeamdynamixApi.instance
    end

    def teamdynamix_asset_status
      @teamdynamix_asset_status
    end

    def teamdynamix_asset(search = false)
      @teamdynamix_asset ||= td_api.get_asset(teamdynamix_asset_uid)

      if search && !@teamdynamix_asset && facts['serialnumber'].present?
        assets = td_api.search_asset(SerialLike: facts['serialnumber'])
        if assets.length == 1
          @teamdynamix_asset = td_api.get_asset(assets.first['ID'])
          self.teamdynamix_asset_uid = teamdynamix_asset['ID']
          @teamdynamix_asset_status = :updated_search
        elsif assets.length > 1
          errors.add(:base, _("Search for asset in TeamDynamix failed: Found #{assets.length} matching assets"))
        end
      end

      @teamdynamix_asset
    end

    def create_or_update_teamdynamix_asset(save = false)
      if teamdynamix_asset(true)
        td_api.update_asset(self)
        @teamdynamix_asset_status ||= :updated_id
        self.save(validate: false) if save
      elsif errors.empty?
        @teamdynamix_asset = td_api.create_asset(self)
        self.teamdynamix_asset_uid = teamdynamix_asset['ID']
        @teamdynamix_asset_status = :created
        self.save(validate: false) if save
      else
        false
      end
    rescue StandardError => e
      errors.add(:base, _("Could not create or update the asset for the host in TeamDynamix: #{e.message}"))
      false
    end

    private

    def retire_teamdynamix_asset
      td_api.retire_asset(self) if teamdynamix_asset
    rescue StandardError => e
      errors.add(:base, _("Could not retire the asset for the host in TeamDynamix: #{e.message}"))
      false
    end
  end
end
