CLASS lhc_zss_i_servicerequest DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS setInitialValues FOR DETERMINE ON MODIFY
      keys FOR ZSS_I_SERVICEREQUEST~setInitialValues.

    METHODS calculateSLA FOR DETERMINE ON MODIFY
    IMPORTING keys FOR ZSS_I_SERVICEREQUEST~calculateSLA.

    METHODS validatePriority FOR VALIDATE ON SAVE
  IMPORTING keys FOR ZSS_I_SERVICEREQUEST~validatePriority.

  METHODS get_instance_features FOR INSTANCE FEATURES
  IMPORTING keys REQUEST requested_features
  FOR ZSS_I_SERVICEREQUEST
  RESULT result.

  METHODS resolveRequest FOR MODIFY
  IMPORTING keys FOR ACTION ZSS_I_SERVICEREQUEST~resolveRequest
  RESULT result.

  METHODS escalateRequest FOR MODIFY
  IMPORTING keys FOR ACTION ZSS_I_SERVICEREQUEST~escalateRequest
  RESULT result.
  METHODS assignTechnician FOR MODIFY
    keys FOR ACTION ZSS_I_SERVICEREQUEST~assignTechnician RESULT result.


ENDCLASS.

CLASS lhc_zss_i_servicerequest IMPLEMENTATION.

METHOD setInitialValues.

  DATA lv_timestamp TYPE timestampl.
  DATA lv_due_at    TYPE timestampl.

  GET TIME STAMP FIELD lv_timestamp.

  " Normal priority: 24 hours
  lv_due_at = cl_abap_tstmp=>add(
    tstmp = lv_timestamp
    secs  = 86400
  ).

  MODIFY ENTITIES OF ZSS_I_SERVICEREQUEST IN LOCAL MODE
    ENTITY ZSS_I_SERVICEREQUEST
      UPDATE FIELDS ( Status Priority CreatedAt DueAt )
      WITH VALUE #(
        FOR key IN keys
        (
          %tky      = key-%tky
          Status    = 'OPEN'
          Priority  = 'NORMAL'
          CreatedAt = lv_timestamp
          DueAt     = lv_due_at
        )
      )
    FAILED DATA(failed_update)
    REPORTED DATA(reported_update).

ENDMETHOD.
METHOD calculateSLA.

  READ ENTITIES OF ZSS_I_SERVICEREQUEST IN LOCAL MODE
    ENTITY ZSS_I_SERVICEREQUEST
      FIELDS ( Priority CreatedAt )
      WITH CORRESPONDING #( keys )
    RESULT DATA(requests).

  LOOP AT requests INTO DATA(request).

    IF request-CreatedAt IS INITIAL.
      CONTINUE.
    ENDIF.

    DATA lv_sla_hours TYPE i.

    SELECT SINGLE sla_hours
      FROM zss_priority
      WHERE priority = @request-Priority
      INTO @lv_sla_hours.

    IF sy-subrc <> 0.
      CONTINUE.
    ENDIF.

    DATA(lv_seconds) = lv_sla_hours * 3600.

    DATA(lv_due_at) = cl_abap_tstmp=>add(
      tstmp = request-CreatedAt
      secs  = lv_seconds
    ).

    MODIFY ENTITIES OF ZSS_I_SERVICEREQUEST IN LOCAL MODE
      ENTITY ZSS_I_SERVICEREQUEST
        UPDATE FIELDS ( DueAt )
        WITH VALUE #(
          (
            %tky  = request-%tky
            DueAt = lv_due_at
          )
        )
      FAILED DATA(failed_sla)
      REPORTED DATA(reported_sla).

  ENDLOOP.

ENDMETHOD.

METHOD validatePriority.

  READ ENTITIES OF ZSS_I_SERVICEREQUEST IN LOCAL MODE
    ENTITY ZSS_I_SERVICEREQUEST
      FIELDS ( Priority )
      WITH CORRESPONDING #( keys )
    RESULT DATA(requests).

  LOOP AT requests INTO DATA(request).

    "Clear any previous validation message
    APPEND VALUE #(
      %tky        = request-%tky
      %state_area = 'VALIDATE_PRIORITY'
    ) TO reported-zss_i_servicerequest.

    "Check the four permitted priorities
    IF request-Priority <> 'LOW'
       AND request-Priority <> 'NORMAL'
       AND request-Priority <> 'HIGH'
       AND request-Priority <> 'CRITICAL'.

      "Prevent the invalid ticket from being saved
      APPEND VALUE #(
        %tky = request-%tky
      ) TO failed-zss_i_servicerequest.

      "Send an error message to Fiori
      APPEND VALUE #(
        %tky        = request-%tky
        %state_area = 'VALIDATE_PRIORITY'

        %msg = new_message_with_text(
          severity = if_abap_behv_message=>severity-error
          text     = 'Priority must be LOW, NORMAL, HIGH or CRITICAL.'
        )

        %element-Priority = if_abap_behv=>mk-on

      ) TO reported-zss_i_servicerequest.

    ENDIF.

  ENDLOOP.

