class FakeTeamDynamixApi
  def create_asset(*)
    get_asset
  end

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  def get_asset(*)
    JSON.parse(File.read(File.join(File.dirname(__FILE__), 'sample_asset.json')))
  end
end
