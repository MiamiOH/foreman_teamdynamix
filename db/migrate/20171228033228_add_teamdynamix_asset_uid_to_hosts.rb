class AddTeamdynamixAssetUidToHosts < ActiveRecord::Migration
  def change
    add_column :hosts, :teamdynamix_asset_uid, :string
  end
end