ENDMETHOD.

METHOD get_instance_features.

  READ ENTITIES OF ZSS_I_SERVICEREQUEST IN LOCAL MODE
    ENTITY ZSS_I_SERVICEREQUEST
      FIELDS ( Status Priority )
      WITH CORRESPONDING #( keys )
    RESULT DATA(requests).

  result = VALUE #(
  FOR request IN requests
  (
    %tky = request-%tky

    %action-resolveRequest =
      COND #(
        WHEN request-Status = 'RESOLVED'
        THEN if_abap_behv=>fc-o-disabled
        ELSE if_abap_behv=>fc-o-enabled
      )

    %action-escalateRequest =
      COND #(
        WHEN request-Status = 'RESOLVED'
          OR request-Priority = 'CRITICAL'
        THEN if_abap_behv=>fc-o-disabled
        ELSE if_abap_behv=>fc-o-enabled
      )
    %action-assignTechnician =
       COND #(
         WHEN request-Status = 'RESOLVED'
         THEN if_abap_behv=>fc-o-disabled
         ELSE if_abap_behv=>fc-o-enabled
  )
  )
).

ENDMETHOD.

METHOD resolveRequest.

  DATA lv_resolved_at TYPE timestampl.

  GET TIME STAMP FIELD lv_resolved_at.

  READ ENTITIES OF ZSS_I_SERVICEREQUEST IN LOCAL MODE
    ENTITY ZSS_I_SERVICEREQUEST
      FIELDS ( Status ResolutionNote )
      WITH CORRESPONDING #( keys )
    RESULT DATA(requests).

  LOOP AT requests INTO DATA(request).

    " Resolution note is mandatory before resolving
    IF request-ResolutionNote IS INITIAL.

      APPEND VALUE #(
        %tky = request-%tky

        %fail = VALUE #(
          cause = if_abap_behv=>cause-unspecific
        )

        %op-%action-resolveRequest = if_abap_behv=>mk-on

      ) TO failed-zss_i_servicerequest.


      APPEND VALUE #(
        %tky = request-%tky

        %op-%action-resolveRequest = if_abap_behv=>mk-on

        %msg = new_message_with_text(
          severity = if_abap_behv_message=>severity-error
          text     = 'Enter a resolution note before resolving the request.'
        )

        %element-ResolutionNote = if_abap_behv=>mk-on

      ) TO reported-zss_i_servicerequest.

      CONTINUE.

    ENDIF.


    MODIFY ENTITIES OF ZSS_I_SERVICEREQUEST IN LOCAL MODE
      ENTITY ZSS_I_SERVICEREQUEST
        UPDATE FIELDS ( Status ResolvedAt )
        WITH VALUE #(
          (
            %tky       = request-%tky
            Status     = 'RESOLVED'
            ResolvedAt = lv_resolved_at
          )
        )
      FAILED DATA(failed_update)
      REPORTED DATA(reported_update).


    "If the internal update itself failed
    IF failed_update-zss_i_servicerequest IS NOT INITIAL.

      APPEND VALUE #(
        %tky = request-%tky

        %fail = VALUE #(
          cause = if_abap_behv=>cause-unspecific
        )

        %op-%action-resolveRequest = if_abap_behv=>mk-on

      ) TO failed-zss_i_servicerequest.

      APPEND VALUE #(
        %tky = request-%tky

        %op-%action-resolveRequest = if_abap_behv=>mk-on

        %msg = new_message_with_text(
          severity = if_abap_behv_message=>severity-error
          text     = 'The request could not be resolved.'
        )

      ) TO reported-zss_i_servicerequest.

      CONTINUE.

    ENDIF.


    "Return only successfully resolved instances
    READ ENTITIES OF ZSS_I_SERVICEREQUEST IN LOCAL MODE
      ENTITY ZSS_I_SERVICEREQUEST
        ALL FIELDS
        WITH VALUE #(
          ( %tky = request-%tky )
        )
      RESULT DATA(updated_requests).

    IF updated_requests IS NOT INITIAL.

      APPEND VALUE #(
        %tky   = request-%tky
        %param = updated_requests[ 1 ]
      ) TO result.

    ENDIF.

  ENDLOOP.

