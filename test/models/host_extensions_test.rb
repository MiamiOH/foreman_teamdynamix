require 'test_helper'

class HostExtensionsTests < ActiveSupport::TestCase
  let(:host) { FactoryBot.create(:host, :managed) }
  let(:td_api) { FakeTeamdynamixApi.new }
  before do
    Host::Managed.any_instance.stubs(:td_api).returns(td_api)
  end

  describe '#create' do
    it 'triggers after_create callback on Host::Managed model' do
      host = FactoryBot.create(:host, :managed)
      assert_send([Host::Managed, :after_create, :create_teamdynamix_asset])
    end

    it 'calls Teamdynamix API to create an asset' do
      host = FactoryBot.create(:host, :managed)
      assert_send([td_api, :create_asset, host])
    end

    it 'sets host#teamdynamix_asset_id' do
      assert_not_nil(host.teamdynamix_asset_id)
    end
  end
end
