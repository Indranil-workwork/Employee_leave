@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Leave Status Value Help View'
@ObjectModel.usageType:{
  serviceQuality: #X,
  sizeCategory:   #S,
  dataClass:      #CUSTOMIZING
}
@Search.searchable: true
define view entity ZI_LeaveStatusVH
  as select from zleave_status_t as ls
  association [0..1] to zleave_status_tx as _Text
    on  $projection.StatusCode = _Text.status_code
    and _Text.langu             = $session.system_language
{
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8  
  key ls.status_code           as StatusCode,
     @Search.defaultSearchElement: true
     @Search.fuzzinessThreshold: 0.7
      _Text.status_desc        as StatusDesc, 
      _Text.status_short_desc  as StatusShortDesc,
      ls.status_criticality    as StatusCriticality,
      ls.is_terminal           as IsTerminal,
      ls.icon_url              as IconUrl,

      _Text
}
