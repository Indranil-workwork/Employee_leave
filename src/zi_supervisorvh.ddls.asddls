@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Supervisor Value Help View'
@ObjectModel.usageType:{
  serviceQuality: #X,
  sizeCategory:   #S,
  dataClass:      #MASTER
}
// Dedicated value help for ApprovedBy field
// Pre-filtered to supervisors — no additionalBinding needed in ZC_
@Search.searchable: true
define view entity ZI_SupervisorVH
  as select from zemp_mst
{
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.8
  key employee_id           as EmployeeId,

      first_name            as FirstName,
      last_name             as LastName,

      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      full_name             as FullName,

      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.7
      department            as Department,

      email                 as Email,
      is_supervisor         as IsSupervisor,
      is_active             as IsActive
}
// Pre-filtered — only active supervisors shown in ApprovedBy F4
where is_active    = 'X'
  and is_supervisor = 'X'
