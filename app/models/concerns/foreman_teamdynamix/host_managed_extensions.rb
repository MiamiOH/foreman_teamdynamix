module ForemanTeamdynamix
  module HostManagedExtensions
    extend ActiveSupport::Concern

    included do
      after_create :create_teamdynamix_asset
    end

    def create_teamdynamix_asset
      TeamdynamixApi.new.create_asset(self)
    end

  end
end
