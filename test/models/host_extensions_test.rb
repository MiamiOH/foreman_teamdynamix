require 'test_helper'

class HostExtensionsTests < ActiveSupport::TestCase
  let(:td_api) { FakeTeamdynamixApi.new }
  before do
    Host::Managed.any_instance.stubs(:td_api).returns(td_api)
  end

  describe '#create' do
    let(:host) { FactoryBot.create(:host, :managed) }
    it 'triggers after_create callback on Host::Managed model' do
      assert_send([Host::Managed, :after_validation, :create_teamdynamix_asset])
    end

    it 'calls Teamdynamix API to create an asset' do
      assert_send([td_api, :create_asset, host])
    end

    it 'sets host#teamdynamix_asset_id' do
      assert_not_nil(host.teamdynamix_asset_id)
    end
  end

  describe '#destroy' do
    let(:host) { FactoryBot.create(:host, :managed) }
    before do
      host.destroy
    end
    it 'triggers before_destroy callback' do
      assert_send([Host::Managed, :before_destroy, :retire_teamdynamix_asset])
    end

    it 'calls Teamdynamix API to retire an asset' do
      assert_send([td_api, :retire_asset, host.teamdynamix_asset_id])
    end
  end

end
