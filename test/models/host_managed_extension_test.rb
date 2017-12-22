require 'test_helper'

module Host
  class ManagedTest < ActiveSupport::TestCase
    describe '#create' do
      
      it 'triggers after_create callback on Host::Managed model' do
        host = FactoryBot.create(:host, :managed)   
        assert_send([Host::Managed, :after_create, :create_td_asset])
      end
      
      it 'calls Teamdynamix API to create an asset' do
        host = FactoryBot.create(:host, :managed)   
        assert_send([FakeTeamDynamixApi.new, :create_asset, host])
      end
      
    end
  end
end
