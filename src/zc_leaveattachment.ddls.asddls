@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Leave Attachment Consumption View'
@Metadata.allowExtensions: true

define view entity ZC_LeaveAttachment
  as projection on ZI_LeaveAttachment
{
  key LeaveId,
  key AttachId,


  FileName,

  @Semantics.mimeType: true
  MimeType,

  FileSize,

  // @Semantics.largeObject drives OData $value stream endpoint
  // contentDispositionPreference ATTACHMENT triggers browser download
  @Semantics.largeObject: {
    mimeType:   'MimeType',
    fileName:   'FileName',
    contentDispositionPreference: #ATTACHMENT
  }
  FileContent,

  CreatedBy,
  CreatedAt,
  LocalLastChangedAt,

  // Parent redirect completes composition in projection layer
  _Leave : redirected to parent ZC_LeaveApplication
}
