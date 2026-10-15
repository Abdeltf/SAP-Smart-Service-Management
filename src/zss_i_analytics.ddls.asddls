@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Service Request Analytics Interface'

define root view entity ZSS_I_ANALYTICS
  as select from zss_srvreq
{
  key request_id as RequestId,

      status     as Status,
      priority   as Priority,
      category   as Category,

      cast( 1 as abap.int4 ) as RequestCount
}
