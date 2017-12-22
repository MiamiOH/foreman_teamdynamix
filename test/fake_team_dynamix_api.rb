class FakeTeamDynamixApi
  
  def create_asset(host)
    # switch with actual output
    true
  end

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  def get_asset(id)
    {
      ID: Random.rand(1000..10_000),
      AppID: Random.rand(1000..10_000),
      AppName: 'configuredAppName',
      ProductModelID: Random.rand(1000..10_000),
      ProductModelName: 'sample_ProductModelName',
      ManufacturerID: Random.rand(1000..10_000),
      ManufacturerName: 'sample_ManufacturerName',
      SupplierID: Random.rand(1000..10_000),
      SupplierName: 'sample_SupplierName',
      StatusID: Random.rand(1000..10_000),
      StatusName: 'sample_StatusName',
      LocationID: Random.rand(1000..10_000),
      LocationName: 'sample_LocationName',
      LocationRoomID: Random.rand(1000..10_000),
      LocationRoomName: 'sample_LocationRoomName',
      Tag: 'sample_Tag',
      SerialNumber: 'sample_SerialNumber',
      Name: 'sample_Name',
      PurchaseCost: Random.rand(1000..10_000),
      AcquisitionDate: Time.now.utc,
      ExpectedReplacementDate:	Time.now.utc,
      RequestingCustomerID: SecureRandom.uuid,
      RequestingCustomerName: 'RequestingCustomerName',
      RequestingDepartmentID: rand(1000..10_000),
      RequestingDepartmentName: 'RequestingDepartmentName',
      OwningCustomerID: SecureRandom.uuid,
      OwningCustomerName: 'OwningCustomerName',
      OwningDepartmentID: Random.rand(1000..10_000),
      OwningDepartmentName: 'OwningDepartmentName',
      ParentID: Random.rand(1000..10_000),
      ParentSerialNumber: 'ParentSerialNumber',
      ParentName: 'ParentName',
      ParentTag: 'ParentTag',
      MaintenanceScheduleID: Random.rand(1000..10_000),
      MaintenanceScheduleName: 'MaintenanceScheduleName',
      ConfigurationItemID: Random.rand(1000..10_000),
      CreatedDate: Time.now.utc,
      CreatedUid: SecureRandom.uuid,
      CreatedFullName: 'CreatedFullName',
      ModifiedDate: Time.now.utc,
      ModifiedUid: SecureRandom.uuid,
      ModifiedFullName: 'ModifiedFullName',
      ExternalID: 'ExternalID',
      ExternalSourceID: Random.rand(1000..10_000),
      ExternalSourceName: 'ExternalSourceName',
      Attributes: 'IEnumerable(Of TeamDynamix.Api.CustomAttributes.CustomAttribute)',
      Attachments: 'IEnumerable(Of TeamDynamix.Api.Attachments.Attachment)',
      Uri: 'http://host.uri.com'
    }.to_json
  end
end
