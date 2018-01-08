module ForemanTeamdynamix
  # Example: Plugin's HostsController inherits from Foreman's HostsController
  module HostsControllerExtensions
    extend ActiveSupport::Concern

    def team_dynamix
      # find host
      find_resource

      return ['No TeamDynamix Asset is linked to this host'] unless @host.td_asset_id
      td_asset

      render partial: 'foreman_teamdynamix/hosts/team_dynamix'
    end

    private

    def td_api
      @td_api || TeamDynamixApi.new
    end

    def td_asset
      @asset = td_api.get_asset(@host.td_asset_id)
    rescue StandardError => e
      ["Error getting asset Data from Team Dynamix: #{e.message}"]
    end

    def action_permission
      if params[:action] == 'team_dynamix'
        :view
      else
        super
      end
    end
  end
end
