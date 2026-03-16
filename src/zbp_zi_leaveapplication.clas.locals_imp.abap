CLASS lhc_leaveapplication DEFINITION
  INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.
    "--- Global authorization — user-level checks ---
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations
      FOR leaveapplication
      RESULT result.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features
      FOR leaveapplication RESULT result.

    METHODS setInitialStatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR leaveapplication~setInitialStatus.

    METHODS calculateTotalDays FOR DETERMINE ON MODIFY
      IMPORTING keys FOR leaveapplication~calculateTotalDays.

    METHODS validateDates FOR VALIDATE ON SAVE
      IMPORTING keys FOR leaveapplication~validateDates.

    METHODS validateEmployee FOR VALIDATE ON SAVE
      IMPORTING keys FOR leaveapplication~validateEmployee.

    METHODS validateLeaveType FOR VALIDATE ON SAVE
      IMPORTING keys FOR leaveapplication~validateLeaveType.

    METHODS submitLeave FOR MODIFY
      IMPORTING keys FOR ACTION leaveapplication~submitLeave
      RESULT result.

    METHODS approveLeave FOR MODIFY
      IMPORTING keys FOR ACTION leaveapplication~approveLeave
      RESULT result.

    METHODS rejectLeave FOR MODIFY
      IMPORTING keys FOR ACTION leaveapplication~rejectLeave
      RESULT result.

    METHODS withdrawLeave FOR MODIFY
      IMPORTING keys FOR ACTION leaveapplication~withdrawLeave
      RESULT result.


ENDCLASS.

CLASS lhc_leaveapplication IMPLEMENTATION.

  "════════════════════════════════════════════════════════════
  " INSTANCE FEATURES
  "════════════════════════════════════════════════════════════
  METHOD get_instance_features.

    READ ENTITIES OF zi_leaveapplication IN LOCAL MODE
      ENTITY leaveapplication
        FIELDS ( status )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_leave)
      FAILED failed.

    result = VALUE #(
      FOR ls_leave IN lt_leave
      LET lv_is_new       = xsdbool( ls_leave-status = 'N' )
          lv_is_submitted = xsdbool( ls_leave-status = 'S' )
          lv_is_terminal  = xsdbool( ls_leave-status = 'A' OR
                                     ls_leave-status = 'R' OR
                                     ls_leave-status = 'W' OR
                                     ls_leave-status = 'C' )
      IN
      ( %tky                  = ls_leave-%tky
        %action-submitLeave   = COND #(
          WHEN lv_is_new       = abap_true
          THEN if_abap_behv=>fc-o-enabled
          ELSE if_abap_behv=>fc-o-disabled )
        %action-approveLeave  = COND #(
          WHEN lv_is_submitted = abap_true
          THEN if_abap_behv=>fc-o-enabled
          ELSE if_abap_behv=>fc-o-disabled )
        %action-rejectLeave   = COND #(
          WHEN lv_is_submitted = abap_true
          THEN if_abap_behv=>fc-o-enabled
          ELSE if_abap_behv=>fc-o-disabled )
        %action-withdrawLeave = COND #(
          WHEN lv_is_submitted = abap_true
          THEN if_abap_behv=>fc-o-enabled
          ELSE if_abap_behv=>fc-o-disabled )
        %update               = COND #(
          WHEN lv_is_terminal  = abap_true
          THEN if_abap_behv=>fc-o-disabled
          ELSE if_abap_behv=>fc-o-enabled )
        %delete               = COND #(
          WHEN lv_is_terminal  = abap_true
          THEN if_abap_behv=>fc-o-disabled
          ELSE if_abap_behv=>fc-o-enabled ) ) ).

  ENDMETHOD.


  "════════════════════════════════════════════════════════════
  " DETERMINATION — Set initial status on CREATE
  "════════════════════════════════════════════════════════════
  METHOD setInitialStatus.

    READ ENTITIES OF zi_leaveapplication IN LOCAL MODE
      ENTITY leaveapplication
        FIELDS ( status )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_leave).

    DELETE lt_leave WHERE status IS NOT INITIAL.
    CHECK lt_leave IS NOT INITIAL.

    MODIFY ENTITIES OF zi_leaveapplication IN LOCAL MODE
      ENTITY leaveapplication
        UPDATE FIELDS ( status )
        WITH VALUE #(
          FOR ls_leave IN lt_leave
          ( %tky   = ls_leave-%tky
            status = 'N' ) )
      REPORTED DATA(lt_reported).

    reported-leaveapplication =
      CORRESPONDING #( DEEP lt_reported-leaveapplication ).

  ENDMETHOD.


  "════════════════════════════════════════════════════════════
  " DETERMINATION — Calculate total days from dates
  "════════════════════════════════════════════════════════════
  METHOD calculateTotalDays.

    READ ENTITIES OF zi_leaveapplication IN LOCAL MODE
      ENTITY leaveapplication
        FIELDS ( startdate enddate )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_leave).

