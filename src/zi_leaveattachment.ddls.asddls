@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Leave Attachment Interface View'
@ObjectModel.usageType:{
  serviceQuality: #X,
  sizeCategory:   #L,
  dataClass:      #TRANSACTIONAL
}
define view entity ZI_LeaveAttachment
  as select from zleave_attch_t as la
  association to parent ZI_LeaveApplication as _Leave
    on $projection.LeaveId = _Leave.LeaveId
{
  key la.leave_id              as LeaveId,
  key la.attach_id             as AttachId,
      la.file_name             as FileName,
      la.mime_type             as MimeType,
      la.file_size             as FileSize,
      la.file_content          as FileContent,
      la.created_by            as CreatedBy,
      la.created_at            as CreatedAt,
      la.local_last_changed_at as LocalLastChangedAt,

      _Leave
}
