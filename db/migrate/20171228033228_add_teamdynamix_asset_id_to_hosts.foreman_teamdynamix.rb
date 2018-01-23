class AddTeamdynamixAssetIdToHosts < ActiveRecord::Migration
  def change
    add_column :hosts, :teamdynamix_asset_id, :string
  end
end
