require 'test_plugin_helper'

class HostsHelperExtensionsTest < ActiveSupport::TestCase
  include ForemanTeamdynamix::HostsHelperExtensions
  let(:host) { FactoryBot.build(:host, :managed) }

  describe '#teamdynamix_fields(host)' do
    context 'when host does not have an asset associated' do
      before do
        host.teamdynamix_asset_id = nil
      end
      test 'returns an array with error message' do
        assert_nothing_raised do
          error_resp = teamdynamix_fields(host).first
          assert_equal(error_resp.first, 'Asset')
          assert_not_nil(error_resp, 'None Associated')
        end
      end
    end
  end

  describe '#teamdynamix_title' do
    let(:title_orig) { SETTINGS[:teamdynamix][:title] }
    before do
      title_orig
      SETTINGS[:teamdynamix][:title] = 'TeamDynamix Tab'
    end
    test 'returns correct title' do
      assert_equal teamdynamix_title, SETTINGS[:teamdynamix][:title]
    end

    test 'settings title is not present' do
      SETTINGS[:teamdynamix][:title] = nil
      assert_equal teamdynamix_title, 'Team Dynamix'
      SETTINGS[:teamdynamix][:title] = title_orig
    end
  end
end
