desc <<-DESC.strip_heredoc.squish
  Scans existing hosts and creates or updates the asset in TeamDynamix.
    * If found, update the fields in the TeamDynamix asset.
    * If not found, create a TeamDynamix asset with desired fields.

  It could be run for all the hosts as:
    * rake teamydynamix:sync:hosts

DESC
namespace :teamdynamix do
  namespace :sync do
    task :hosts => :environment do
      td_api = TeamdynamixApi.instance
      errors = []
      creates = 0
      updates_from_serial_matching = 0
      update_from_asset_id = 0

      console_user = User.find_by(login: 'foreman_console_admin')
      User.current = console_user

      Host.all.each do |h|
        # if asset exists, update it
        if td_api.asset_exist?(h.teamdynamix_asset_uid)
          td_api.update_asset(h)
          update_from_asset_id += 1
        else
          assets = td_api.search_asset(SerialLike: h.name)
          if assets.empty?
            asset = td_api.create_asset(h)
            h.teamdynamix_asset_uid = asset['ID']
            errors.push("Could not save host: #{h.name} (#{h.id})") unless h.save
            creates += 1
          elsif assets.length > 1
            errors.push("Could not sync: Found more than 1 asset for #{h.name} (#{h.id})")
          else
            h.teamdynamix_asset_uid = assets.first['ID']
            td_api.update_asset(h)
            errors.push("Could not save host: #{h.name} (#{h.id})") unless h.save
            updates_from_serial_matching += 1
          end
        end
        sleep(1) # TD only allows 60 api calls per minute
      end
      puts "Assets created: #{creates}" unless creates.eql?(0)
      unless updates_from_serial_matching.eql?(0)
        puts "Assets updated from serial search: #{updates_from_serial_matching}"
      end
      puts "Assets updated from ID: #{update_from_asset_id}" unless update_from_asset_id.eql?(0)
      puts "Errors:\n#{errors.join("\n")}" unless errors.empty?
    end
  end
end
