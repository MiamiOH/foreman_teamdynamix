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
      td_api.create_asset(self)
    end

  end
end