*    MODIFY ENTITIES OF zi_leaveapplication IN LOCAL MODE
*      ENTITY leaveapplication
*        UPDATE FIELDS ( totaldays )
*        WITH VALUE #(
*          FOR ls_leave IN lt_leave
*          WHERE ( startdate IS NOT INITIAL
*              AND enddate   IS NOT INITIAL
*              AND enddate   >= startdate )
*          ( %tky      = ls_leave-%tky
*            totaldays = CONV #(
*              ls_leave-enddate - ls_leave-startdate + 1 ) ) )
*      REPORTED DATA(lt_reported).
*
*    reported-leaveapplication =
*      CORRESPONDING #( DEEP lt_reported-leaveapplication ).

  ENDMETHOD.


  "════════════════════════════════════════════════════════════
  " VALIDATION — Validate StartDate and EndDate
  "════════════════════════════════════════════════════════════
  METHOD validateDates.

    READ ENTITIES OF zi_leaveapplication IN LOCAL MODE
      ENTITY leaveapplication
        FIELDS ( startdate enddate )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_leave).

    DATA(lv_today) = cl_abap_context_info=>get_system_date( ).

    LOOP AT lt_leave INTO DATA(ls_leave).

      IF ls_leave-startdate IS INITIAL.
        APPEND VALUE #(
          %tky               = ls_leave-%tky
          %state_area        = 'VALIDATE_DATES'
          %msg               = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = 'Start date is required' )
          %element-startdate = if_abap_behv=>mk-on )
        TO reported-leaveapplication.
        APPEND VALUE #( %tky = ls_leave-%tky )
          TO failed-leaveapplication.
        CONTINUE.
      ENDIF.

      IF ls_leave-startdate < lv_today.
        APPEND VALUE #(
          %tky               = ls_leave-%tky
          %state_area        = 'VALIDATE_DATES'
          %msg               = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = 'Start date cannot be in the past' )
          %element-startdate = if_abap_behv=>mk-on )
        TO reported-leaveapplication.
        APPEND VALUE #( %tky = ls_leave-%tky )
          TO failed-leaveapplication.
      ENDIF.

      IF ls_leave-enddate < ls_leave-startdate.
        APPEND VALUE #(
          %tky             = ls_leave-%tky
          %state_area      = 'VALIDATE_DATES'
          %msg             = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = 'End date cannot be before start date' )
          %element-enddate = if_abap_behv=>mk-on )
        TO reported-leaveapplication.
        APPEND VALUE #( %tky = ls_leave-%tky )
          TO failed-leaveapplication.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  "════════════════════════════════════════════════════════════
  " VALIDATION — Employee must exist and be active
  "════════════════════════════════════════════════════════════
 METHOD validateEmployee.

  READ ENTITIES OF zi_leaveapplication IN LOCAL MODE
    ENTITY leaveapplication
      FIELDS ( employeeid )
      WITH CORRESPONDING #( keys )
    RESULT DATA(lt_leave).

  "--- Range table — required for IN operator in OpenSQL ---
  DATA lt_emp_ids TYPE RANGE OF zemployee_id.

  LOOP AT lt_leave INTO DATA(ls_leave).
    APPEND VALUE #(
      sign   = 'I'
      option = 'EQ'
      low    = ls_leave-employeeid )
    TO lt_emp_ids.
  ENDLOOP.

  "--- Deduplicate range table ---
  SORT lt_emp_ids BY low.
  DELETE ADJACENT DUPLICATES FROM lt_emp_ids
    COMPARING low.

  SELECT employee_id
    FROM zemp_mst
    WHERE employee_id IN @lt_emp_ids
      AND is_active   =  'X'
    INTO TABLE @DATA(lt_valid_employees).

  LOOP AT lt_leave INTO ls_leave.

    READ TABLE lt_valid_employees
      WITH KEY employee_id = ls_leave-employeeid
      TRANSPORTING NO FIELDS.

    IF sy-subrc <> 0.
      APPEND VALUE #(
        %tky                = ls_leave-%tky
        %state_area         = 'VALIDATE_EMPLOYEE'
        %msg                = new_message_with_text(
          severity = if_abap_behv_message=>severity-error
          text     = |Employee { ls_leave-employeeid
                      } does not exist or is inactive| )
        %element-employeeid = if_abap_behv=>mk-on )
      TO reported-leaveapplication.
      APPEND VALUE #( %tky = ls_leave-%tky )
        TO failed-leaveapplication.
    ENDIF.

  ENDLOOP.

