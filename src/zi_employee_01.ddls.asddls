@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Employee Interface View'
@ObjectModel.usageType:{
  serviceQuality: #X,
  sizeCategory:   #S,
  dataClass:      #MASTER            
}
define view entity ZI_Employee_01
  as select from zemp_mst            
{
  key employee_id          as EmployeeId,

      first_name           as FirstName,
      last_name            as LastName,
      full_name            as FullName,
      email                as Email,                              
      department           as Department,                             
      is_supervisor        as IsSupervisor,                              
      is_active            as IsActive,                              
      created_by           as CreatedBy,
      created_at           as CreatedAt,
      last_changed_by      as LastChangedBy,
      last_changed_at      as LastChangedAt,
      local_last_changed_at as LocalLastChangedAt
}
