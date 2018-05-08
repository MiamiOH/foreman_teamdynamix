module Orchestration
  module Teamdynamix
    extend ActiveSupport::Concern

    included do
      before_create :queue_teamdynamix_create
    end

    def td_api
      @td_api ||= TeamdynamixApi.instance
    end

    protected

    def queue_teamdynamix_create
      queue.create(:name   => _('Creating asset in TeamDynamix %s') % self, :priority => 60,
                   :action => [self, :set_teamdynamix])
    end

    def set_teamdynamix
      assets = td_api.search_asset(SerialLike: name)
      if assets.empty?
        asset = td_api.create_asset(self)
        self.teamdynamix_asset_uid = asset['ID']
      elsif assets.length > 1
        raise 'Found more than 1 existing asset'
      else
        self.teamdynamix_asset_uid = assets.first['ID']
        td_api.update_asset(self)
      end
    rescue StandardError => e
      errors.add(:base, _("Could not create the asset for the host in TeamDynamix: #{e.message}"))
      false
    end

    def del_teamdynamix; end
  end
end
