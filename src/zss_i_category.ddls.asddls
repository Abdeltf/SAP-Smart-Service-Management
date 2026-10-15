@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Category Value Help'
@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.resultSet.sizeCategory: #XS

define view entity ZSS_I_CATEGORY
  as select from zss_category
{
  @ObjectModel.text.element: ['Description']
  key category    as Category,

  @Semantics.text: true
      description as Description
}
