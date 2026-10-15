CLASS zcl_ss_fill_technician DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

ENDCLASS.


CLASS zcl_ss_fill_technician IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    DATA lt_technicians TYPE STANDARD TABLE OF zss_technician WITH EMPTY KEY.

    lt_technicians = VALUE #(
      (
        technician_id   = 'TECH001'
        technician_name = 'Lena Fischer'
        department      = 'IT Support'
      )

      (
        technician_id   = 'TECH002'
        technician_name = 'Jonas Weber'
        department      = 'Infrastructure'
      )

      (
        technician_id   = 'TECH003'
        technician_name = 'Mira Schneider'
        department      = 'Network'
      )

      (
        technician_id   = 'TECH004'
        technician_name = 'David Keller'
        department      = 'Applications'
      )
    ).

    DELETE FROM zss_technician.

    INSERT zss_technician FROM TABLE @lt_technicians.

    out->write( 'Technician master data created successfully.' ).

  ENDMETHOD.

ENDCLASS.
