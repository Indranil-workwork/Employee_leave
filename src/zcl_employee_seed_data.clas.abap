CLASS zcl_employee_seed_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

  PRIVATE SECTION.
    METHODS seed_employees
      IMPORTING io_out TYPE REF TO if_oo_adt_classrun_out.
    METHODS verify_employees
      IMPORTING io_out TYPE REF TO if_oo_adt_classrun_out.
    METHODS print_separator
      IMPORTING io_out  TYPE REF TO if_oo_adt_classrun_out
                iv_label TYPE string.

ENDCLASS.



CLASS zcl_employee_seed_data IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    print_separator( io_out = out iv_label = 'EMPLOYEE MASTER — SEED DATA RUNNER' ).

    seed_employees(  io_out = out ).
    verify_employees( io_out = out ).

    print_separator( io_out = out iv_label = 'EMPLOYEE SEED DATA COMPLETED' ).

  ENDMETHOD.


  METHOD seed_employees.

    print_separator( io_out = io_out iv_label = 'Seeding: ZEM_MST' ).

    DATA lt_employees TYPE TABLE OF zemp_mst WITH EMPTY KEY.

    lt_employees = VALUE #(

      ( client        = sy-mandt
        employee_id   = '1'
        first_name    = 'Arjun'
        last_name     = 'Sharma'
        full_name     = 'Arjun Sharma'
        email         = 'arjun.sharma@company.com'
        department    = 'Information Technology'
        is_supervisor = ' '
        is_active     = 'X' )

      ( client        = sy-mandt
        employee_id   = '2'
        first_name    = 'Priya'
        last_name     = 'Mehta'
        full_name     = 'Priya Mehta'
        email         = 'priya.mehta@company.com'
        department    = 'Information Technology'
        is_supervisor = ' '
        is_active     = 'X' )

      ( client        = sy-mandt
        employee_id   = '3'
        first_name    = 'Rahul'
        last_name     = 'Verma'
        full_name     = 'Rahul Verma'
        email         = 'rahul.verma@company.com'
        department    = 'Human Resources'
        is_supervisor = ' '
        is_active     = 'X' )

      ( client        = sy-mandt
        employee_id   = '4'
        first_name    = 'Sneha'
        last_name     = 'Patil'
        full_name     = 'Sneha Patil'
        email         = 'sneha.patil@company.com'
        department    = 'Finance'
        is_supervisor = ' '
        is_active     = 'X' )

      ( client        = sy-mandt
        employee_id   = '5'
        first_name    = 'Vikram'
        last_name     = 'Nair'
        full_name     = 'Vikram Nair'
        email         = 'vikram.nair@company.com'
        department    = 'Operations'
        is_supervisor = ' '
        is_active     = 'X' )

      ( client        = sy-mandt
        employee_id   = '6'
        first_name    = 'Kavitha'
        last_name     = 'Iyer'
        full_name     = 'Kavitha Iyer'
        email         = 'kavitha.iyer@company.com'
        department    = 'Information Technology'
        is_supervisor = 'X'
        is_active     = 'X' )

      ( client        = sy-mandt
        employee_id   = '7'
        first_name    = 'Deepak'
        last_name     = 'Joshi'
        full_name     = 'Deepak Joshi'
        email         = 'deepak.joshi@company.com'
        department    = 'Human Resources'
        is_supervisor = 'X'
        is_active     = 'X' )

      ( client        = sy-mandt
        employee_id   = '8'
        first_name    = 'Anita'
        last_name     = 'Kulkarni'
        full_name     = 'Anita Kulkarni'
        email         = 'anita.kulkarni@company.com'
        department    = 'Finance'
        is_supervisor = 'X'
        is_active     = 'X' )

    ).

    DELETE FROM zemp_mst.

    io_out->write( |Deleted existing records from ZEMP_MST.| ).

    INSERT zemp_mst FROM TABLE @lt_employees.

    IF sy-subrc = 0.
      io_out->write( |✅ ZEMPLOYEE_T : { lines( lt_employees ) } records inserted.| ).
      io_out->write( | ↳ Regular Employees : EMP001 / EMP002 / EMP003 / EMP004 / EMP005| ).
      io_out->write( | ↳ Supervisors       : SUP001 / SUP002 / SUP003| ).
    ELSE.
      io_out->write( |❌ ZEMPLOYEE_T insert failed — SY-SUBRC = { sy-subrc }| ).
    ENDIF.

  ENDMETHOD.


  METHOD verify_employees.

    print_separator( io_out = io_out iv_label = 'Verification: ZEMPLOYEE_T' ).

    SELECT employee_id,
           full_name,
           department,
           is_supervisor,
           is_active
      FROM zemp_mst
      ORDER BY is_supervisor DESCENDING, employee_id ASCENDING
      INTO TABLE @DATA(lt_employees).

    IF lt_employees IS INITIAL.
      io_out->write( |❌ No records found in ZEMPLOYEE_T.| ).
      RETURN.
    ENDIF.

    io_out->write( |Total records found : { lines( lt_employees ) }| ).
    io_out->write( |━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━| ).
    io_out->write( |ID        | &
                |Full Name                    | &
                |Department           | &
                |Supervisor | &
                |Active| ).
    io_out->write( |━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━| ).

    LOOP AT lt_employees INTO DATA(ls_emp).
      io_out->write( |{ ls_emp-employee_id }   | &
                  |{ ls_emp-full_name }      | &
                  |{ ls_emp-department }     | &
                  |{ ls_emp-is_supervisor }          | &
                  |{ ls_emp-is_active }| ).
    ENDLOOP.

    DATA(lv_supervisor_count) = REDUCE i(
      INIT count = 0
      FOR ls IN lt_employees
      WHERE ( is_supervisor = 'X' )
      NEXT count = count + 1 ).

    DATA(lv_active_count) = REDUCE i(
      INIT count = 0
      FOR ls IN lt_employees
      WHERE ( is_active = 'X' )
      NEXT count = count + 1 ).

    io_out->write( |━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━| ).
    io_out->write( |✅ Supervisors : { lv_supervisor_count }| ).
    io_out->write( |✅ Active      : { lv_active_count }| ).

  ENDMETHOD.


  METHOD print_separator.
    io_out->write( `` ).
    io_out->write( |━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━| ).
    io_out->write( | { iv_label }| ).
    io_out->write( |━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━| ).
  ENDMETHOD.

ENDCLASS.

