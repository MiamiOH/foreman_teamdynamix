require 'test_plugin_helper'

class HostsControllerTest < ActionController::TestCase
  let(:os) { FactoryBot.create(:operatingsystem, name: 'CentOS', major: '7', type: 'Redhat') }
  let(:arch) { FactoryBot.create(:architecture) }
  let(:host) { FactoryBot.create(:host, mac: '00:00:00:00:00:00', ip: '127.0.0.1', operatingsystem: os, arch: arch) }
  # let(:asset) { FactoryBot.attributes_for(:td_asset) }
  let(:asset) { FakeTDApi.asset }
  let(:default_TD_fields) { { 'Asset ID': asset['ID'], 'Owner': asset['OwningCustomerName'], 'Parent Asset': asset['ParentID'], 'mu.ci.Description': 'to be discussed', 'Ticket Routing Details': 'to be discussed' } }
  let(:td_tab_title) { SETTINGS[:team_dynamix][:title] || 'TeamDynamix' }

  describe 'Given host exist as an asset in TeamDynamix' do
    describe 'when TeamDynamix asset attributes are configured' do
      describe 'GET hosts/show' do
        test 'loads the TeamDynamix tab' do
          get :show, { :id => host.name }, set_session_user
          assert_includes response.headers['Content-Type'], 'text/html'
          assert_includes response.body, "<ul id=\"myTab\""
          assert_equal response.status, 200
          assert_includes response.body, "<li><a href=\"#team_dynamix\" data-toggle=\"tab\">#{td_tab_title}</a></li>"
        end
        test 'TeamDynamix tab contains configured asset attributes' do
          get hosts_team_dynamix_path, { :id => host.name }, set_session_user
          assert_template 'foreman_team_dynamix'
        end
      end
    end
  end
end
