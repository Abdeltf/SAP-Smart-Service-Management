CLASS zcl_ss_criticality DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_sadl_exit_calc_element_read.

ENDCLASS.


CLASS zcl_ss_criticality IMPLEMENTATION.

  METHOD if_sadl_exit_calc_element_read~get_calculation_info.

    LOOP AT it_requested_calc_elements INTO DATA(lv_element).

      CASE lv_element.

        WHEN 'PRIORITYCRITICALITY'.
          APPEND 'PRIORITY' TO et_requested_orig_elements.

        WHEN 'STATUSCRITICALITY'.
          APPEND 'STATUS' TO et_requested_orig_elements.

      ENDCASE.

    ENDLOOP.

  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~calculate.

    TYPES:
      BEGIN OF ty_request,
        Priority            TYPE zss_srvreq-priority,
        Status              TYPE zss_srvreq-status,
        PriorityCriticality TYPE int1,
        StatusCriticality   TYPE int1,
      END OF ty_request.

    DATA lt_requests TYPE STANDARD TABLE OF ty_request WITH DEFAULT KEY.

    lt_requests = CORRESPONDING #( it_original_data ).

    LOOP AT lt_requests ASSIGNING FIELD-SYMBOL(<request>).

      CASE <request>-Priority.
        WHEN 'CRITICAL'.
          <request>-PriorityCriticality = 1. " Red
        WHEN 'HIGH'.
          <request>-PriorityCriticality = 2. " Orange
        WHEN 'NORMAL'.
          <request>-PriorityCriticality = 0. " Neutral
        WHEN 'LOW'.
          <request>-PriorityCriticality = 3. " Green
        WHEN OTHERS.
          <request>-PriorityCriticality = 0.
      ENDCASE.


      CASE <request>-Status.
        WHEN 'RESOLVED'.
          <request>-StatusCriticality = 3. " Green
        WHEN 'IN_PROGRESS'.
          <request>-StatusCriticality = 5. " Blue / Information
        WHEN 'OPEN'.
          <request>-StatusCriticality = 2. " Orange
        WHEN OTHERS.
          <request>-StatusCriticality = 0.
      ENDCASE.

    ENDLOOP.

    ct_calculated_data = CORRESPONDING #( lt_requests ).

  ENDMETHOD.

ENDCLASS.
