@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Service Request Analytics'
@Metadata.allowExtensions: true
@OData.applySupportedForAggregation: #FULL

@UI.headerInfo: {
  typeName: 'Service Request Analytics',
  typeNamePlural: 'Service Request Analytics'
}

@UI.chart: [{
  qualifier: 'StatusChart',
  title: 'Requests by Status',
  chartType: #DONUT,
  dimensions: ['Status'],
  measures: ['RequestCount'],
  dimensionAttributes: [{
    dimension: 'Status',
    role: #CATEGORY
  }],
  measureAttributes: [{
    measure: 'RequestCount',
    role: #AXIS_1
  }]
}]

define root view entity ZSS_C_ANALYTICS
  provider contract transactional_query
  as projection on ZSS_I_ANALYTICS
{
  key RequestId,

  @UI.lineItem: [{ position: 10, label: 'Status' }]
  Status,

  @UI.lineItem: [{ position: 20, label: 'Priority' }]
  Priority,

  @UI.lineItem: [{ position: 30, label: 'Category' }]
  Category,

  @Aggregation.default: #SUM
  @EndUserText.label: 'Number of Requests'
  @UI.lineItem: [{ position: 40, label: 'Requests' }]
  RequestCount
}
