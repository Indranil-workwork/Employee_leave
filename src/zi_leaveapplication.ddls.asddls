@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Leave Application Interface View'
@ObjectModel.usageType:{
  serviceQuality: #X,
  sizeCategory:   #M,
  dataClass:      #TRANSACTIONAL
}
define root view entity ZI_LeaveApplication
  as select from zleave_app_t as la
  association [0..1] to ZI_Employee_01      as _Employee
    on la.employee_id   = _Employee.EmployeeId
  association [0..1] to ZI_LeaveTypeVH   as _LeaveType
    on la.leave_type    = _LeaveType.LeaveTypeCode
  association [0..1] to ZI_LeaveStatusVH as _Status
    on la.status        = _Status.StatusCode
  association [0..1] to ZI_Employee_01      as _ApprovedBy
    on la.approved_by   = _ApprovedBy.EmployeeId
  composition [0..*] of ZI_LeaveAttachment as _Attachments
{
  key la.leave_id              as LeaveId,
      la.employee_id           as EmployeeId,
      la.leave_type            as LeaveType,
      la.start_date            as StartDate,
      la.end_date              as EndDate,
      la.total_days            as TotalDays,
      la.reason                as Reason,
      la.status                as Status,
      _Status.StatusCriticality as StatusCriticality,
      la.approved_by           as ApprovedBy,
      la.approved_at           as ApprovedAt,
      la.created_by            as CreatedBy,
      la.created_at            as CreatedAt,
      la.last_changed_by       as LastChangedBy,
      la.last_changed_at       as LastChangedAt,
      la.local_last_changed_at as LocalLastChangedAt,

      _Employee,
      _LeaveType,
      _Status,
      _ApprovedBy,
      _Attachments
}
