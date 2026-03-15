CLASS zcl_leave_seed_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

  PRIVATE SECTION.

    "--- Leave Type ---
    METHODS seed_leave_type_config
      IMPORTING io_out TYPE REF TO if_oo_adt_classrun_out.

    METHODS seed_leave_type_texts
      IMPORTING io_out TYPE REF TO if_oo_adt_classrun_out.

    "--- Leave Status ---
    METHODS seed_leave_status_config
      IMPORTING io_out TYPE REF TO if_oo_adt_classrun_out.

    METHODS seed_leave_status_texts
      IMPORTING io_out TYPE REF TO if_oo_adt_classrun_out.

    "--- Helpers ---
    METHODS print_separator
      IMPORTING io_out TYPE REF TO if_oo_adt_classrun_out
                iv_label TYPE string.

ENDCLASS.


CLASS zcl_leave_seed_data IMPLEMENTATION.



  METHOD if_oo_adt_classrun~main.
    " MAIN ENTRY POINT — F9 to execute
    print_separator( io_out = out iv_label = 'LEAVE APPLICATION — SEED DATA RUNNER' ).

    "--- Seed in strict dependency order ---
    "--- Parent tables first, text tables second ---
    seed_leave_type_config(   io_out = out ).
    seed_leave_type_texts(    io_out = out ).
    seed_leave_status_config( io_out = out ).
    seed_leave_status_texts(  io_out = out ).

    print_separator( io_out = out iv_label = 'ALL SEED DATA COMPLETED SUCCESSFULLY' ).

  ENDMETHOD.



  METHOD seed_leave_type_config. " TABLE 1: ZLEAVE_TYPE_T — Language Independent Configuration

    print_separator( io_out = io_out iv_label = 'Seeding: ZLEAVE_TYPE_T' ).

    DATA lt_types TYPE TABLE OF zleave_type_t WITH EMPTY KEY.

    "--- Build payload ---
    "--- Note: No description fields here — moved to ZLEAVE_TYPE_TX ---
    lt_types = VALUE #(

      ( client             = sy-mandt
        leave_type_code    = 'AL'
        max_days_allowed   = 21
        requires_document  = ' '
        is_active          = 'X' )

      ( client             = sy-mandt
        leave_type_code    = 'SL'
        max_days_allowed   = 14
        requires_document  = 'X'    "Doctor note mandatory for Sick Leave
        is_active          = 'X' )

      ( client             = sy-mandt
        leave_type_code    = 'ML'
        max_days_allowed   = 30
        requires_document  = 'X'    "Doctor note mandatory for Medical Leave
        is_active          = 'X' )

      ( client             = sy-mandt
        leave_type_code    = 'UL'
        max_days_allowed   = 90
        requires_document  = ' '
        is_active          = 'X' )

      ( client             = sy-mandt
        leave_type_code    = 'CL'
        max_days_allowed   = 7
        requires_document  = ' '
        is_active          = 'X' )

    ).

    "--- Idempotent: delete existing before insert ---
    DELETE FROM zleave_type_t.

    io_out->write( |Deleted existing records from ZLEAVE_TYPE_T.| ).

    "--- Insert fresh records ---
    INSERT zleave_type_t FROM TABLE @lt_types.

    IF sy-subrc = 0.
      io_out->write( |✅ ZLEAVE_TYPE_T : { lines( lt_types ) } records inserted.| ).
      io_out->write( | ↳ Codes seeded : AL / SL / ML / UL / CL| ).
    ELSE.
      io_out->write( |❌ ZLEAVE_TYPE_T insert failed — SY-SUBRC = { sy-subrc }| ).
    ENDIF.

  ENDMETHOD.


  METHOD seed_leave_type_texts. " TABLE 2: ZLEAVE_TYPE_TX — Language Dependent Texts

    print_separator( io_out = io_out iv_label = 'Seeding: ZLEAVE_TYPE_TX' ).

    DATA lt_texts TYPE TABLE OF zleave_type_tx WITH EMPTY KEY.

    lt_texts = VALUE #(

      "══════════════════════════
      " ENGLISH  (langu = 'E')
      "══════════════════════════
      ( client              = sy-mandt
        leave_type_code     = 'AL'
        langu               = 'E'
        leave_type_desc     = 'Annual Leave'
        leave_type_short_desc = 'Annual' )

      ( client              = sy-mandt
        leave_type_code     = 'SL'
        langu               = 'E'
        leave_type_desc     = 'Sick Leave'
        leave_type_short_desc = 'Sick' )

      ( client              = sy-mandt
        leave_type_code     = 'ML'
        langu               = 'E'
        leave_type_desc     = 'Medical Leave'
        leave_type_short_desc = 'Medical' )

      ( client              = sy-mandt
        leave_type_code     = 'UL'
        langu               = 'E'
        leave_type_desc     = 'Unpaid Leave'
        leave_type_short_desc = 'Unpaid' )

      ( client              = sy-mandt
        leave_type_code     = 'CL'
        langu               = 'E'
        leave_type_desc     = 'Casual Leave'
        leave_type_short_desc = 'Casual' )

      "══════════════════════════
      " GERMAN  (langu = 'D')
      "══════════════════════════
      ( client              = sy-mandt
        leave_type_code     = 'AL'
        langu               = 'D'
        leave_type_desc     = 'Jahresurlaub'
        leave_type_short_desc = 'Jahres' )

      ( client              = sy-mandt
        leave_type_code     = 'SL'
        langu               = 'D'
        leave_type_desc     = 'Krankenurlaub'
        leave_type_short_desc = 'Krank' )

      ( client              = sy-mandt
        leave_type_code     = 'ML'
        langu               = 'D'
        leave_type_desc     = 'Medizinischer Urlaub'
        leave_type_short_desc = 'Medizin' )

      ( client              = sy-mandt
        leave_type_code     = 'UL'
        langu               = 'D'
        leave_type_desc     = 'Unbezahlter Urlaub'
        leave_type_short_desc = 'Unbezahlt' )

      ( client              = sy-mandt
        leave_type_code     = 'CL'
        langu               = 'D'
        leave_type_desc     = 'Gelegenheitsurlaub'
        leave_type_short_desc = 'Gelegen' )

      "══════════════════════════
      " FRENCH  (langu = 'F')
      "══════════════════════════
      ( client              = sy-mandt
        leave_type_code     = 'AL'
        langu               = 'F'
        leave_type_desc     = 'Congé annuel'
        leave_type_short_desc = 'Annuel' )

      ( client              = sy-mandt
        leave_type_code     = 'SL'
        langu               = 'F'
        leave_type_desc     = 'Congé maladie'
        leave_type_short_desc = 'Maladie' )

      ( client              = sy-mandt
        leave_type_code     = 'ML'
        langu               = 'F'
        leave_type_desc     = 'Congé médical'
        leave_type_short_desc = 'Médical' )

      ( client              = sy-mandt
        leave_type_code     = 'UL'
        langu               = 'F'
        leave_type_desc     = 'Congé non rémunéré'
        leave_type_short_desc = 'Non rém.' )

      ( client              = sy-mandt
        leave_type_code     = 'CL'
        langu               = 'F'
        leave_type_desc     = 'Congé occasionnel'
        leave_type_short_desc = 'Occasion' )

    ).

    "--- Idempotent delete ---
    DELETE FROM zleave_type_tx.

    io_out->write( |Deleted existing records from ZLEAVE_TYPE_TX.| ).

    INSERT zleave_type_tx FROM TABLE @lt_texts.

    IF sy-subrc = 0.
      io_out->write( |✅ ZLEAVE_TYPE_TX : { lines( lt_texts ) } records inserted.| ).
      io_out->write( | ↳ Languages seeded : EN (E) / DE (D) / FR (F)| ).
      io_out->write( | ↳ Records per lang : 5 codes × 3 languages = 15 total| ).
    ELSE.
      io_out->write( |❌ ZLEAVE_TYPE_TX insert failed — SY-SUBRC = { sy-subrc }| ).
    ENDIF.

  ENDMETHOD.


  METHOD seed_leave_status_config. " TABLE 3: ZLEAVE_STATUS_T — Language Independent Configuration

    print_separator( io_out = io_out iv_label = 'Seeding: ZLEAVE_STATUS_T' ).

    DATA lt_status TYPE TABLE OF zleave_status_t WITH EMPTY KEY.

    "--- Note: No description fields here — moved to ZLEAVE_STATUS_TX ---
    lt_status = VALUE #(

      ( client              = sy-mandt
        status_code         = 'N'
        status_criticality  = 0       "Fiori: Grey  — no semantic color
        is_terminal         = ' '     "Can still transition forward
        icon_url            = 'sap-icon://status-inactive' )

      ( client              = sy-mandt
        status_code         = 'S'
        status_criticality  = 2       "Fiori: Yellow — in process
        is_terminal         = ' '     "Awaiting approval decision
        icon_url            = 'sap-icon://status-in-process' )

      ( client              = sy-mandt
        status_code         = 'A'
        status_criticality  = 3       "Fiori: Green  — positive outcome
        is_terminal         = 'X'     "No further transitions allowed
        icon_url            = 'sap-icon://status-positive' )

      ( client              = sy-mandt
        status_code         = 'R'
        status_criticality  = 1       "Fiori: Red    — negative outcome
        is_terminal         = 'X'     "No further transitions allowed
        icon_url            = 'sap-icon://status-negative' )

      ( client              = sy-mandt
        status_code         = 'W'
        status_criticality  = 1       "Fiori: Red    — withdrawn by employee
        is_terminal         = 'X'
        icon_url            = 'sap-icon://status-critical' )

      ( client              = sy-mandt
        status_code         = 'C'
        status_criticality  = 0       "Fiori: Grey   — cancelled
        is_terminal         = 'X'
        icon_url            = 'sap-icon://status-inactive' )

    ).

    DELETE FROM zleave_status_t.

    io_out->write( |Deleted existing records from ZLEAVE_STATUS_T.| ).

    INSERT zleave_status_t FROM TABLE @lt_status.

    IF sy-subrc = 0.
      io_out->write( |✅ ZLEAVE_STATUS_T : { lines( lt_status ) } records inserted.| ).
      io_out->write( | ↳ Codes seeded : N / S / A / R / W / C| ).
      io_out->write( | ↳ Terminal codes : A / R / W / C| ).
    ELSE.
      io_out->write( |❌ ZLEAVE_STATUS_T insert failed — SY-SUBRC = { sy-subrc }| ).
    ENDIF.

  ENDMETHOD.

  METHOD seed_leave_status_texts. " TABLE 4: ZLEAVE_STATUS_TX — Language Dependent Texts

    print_separator( io_out = io_out iv_label = 'Seeding: ZLEAVE_STATUS_TX' ).

    DATA lt_texts TYPE TABLE OF zleave_status_tx WITH EMPTY KEY.

    lt_texts = VALUE #(

      "══════════════════════════
      " ENGLISH  (langu = 'E')
      "══════════════════════════
      ( client            = sy-mandt
        status_code       = 'N'
        langu             = 'E'
        status_desc       = 'New'
        status_short_desc = 'New' )

      ( client            = sy-mandt
        status_code       = 'S'
        langu             = 'E'
        status_desc       = 'Submitted'
        status_short_desc = 'Submitted' )

      ( client            = sy-mandt
        status_code       = 'A'
        langu             = 'E'
        status_desc       = 'Approved'
        status_short_desc = 'Approved' )

      ( client            = sy-mandt
        status_code       = 'R'
        langu             = 'E'
        status_desc       = 'Rejected'
        status_short_desc = 'Rejected' )

      ( client            = sy-mandt
        status_code       = 'W'
        langu             = 'E'
        status_desc       = 'Withdrawn'
        status_short_desc = 'Withdrawn' )

      ( client            = sy-mandt
        status_code       = 'C'
        langu             = 'E'
        status_desc       = 'Cancelled'
        status_short_desc = 'Cancelled' )

      "══════════════════════════
      " GERMAN  (langu = 'D')
      "══════════════════════════
      ( client            = sy-mandt
        status_code       = 'N'
        langu             = 'D'
        status_desc       = 'Neu'
        status_short_desc = 'Neu' )

      ( client            = sy-mandt
        status_code       = 'S'
        langu             = 'D'
        status_desc       = 'Eingereicht'
        status_short_desc = 'Eingereicht' )

      ( client            = sy-mandt
        status_code       = 'A'
        langu             = 'D'
        status_desc       = 'Genehmigt'
        status_short_desc = 'Genehm.' )

      ( client            = sy-mandt
        status_code       = 'R'
        langu             = 'D'
        status_desc       = 'Abgelehnt'
        status_short_desc = 'Abgel.' )

      ( client            = sy-mandt
        status_code       = 'W'
        langu             = 'D'
        status_desc       = 'Zurückgezogen'
        status_short_desc = 'Zurückgez.' )

      ( client            = sy-mandt
        status_code       = 'C'
        langu             = 'D'
        status_desc       = 'Storniert'
        status_short_desc = 'Storniert' )

      "══════════════════════════
      " FRENCH  (langu = 'F')
      "══════════════════════════
      ( client            = sy-mandt
        status_code       = 'N'
        langu             = 'F'
        status_desc       = 'Nouveau'
        status_short_desc = 'Nouveau' )

      ( client            = sy-mandt
        status_code       = 'S'
        langu             = 'F'
        status_desc       = 'Soumis'
        status_short_desc = 'Soumis' )

      ( client            = sy-mandt
        status_code       = 'A'
        langu             = 'F'
        status_desc       = 'Approuvé'
        status_short_desc = 'Approuvé' )

      ( client            = sy-mandt
        status_code       = 'R'
        langu             = 'F'
        status_desc       = 'Rejeté'
        status_short_desc = 'Rejeté' )

      ( client            = sy-mandt
        status_code       = 'W'
        langu             = 'F'
        status_desc       = 'Retiré'
        status_short_desc = 'Retiré' )

      ( client            = sy-mandt
        status_code       = 'C'
        langu             = 'F'
        status_desc       = 'Annulé'
        status_short_desc = 'Annulé' )

    ).

    DELETE FROM zleave_status_tx.

    io_out->write( |Deleted existing records from ZLEAVE_STATUS_TX.| ).

    INSERT zleave_status_tx FROM TABLE @lt_texts.

    IF sy-subrc = 0.
      io_out->write( |✅ ZLEAVE_STATUS_TX : { lines( lt_texts ) } records inserted.| ).
      io_out->write( | ↳ Languages seeded : EN (E) / DE (D) / FR (F)| ).
      io_out->write( | ↳ Records per lang : 6 codes × 3 languages = 18 total| ).
    ELSE.
      io_out->write( |❌ ZLEAVE_STATUS_TX insert failed — SY-SUBRC = { sy-subrc }| ).
    ENDIF.

  ENDMETHOD.


  METHOD print_separator. " HELPER: Print visual separator in console

    io_out->write( `` ).
    io_out->write( |━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━| ).
    io_out->write( | { iv_label }| ).
    io_out->write( |━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━| ).

  ENDMETHOD.

ENDCLASS.