ENDMETHOD.


  "════════════════════════════════════════════════════════════
  " VALIDATION — Leave Type must exist and be active
  "════════════════════════════════════════════════════════════
METHOD validateLeaveType.

  READ ENTITIES OF zi_leaveapplication IN LOCAL MODE
    ENTITY leaveapplication
      FIELDS ( leavetype )
      WITH CORRESPONDING #( keys )
    RESULT DATA(lt_leave).

  "--- RANGE OF — required for IN operator in OpenSQL ---
  "--- STANDARD TABLE OF zleave_type_code is NOT valid ---
  DATA lt_type_codes TYPE RANGE OF zleave_type_code.

  LOOP AT lt_leave INTO DATA(ls_leave).
    APPEND VALUE #(
      sign   = 'I'
      option = 'EQ'
      low    = ls_leave-leavetype )
    TO lt_type_codes.
  ENDLOOP.

  "--- Deduplicate range table before SELECT ---
  SORT lt_type_codes BY low.
  DELETE ADJACENT DUPLICATES FROM lt_type_codes
    COMPARING low.

  SELECT leave_type_code
    FROM zleave_type_t
    WHERE leave_type_code IN @lt_type_codes
      AND is_active       =  'X'
    INTO TABLE @DATA(lt_valid_types).

  LOOP AT lt_leave INTO ls_leave.

    READ TABLE lt_valid_types
      WITH KEY leave_type_code = ls_leave-leavetype
      TRANSPORTING NO FIELDS.

    IF sy-subrc <> 0.
      APPEND VALUE #(
        %tky               = ls_leave-%tky
        %state_area        = 'VALIDATE_LEAVETYPE'
        %msg               = new_message_with_text(
          severity = if_abap_behv_message=>severity-error
          text     = |Leave type { ls_leave-leavetype
                      } does not exist or is inactive| )
        %element-leavetype = if_abap_behv=>mk-on )
      TO reported-leaveapplication.
      APPEND VALUE #( %tky = ls_leave-%tky )
        TO failed-leaveapplication.
    ENDIF.

  ENDLOOP.

ENDMETHOD.


  "════════════════════════════════════════════════════════════
  " ACTION — Submit Leave (N → S)
  "════════════════════════════════════════════════════════════
  METHOD submitLeave.

    READ ENTITIES OF zi_leaveapplication IN LOCAL MODE
      ENTITY leaveapplication
        FIELDS ( status )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_leave)
      FAILED failed.

    DELETE lt_leave WHERE status <> 'N'.
    CHECK lt_leave IS NOT INITIAL.

    MODIFY ENTITIES OF zi_leaveapplication IN LOCAL MODE
      ENTITY leaveapplication
        UPDATE FIELDS ( status )
        WITH VALUE #(
          FOR ls_leave IN lt_leave
          ( %tky   = ls_leave-%tky
            status = 'S' ) )
      FAILED   failed
      REPORTED reported.

    READ ENTITIES OF zi_leaveapplication IN LOCAL MODE
      ENTITY leaveapplication
        ALL FIELDS
        WITH CORRESPONDING #( lt_leave )
      RESULT DATA(lt_result).

    result = VALUE #(
      FOR ls_result IN lt_result
      ( %tky   = ls_result-%tky
        %param = ls_result ) ).

  ENDMETHOD.


  "════════════════════════════════════════════════════════════
  " ACTION — Approve Leave (S → A)
  "════════════════════════════════════════════════════════════
