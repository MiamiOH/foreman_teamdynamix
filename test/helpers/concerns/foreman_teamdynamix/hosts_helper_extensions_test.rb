require 'test_plugin_helper'

class HostsHelperExtensionsTest < ActiveSupport::TestCase
  include ForemanTeamdynamix::HostsHelperExtensions
  let(:host) { FactoryBot.create(:host, :managed) }
  let(:td_api) { FakeTeamdynamixApi.new }
  before do
    Host::Managed.any_instance.stubs(:td_api).returns(td_api)
    @host = host
  end

  describe '#teamdynamix_fields' do
    let(:sample_asset) { td_api.get_asset }
    let(:default_fields) { [ get_sample_asset_uri ] }
    let(:direct_attribs_config) { { 'Asset ID' => 'ID',
                                    'Owner' => 'OwningCustomerName',
                                    'Parent Asset' => 'ParentID' } }
    let(:direct_attribs_fields) { get_direct_asset_attribs_val(direct_attribs_config) }
    let(:expected_fields) { default_fields + direct_attribs_fields }
    before do
      SETTINGS[:teamdynamix][:fields] = {}
      SETTINGS[:teamdynamix][:fields].merge!(direct_attribs_config)
    end

    context 'configuration only has attributes' do
      test 'returns fields as expected' do
        assert_equal teamdynamix_fields, expected_fields
      end
    end

    context 'configuration has nested attributes' do
      let(:nested_attribs_config) { { 'mu.ci.Description' => "Attributes.'mu.ci.Description'",
                                      'Ticket Routing Details' => "Attributes.'Ticket Routing Details'" } }
      let(:nested_attribs_fields) { get_nested_asset_attribs_val(nested_attribs_config) }
      let(:expected_fields) { default_fields + nested_attribs_fields }
      before do
        SETTINGS[:teamdynamix][:fields] = {}
        SETTINGS[:teamdynamix][:fields].merge!(nested_attribs_config)
      end
      test 'returns fields as expected' do
        assert_equal teamdynamix_fields, expected_fields
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

    test 'settings title is not present: return default title' do
      SETTINGS[:teamdynamix][:title] = nil
      assert_equal teamdynamix_title, 'Team Dynamix'
      SETTINGS[:teamdynamix][:title] = title_orig
    end
  end
end
