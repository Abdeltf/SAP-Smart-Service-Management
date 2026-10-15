@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Technician Value Help'
@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.resultSet.sizeCategory: #XS

define view entity ZSS_I_TECHNICIAN
  as select from zss_technician
{
  @ObjectModel.text.element: ['TechnicianName']
  key technician_id   as TechnicianId,

  @Semantics.text: true
      technician_name as TechnicianName,

      department      as Department
}
