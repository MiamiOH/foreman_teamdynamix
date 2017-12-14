module ForemanTeamdynamix
  # Example: Plugin's HostsController inherits from Foreman's HostsController
  module HostsControllerExtensions
    extend ActiveSupport::Concern

    def new_action
      render 'foreman_teamdynamix/hosts/new_action'
      # automatically renders view/foreman_teamdynamix/hosts/new_action
    end
  end
end
