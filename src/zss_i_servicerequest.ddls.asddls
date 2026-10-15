@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Service Request Interface'
@Metadata.ignorePropagatedAnnotations: true

define root view entity ZSS_I_SERVICEREQUEST
  as select from zss_srvreq
{
  key request_id       as RequestId,

      title            as Title,
      description      as Description,

      requester        as Requester,
      department       as Department,

      category         as Category,
      priority         as Priority,
      status           as Status,
      

      assigned_to      as AssignedTo,

      created_at       as CreatedAt,
      due_at           as DueAt,
      resolved_at      as ResolvedAt,

      resolution_note  as ResolutionNote,

      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,

      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at as LastChangedAt
}
