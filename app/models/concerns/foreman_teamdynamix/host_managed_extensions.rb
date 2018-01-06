module ForemanTeamdynamix
  module HostManagedExtensions
    extend ActiveSupport::Concern

    def td_api
      @td_api || TeamdynamixApi.new
    end

    included do
      after_create :create_teamdynamix_asset
    end

    def create_teamdynamix_asset
      asset = td_api.create_asset(self)
      self.teamdynamix_asset_id = asset['ID']
      self.save
      self.save!(:validate => false) # don't want to trigger callbacks
    end

  end
end
