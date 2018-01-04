require 'test_helper'
require 'fake_team_dynamix_api'

module Host
  class ManagedTest < ActiveSupport::TestCase
    let(:host) { FactoryBot.create(:host, :managed) }
    let(:td_api) { FakeTeamDynamixApi.new } 
    before do
      Host::Managed.any_instance.stubs(:td_api).returns(td_api)
    end
    
    describe '#create' do    
      it 'triggers after_create callback on Host::Managed model' do
        assert_send([Host::Managed, :after_create, :create_td_asset])
      end
      
      it 'calls Teamdynamix API to create an asset' do
        assert_send([td_api, :create_asset, host])
      end

      it 'sets host#td_asset_id' do
        assert_not_nil(host.td_asset_id)
      end
    end
  end
end
