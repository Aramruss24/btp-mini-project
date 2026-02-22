CLASS zcl_gen_data_0130 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_gen_data_0130 IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    " 1. Limpiamos las tablas para empezar de cero
    DELETE FROM ztb_job_he_0130.
    DELETE FROM ztb_job_it_0130.

    " 2. Declaramos tablas internas
    DATA: lt_header TYPE TABLE OF ztb_job_he_0130,
          lt_items  TYPE TABLE OF ztb_job_it_0130.

    " 3. Variables para UUIDs y Tiempos
    DATA: lv_job_uuid TYPE sysuuid_x16,
          lv_ts       TYPE abp_creation_tstmpl.

    GET TIME STAMP FIELD lv_ts.

    " --- OPORTUNIDAD 1: Proyecto SAP BTP en España ---

    " Generamos un UUID nuevo para esta cabecera
    TRY.
        lv_job_uuid = cl_system_uuid=>create_uuid_x16_static( ).
      CATCH cx_uuid_error.
    ENDTRY.

    APPEND VALUE #(
      client                = sy-mandt
      job_uuid              = lv_job_uuid
      job_title             = 'Consultor Senior ABAP RAP'
      client_name           = 'Iberia Tech S.L.'
      status                = 'O' " Open
      proposal_amount       = '350.00'
      currency_code         = 'EUR'
      created_by            = 'GENERATOR'
      created_at            = lv_ts
      local_last_changed_at = lv_ts " Importante para ETag
    ) TO lt_header.

    TRY.

        " Item 1.1: Entrevista
        APPEND VALUE #(
          client           = sy-mandt
          item_uuid        = cl_system_uuid=>create_uuid_x16_static( )
          job_uuid         = lv_job_uuid " ¡Aquí enlazamos con el padre!
          item_description = 'Entrevista Técnica con Arquitecto'
          due_date         = '20260220'
          status           = 'P'
          completion_ratio = 0
          local_last_changed_at = lv_ts
        ) TO lt_items.

        " Item 1.2: Prueba Técnica
        APPEND VALUE #(
          client           = sy-mandt
          item_uuid        = cl_system_uuid=>create_uuid_x16_static( )
          job_uuid         = lv_job_uuid
          item_description = 'Desarrollo de API Restful'
          due_date         = '20260225'
          status           = 'P'
          completion_ratio = 0
          local_last_changed_at = lv_ts
        ) TO lt_items.

      CATCH cx_uuid_error.

    ENDTRY.

    " --- OPORTUNIDAD 2: Migración S/4HANA en Italia ---

    TRY.
        lv_job_uuid = cl_system_uuid=>create_uuid_x16_static( ).
      CATCH cx_uuid_error.
    ENDTRY.

    APPEND VALUE #(
      client                = sy-mandt
      job_uuid              = lv_job_uuid
      job_title             = 'S/4HANA Migration Lead'
      client_name           = 'Milano Fashion Group'
      status                = 'A' " Accepted
      proposal_amount       = '450.00'
      currency_code         = 'EUR'
      created_by            = 'GENERATOR'
      created_at            = lv_ts
      local_last_changed_at = lv_ts
    ) TO lt_header.

    " 4. Insertamos en Base de Datos
    INSERT ztb_job_he_0130 FROM TABLE @lt_header.
    INSERT ztb_job_it_0130 FROM TABLE @lt_items.

    " 5. Mensaje de éxito en consola
    out->write( |Se han creado { lines( lt_header ) } oportunidades y { lines( lt_items ) } hitos.| ).

  ENDMETHOD.
ENDCLASS.