METHOD approveLeave.

  READ ENTITIES OF zi_leaveapplication IN LOCAL MODE
    ENTITY leaveapplication
      FIELDS ( status )
      WITH CORRESPONDING #( keys )
    RESULT DATA(lt_leave)
    FAILED failed.

  DELETE lt_leave WHERE status <> 'S'.
  CHECK lt_leave IS NOT INITIAL.

  MODIFY ENTITIES OF zi_leaveapplication IN LOCAL MODE
    ENTITY leaveapplication
      UPDATE FIELDS ( status approvedby approvedat )
      WITH VALUE #(
        FOR ls_leave IN lt_leave
        ( %tky       = ls_leave-%tky
          status     = 'A'
          approvedby = cl_abap_context_info=>get_user_alias( )
          approvedat = utclong_current( ) ) )
  "                    ↑ built-in function — returns utclong directly
  "                    ↑ no class method needed — always available
    FAILED   failed
    REPORTED reported.

  READ ENTITIES OF zi_leaveapplication IN LOCAL MODE
    ENTITY leaveapplication
      ALL FIELDS
      WITH CORRESPONDING #( lt_leave )
    RESULT DATA(lt_result).

  result = VALUE #(
    FOR ls_result IN lt_result
    ( %tky   = ls_result-%tky
      %param = ls_result ) ).

ENDMETHOD.


  "════════════════════════════════════════════════════════════
  " ACTION — Reject Leave (S → R)
  "════════════════════════════════════════════════════════════
  METHOD rejectLeave.

    READ ENTITIES OF zi_leaveapplication IN LOCAL MODE
      ENTITY leaveapplication
        FIELDS ( status )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_leave)
      FAILED failed.

    DELETE lt_leave WHERE status <> 'S'.
    CHECK lt_leave IS NOT INITIAL.

    MODIFY ENTITIES OF zi_leaveapplication IN LOCAL MODE
      ENTITY leaveapplication
        UPDATE FIELDS ( status )
        WITH VALUE #(
          FOR ls_leave IN lt_leave
          ( %tky   = ls_leave-%tky
            status = 'R' ) )
      FAILED   failed
      REPORTED reported.

    READ ENTITIES OF zi_leaveapplication IN LOCAL MODE
      ENTITY leaveapplication
        ALL FIELDS
        WITH CORRESPONDING #( lt_leave )
      RESULT DATA(lt_result).

    result = VALUE #(
      FOR ls_result IN lt_result
      ( %tky   = ls_result-%tky
        %param = ls_result ) ).

  ENDMETHOD.


  "════════════════════════════════════════════════════════════
  " ACTION — Withdraw Leave (S → W)
  "════════════════════════════════════════════════════════════
  METHOD withdrawLeave.

    READ ENTITIES OF zi_leaveapplication IN LOCAL MODE
      ENTITY leaveapplication
        FIELDS ( status )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_leave)
      FAILED failed.

    DELETE lt_leave WHERE status <> 'S'.
    CHECK lt_leave IS NOT INITIAL.

    MODIFY ENTITIES OF zi_leaveapplication IN LOCAL MODE
      ENTITY leaveapplication
        UPDATE FIELDS ( status )
        WITH VALUE #(
          FOR ls_leave IN lt_leave
          ( %tky   = ls_leave-%tky
            status = 'W' ) )
      FAILED   failed
      REPORTED reported.

    READ ENTITIES OF zi_leaveapplication IN LOCAL MODE
      ENTITY leaveapplication
        ALL FIELDS
        WITH CORRESPONDING #( lt_leave )
      RESULT DATA(lt_result).

    result = VALUE #(
      FOR ls_result IN lt_result
      ( %tky   = ls_result-%tky
        %param = ls_result ) ).

  ENDMETHOD.

