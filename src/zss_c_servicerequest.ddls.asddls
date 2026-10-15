@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Service Request Projection'
@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true

define root view entity ZSS_C_SERVICEREQUEST
  provider contract transactional_query
  as projection on ZSS_I_SERVICEREQUEST
{
    key RequestId,

        Title,
        Description,

        Requester,
        Department,

        @Consumption.valueHelpDefinition: [
  {
    entity: {
      name: 'ZSS_I_CATEGORY',
      element: 'Category'
    }
  }
]
        Category,
        @Consumption.valueHelpDefinition: [
  {
    entity: {
      name: 'ZSS_I_PRIORITY',
      element: 'Priority'
    }
  }
]
Priority,
        Status,

        AssignedTo,

        CreatedAt,
        DueAt,
        ResolvedAt,

        ResolutionNote,
        LastChangedAt,
        LocalLastChangedAt,
        @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_SS_CRITICALITY'
virtual PriorityCriticality : abap.int1,

@ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_SS_CRITICALITY'
virtual StatusCriticality : abap.int1
}
