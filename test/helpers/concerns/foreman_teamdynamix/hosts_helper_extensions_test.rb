require 'test_plugin_helper'

class HostsHelperExtensionsTest < ActiveSupport::TestCase
  include ForemanTeamdynamix::HostsHelperExtensions
  let(:host) { FactoryBot.create(:host, :managed) }
  let(:td_api) { FakeTeamDynamixApi.new }
  before do
    Host::Managed.any_instance.stubs(:td_api).returns(td_api)
  end

  describe '#teamdynamix_fields(host)' do
    let(:sample_asset) { td_api.get_asset }
    let(:direct_attribs_config) { { 'Asset ID' => 'ID',
                                    'Owner' => 'OwningCustomerName',
                                    'Parent Asset' => 'ParentID' } }
    let(:direct_attribs_fields) { get_direct_asset_attribs_val(direct_attribs_config) }
    before do
      SETTINGS[:team_dynamix][:fields] = {}
      SETTINGS[:team_dynamix][:fields].merge!(direct_attribs_config)
    end
    
    context 'configuration only has attributes' do
      test 'returns fields as expected' do
        assert_equal teamdynamix_fields(host), direct_attribs_fields
      end
    end

    context 'configuration has nested attributes' do
      let(:nested_attribs_config) { { 'mu.ci.Description' => "Attributes.'mu.ci.Description'",
                                      'Ticket Routing Details' => "Attributes.'Ticket Routing Details'" } }
      let(:nested_attribs_fields) { get_nested_asset_attribs_val(nested_attribs_config) }
      let(:expected_fields) { direct_attribs_fields + nested_attribs_fields }
      before do
        SETTINGS[:team_dynamix][:fields] = {}
        SETTINGS[:team_dynamix][:fields].merge!(nested_attribs_config)
      end
      test 'returns fields as expected' do
        assert_equal teamdynamix_fields(host), nested_attribs_fields
      end
    end
  end

  describe '#td_tab_title' do
    title_orig = SETTINGS[:team_dynamix][:title]
    after do
      SETTINGS[:team_dynamix][:title] = title_orig
    end
    test 'returns correct title' do
      title = 'Custom Tab Title'
      SETTINGS[:team_dynamix][:title] = title
      assert_equal td_tab_title, title
    end

    test 'settings title is not present' do
      SETTINGS[:team_dynamix][:title] = nil
      assert_equal td_tab_title, 'Team Dynamix'
    end
  end
end