METHOD get_global_authorizations.

  "--- Trial / Demo system ---
  "--- Grant all operations to all users ---
  "--- No authorization object check performed ---

  IF requested_authorizations-%create EQ
      if_abap_behv=>mk-on.
    result-%create = if_abap_behv=>auth-allowed.
  ENDIF.

  IF requested_authorizations-%update EQ
      if_abap_behv=>mk-on.
    result-%update = if_abap_behv=>auth-allowed.
  ENDIF.

  IF requested_authorizations-%delete EQ
      if_abap_behv=>mk-on.
    result-%delete = if_abap_behv=>auth-allowed.
  ENDIF.

  IF requested_authorizations-%action-submitLeave EQ
      if_abap_behv=>mk-on.
    result-%action-submitLeave = if_abap_behv=>auth-allowed.
  ENDIF.

  IF requested_authorizations-%action-approveLeave EQ
      if_abap_behv=>mk-on.
    result-%action-approveLeave = if_abap_behv=>auth-allowed.
  ENDIF.

  IF requested_authorizations-%action-rejectLeave EQ
      if_abap_behv=>mk-on.
    result-%action-rejectLeave = if_abap_behv=>auth-allowed.
  ENDIF.

  IF requested_authorizations-%action-withdrawLeave EQ
      if_abap_behv=>mk-on.
    result-%action-withdrawLeave = if_abap_behv=>auth-allowed.
  ENDIF.

ENDMETHOD.

ENDCLASS.

CLASS lhc_attachment DEFINITION
  INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features
      FOR attachment RESULT result.

* validateAttachment replaces get_content + create_content
    METHODS validateAttachment FOR VALIDATE ON SAVE
      IMPORTING keys FOR attachment~validateAttachment.

ENDCLASS.

CLASS lhc_attachment IMPLEMENTATION.

  "════════════════════════════════════════════════════════════
  " INSTANCE FEATURES — Disable update for all attachments
  "════════════════════════════════════════════════════════════
  METHOD get_instance_features.

    result = VALUE #(
      FOR attachment IN keys
      ( %tky    = attachment-%tky
        %update = if_abap_behv=>fc-o-disabled ) ).

  ENDMETHOD.


  "════════════════════════════════════════════════════════════
  " VALIDATION — MIME type and file size checks
  "════════════════════════════════════════════════════════════
  METHOD validateAttachment.

    READ ENTITIES OF zi_leaveapplication IN LOCAL MODE
      ENTITY attachment
        FIELDS ( mimetype filesize filename )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_attachments).

    LOOP AT lt_attachments INTO DATA(ls_attach).

      "--- Validate MIME type ---
      IF ls_attach-mimetype <> 'application/pdf' AND
         ls_attach-mimetype <> 'image/jpeg'      AND
         ls_attach-mimetype <> 'image/png'.

        APPEND VALUE #(
          %tky            = ls_attach-%tky
          %state_area     = 'VALIDATE_ATTACHMENT'
          %msg            = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = |MIME type { ls_attach-mimetype
                        } not allowed. Use PDF JPEG or PNG| )
          %element-mimetype = if_abap_behv=>mk-on )
        TO reported-attachment.

        APPEND VALUE #( %tky = ls_attach-%tky )
          TO failed-attachment.

        CONTINUE.
      ENDIF.

      "--- Validate file name is not initial ---
      IF ls_attach-filename IS INITIAL.

        APPEND VALUE #(
          %tky              = ls_attach-%tky
          %state_area       = 'VALIDATE_ATTACHMENT'
          %msg              = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = 'File name is required' )
          %element-filename = if_abap_behv=>mk-on )
        TO reported-attachment.

        APPEND VALUE #( %tky = ls_attach-%tky )
          TO failed-attachment.

        CONTINUE.
      ENDIF.

      "--- Validate file size — max 5 MB = 5242880 bytes ---
      IF ls_attach-filesize > 5242880.

        APPEND VALUE #(
          %tky              = ls_attach-%tky
          %state_area       = 'VALIDATE_ATTACHMENT'
          %msg              = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = 'File size exceeds maximum limit of 5 MB' )
          %element-filesize = if_abap_behv=>mk-on )
        TO reported-attachment.

        APPEND VALUE #( %tky = ls_attach-%tky )
          TO failed-attachment.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
