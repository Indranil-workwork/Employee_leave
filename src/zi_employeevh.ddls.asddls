@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Employee Value Help View'
@ObjectModel.usageType:{
  serviceQuality: #X,
  sizeCategory:   #S,
  dataClass:      #MASTER
}
// Dedicated value help view for Employee field
// Keeps ZI_Employee clean as pure interface view
// Consistent pattern with ZI_LeaveTypeVH and ZI_LeaveStatusVH
@Search.searchable: true
define view entity ZI_EmployeeVH
  as select from zemp_mst
{
  // Primary key — exact match search
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.8
  key employee_id           as EmployeeId,

      first_name            as FirstName,
      last_name             as LastName,

      // Main display field in F4 popup
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      full_name             as FullName,

      // Allows department-based filtering in F4
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.7
      department            as Department,

      email                 as Email,

      // Exposed for additionalBinding filter in ZC_ layer
      // Allows ApprovedBy VH to filter supervisors only
      is_supervisor         as IsSupervisor,

      is_active             as IsActive
}
// Only active employees appear in value help
where is_active = 'X'
