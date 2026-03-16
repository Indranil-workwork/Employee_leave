@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Leave Application Consumption View'
@Metadata.allowExtensions: true
define root view entity ZC_LeaveApplication
  provider contract transactional_query
  as projection on ZI_LeaveApplication
{
  key LeaveId,


  @Consumption.valueHelpDefinition: [{
    entity: {
      name:    'ZI_EmployeeVH',
      element: 'EmployeeId'
    }
  }]
  EmployeeId,

  // Value help resolved from ZI_LeaveTypeVH
  // Text association drives automatic description display in UI
  @Consumption.valueHelpDefinition: [{
    entity: {
      name:    'ZI_LeaveTypeVH',
      element: 'LeaveTypeCode'
    }
  }]
  @ObjectModel.text.association: '_LeaveType'
  LeaveType,

  StartDate,
  EndDate,
  TotalDays,
  Reason,

  // Value help resolved from ZI_LeaveStatusVH
  // StatusCriticality from ZI_LeaveStatusVH drives Fiori color coding
  @Consumption.valueHelpDefinition: [{
    entity: {
      name:    'ZI_LeaveStatusVH',
      element: 'StatusCode'
    }
  }]
  @ObjectModel.text.association: '_Status'
  Status,
  // Used as criticality source in @UI.lineItem and @UI.identification
  StatusCriticality,
  

  // Cleaner than additionalBinding on ZI_EmployeeVH
  @Consumption.valueHelpDefinition: [{
    entity: {
      name:    'ZI_SupervisorVH',
      element: 'EmployeeId'
    }
  }]
  ApprovedBy,

  ApprovedAt,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,
  LocalLastChangedAt,

  // Associations passed through from ZI_ layer
  _Employee,
  _LeaveType,
  _Status,
  _ApprovedBy,

  // Child composition redirected to ZC_ projection child
  _Attachments : redirected to composition child ZC_LeaveAttachment
}
