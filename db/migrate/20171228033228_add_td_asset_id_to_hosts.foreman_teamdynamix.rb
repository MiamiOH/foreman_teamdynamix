class AddTdAssetIdToHosts < ActiveRecord::Migration[5.0]
  def change
    add_column :hosts, :td_asset_id, :string
  end
end
