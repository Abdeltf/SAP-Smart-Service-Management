CLASS zcl_ss_fill_priority DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

ENDCLASS.


CLASS zcl_ss_fill_priority IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

  DATA lt_priorities TYPE STANDARD TABLE OF zss_priority WITH EMPTY KEY.

  lt_priorities = VALUE #(
    ( priority    = 'LOW'
      description = 'Low'
      sla_hours   = 72 )

    ( priority    = 'NORMAL'
      description = 'Normal'
      sla_hours   = 24 )

    ( priority    = 'HIGH'
      description = 'High'
      sla_hours   = 8 )

    ( priority    = 'CRITICAL'
      description = 'Critical'
      sla_hours   = 2 )
  ).

  DELETE FROM zss_priority.

  INSERT zss_priority FROM TABLE @lt_priorities.

  out->write( 'Priority configuration created successfully.' ).

ENDMETHOD.



ENDCLASS.
