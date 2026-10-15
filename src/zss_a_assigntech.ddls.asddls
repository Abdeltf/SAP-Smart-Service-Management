@EndUserText.label: 'Assign Technician Parameter'
define abstract entity ZSS_A_ASSIGNTECH
{
  @EndUserText.label: 'Technician ID'

  @Consumption.valueHelpDefinition: [
    {
      entity: {
        name: 'ZSS_I_TECHNICIAN',
        element: 'TechnicianId'
      }
    }
  ]

  TechnicianId : abap.char(12);
}
