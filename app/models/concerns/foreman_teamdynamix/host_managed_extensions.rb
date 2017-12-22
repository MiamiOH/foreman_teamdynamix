module ForemanTeamdynamix 
  module HostManagedExtensions 
    extend ActiveSupport::Concern 
    
    included do
      after_create :create_td_asset
    end
  
    def create_td_asset
      FakeTeamDynamixApi.new.create_asset(self)
    end
    
  end
end  