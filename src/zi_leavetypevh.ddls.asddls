@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Leave Type Value Help View'
@ObjectModel.usageType:{
  serviceQuality: #X,
  sizeCategory:   #S,
  dataClass:      #CUSTOMIZING
}
@Search.searchable: true
define view entity ZI_LeaveTypeVH
  as select from zleave_type_t as lt
  association [0..1] to zleave_type_tx as _Text
    on  $projection.LeaveTypeCode = _Text.leave_type_code
    and _Text.langu               = $session.system_language
{
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8  
  key lt.leave_type_code     as LeaveTypeCode,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      _Text.leave_type_desc  as LeaveTypeDesc,
     
     @Search.defaultSearchElement: true
     @Search.fuzzinessThreshold: 0.7
      _Text.leave_type_short_desc as LeaveTypeShortDesc,
      lt.max_days_allowed    as MaxDaysAllowed,
      lt.requires_document   as RequiresDocument,
      lt.is_active           as IsActive,

      _Text
}
where lt.is_active = 'X'
