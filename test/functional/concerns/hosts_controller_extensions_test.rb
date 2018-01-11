require 'test_plugin_helper'

class HostsControllerTest < ActionController::TestCase
  let(:host) { FactoryBot.create(:host, :managed) }
  let(:td_api) { FakeTeamDynamixApi.new }
  let(:td_tab_title) { SETTINGS[:team_dynamix][:title] || 'Team Dynamix' }

  # rubocop:disable Style/StringLiterals, HttpPositionalArguments
  describe 'Given host exist as an asset in TeamDynamix' do
    describe 'when TeamDynamix asset attributes are configured' do
      # mock TD API#create_asset
      before do
        Host::Managed.any_instance.stubs(:td_api).returns(td_api)
      end
      describe 'GET hosts/show' do
        test 'loads the TeamDynamix tab' do
          get :show, { :id => host.name }, set_session_user
          assert_includes response.headers['Content-Type'], 'text/html'
          assert_includes response.body, "<ul id=\"myTab\""
          assert_equal response.status, 200
          assert_includes response.body, "<li><a href=\"#team_dynamix\" data-toggle=\"tab\">#{td_tab_title}</a></li>"
          assert_includes response.body, "<div id=\"team_dynamix\" class=\"tab-pane\" data-ajax-url=\"/hosts/#{host.name}/team_dynamix\" data-on-complete=\"onContentLoad\">"
        end

        test 'TeamDynamix tab contains configured asset attributes' do
          skip('error finding AJAX route to asset')
          get hosts_team_dynamix_path, { :id => host.name }, set_session_user
          assert_template 'foreman_team_dynamix'
        end
      end
    end
  end
  # rubocop:enable Style/StringLiterals, HttpPositionalArguments
end
