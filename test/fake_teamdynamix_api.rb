class FakeTeamdynamixApi
  def create_asset(*)
    get_asset
  end

  def search_asset(*)
    Array.wrap(get_asset)
  end

  def retire_asset(*)
    true
  end

  def get_asset(*)
    JSON.parse(File.read(File.join(File.dirname(__FILE__), 'sample_asset.json')))
  end
end
