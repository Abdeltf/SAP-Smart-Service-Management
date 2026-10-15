@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Priority Value Help'
@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.resultSet.sizeCategory: #XS

define view entity ZSS_I_PRIORITY
  as select from zss_priority
{
  @ObjectModel.text.element: ['Description']
  key priority    as Priority,

  @Semantics.text: true
      description as Description,

      sla_hours   as SlaHours
}