ENDMETHOD.

METHOD escalateRequest.

  READ ENTITIES OF ZSS_I_SERVICEREQUEST IN LOCAL MODE
    ENTITY ZSS_I_SERVICEREQUEST
      FIELDS ( Status Priority )
      WITH CORRESPONDING #( keys )
    RESULT DATA(requests).

  LOOP AT requests INTO DATA(request).

    "Resolved tickets must not be escalated
    IF request-Status = 'RESOLVED'.

      APPEND VALUE #(
        %tky = request-%tky
        %fail = VALUE #(
          cause = if_abap_behv=>cause-unspecific
        )
        %op-%action-escalateRequest = if_abap_behv=>mk-on
      ) TO failed-zss_i_servicerequest.

      APPEND VALUE #(
        %tky = request-%tky
        %op-%action-escalateRequest = if_abap_behv=>mk-on
        %msg = new_message_with_text(
          severity = if_abap_behv_message=>severity-error
          text     = 'A resolved request cannot be escalated.'
        )
      ) TO reported-zss_i_servicerequest.

      CONTINUE.

    ENDIF.


    MODIFY ENTITIES OF ZSS_I_SERVICEREQUEST IN LOCAL MODE
      ENTITY ZSS_I_SERVICEREQUEST
        UPDATE FIELDS ( Priority )
        WITH VALUE #(
          (
            %tky     = request-%tky
            Priority = 'CRITICAL'
          )
        )
      FAILED DATA(failed_update)
      REPORTED DATA(reported_update).


    IF failed_update-zss_i_servicerequest IS NOT INITIAL.

      APPEND VALUE #(
        %tky = request-%tky
        %fail = VALUE #(
          cause = if_abap_behv=>cause-unspecific
        )
        %op-%action-escalateRequest = if_abap_behv=>mk-on
      ) TO failed-zss_i_servicerequest.

      CONTINUE.

    ENDIF.


    READ ENTITIES OF ZSS_I_SERVICEREQUEST IN LOCAL MODE
      ENTITY ZSS_I_SERVICEREQUEST
        ALL FIELDS
        WITH VALUE #(
          ( %tky = request-%tky )
        )
      RESULT DATA(updated_requests).

    IF updated_requests IS NOT INITIAL.

      APPEND VALUE #(
        %tky   = request-%tky
        %param = updated_requests[ 1 ]
      ) TO result.

    ENDIF.

  ENDLOOP.

  ENDMETHOD.


  METHOD assignTechnician.
  LOOP AT keys INTO DATA(key).

    IF key-%param-TechnicianId IS INITIAL.

      APPEND VALUE #(
        %tky = key-%tky
        %fail = VALUE #(
          cause = if_abap_behv=>cause-unspecific
        )
        %op-%action-assignTechnician = if_abap_behv=>mk-on
      ) TO failed-zss_i_servicerequest.

      APPEND VALUE #(
        %tky = key-%tky
        %op-%action-assignTechnician = if_abap_behv=>mk-on
        %msg = new_message_with_text(
          severity = if_abap_behv_message=>severity-error
          text     = 'Enter a technician ID.'
        )
      ) TO reported-zss_i_servicerequest.

      CONTINUE.

    ENDIF.

    MODIFY ENTITIES OF ZSS_I_SERVICEREQUEST IN LOCAL MODE
      ENTITY ZSS_I_SERVICEREQUEST
        UPDATE FIELDS ( AssignedTo Status )
        WITH VALUE #(
          (
            %tky       = key-%tky
            AssignedTo = key-%param-TechnicianId
            Status     = 'IN_PROGRESS'
          )
        )
      FAILED DATA(failed_update)
      REPORTED DATA(reported_update).

  ENDLOOP.


  READ ENTITIES OF ZSS_I_SERVICEREQUEST IN LOCAL MODE
    ENTITY ZSS_I_SERVICEREQUEST
      ALL FIELDS
      WITH CORRESPONDING #( keys )
    RESULT DATA(updated_requests).

  result = VALUE #(
    FOR request IN updated_requests
    (
      %tky   = request-%tky
      %param = request
    )
  ).
  ENDMETHOD.

ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations

