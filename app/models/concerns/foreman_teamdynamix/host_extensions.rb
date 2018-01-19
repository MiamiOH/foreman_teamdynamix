module ForemanTeamdynamix
  module HostExtensions
    extend ActiveSupport::Concern

    def td_api
      @td_api ||= TeamdynamixApi.new
    end

    included do
      after_validation :create_teamdynamix_asset, on: :create
    end

    private

    def create_teamdynamix_asset
      asset = td_api.create_asset(self)
      self.teamdynamix_asset_id = asset['ID']
    end

  end
end
