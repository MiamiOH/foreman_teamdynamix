module ForemanTeamdynamix
  module HostManagedExtensions
    extend ActiveSupport::Concern
    attr_writer :td_api

    def td_api
      @td_api || TeamDynamixApi.new
    end

    included do
      after_create :create_td_asset
    end

    def create_td_asset
      asset = td_api.create_asset(self)
      self.td_asset_id = asset['ID']
      self.save
    end
  end
end
