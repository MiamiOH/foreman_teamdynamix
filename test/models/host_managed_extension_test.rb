require 'test_helper'

module Host
  class ManagedTest < ActiveSupport::TestCase
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

    end
  end
end
