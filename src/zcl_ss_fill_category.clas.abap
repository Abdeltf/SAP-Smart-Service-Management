CLASS zcl_ss_fill_category DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

ENDCLASS.


CLASS zcl_ss_fill_category IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    DATA lt_categories TYPE STANDARD TABLE OF zss_category WITH EMPTY KEY.

    lt_categories = VALUE #(
      ( category = 'SOFTWARE'
        description = 'Software' )

      ( category = 'HARDWARE'
        description = 'Hardware' )

      ( category = 'NETWORK'
        description = 'Network' )

      ( category = 'ACCESS'
        description = 'Access / Permissions' )

      ( category = 'OTHER'
        description = 'Other' )
    ).

    DELETE FROM zss_category.

    INSERT zss_category FROM TABLE @lt_categories.

    out->write( 'Category configuration created successfully.' ).

  ENDMETHOD.

ENDCLASS.
