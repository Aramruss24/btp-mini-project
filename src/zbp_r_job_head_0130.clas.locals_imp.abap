CLASS lhc_JobHeader DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR JobHeader RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR JobHeader RESULT result.
    METHODS setInitialValues FOR DETERMINE ON MODIFY
      IMPORTING keys FOR JobHeader~setInitialValues.

    METHODS validateAmount FOR VALIDATE ON SAVE
      IMPORTING keys FOR JobHeader~validateAmount.
    METHODS acceptOpportunity FOR MODIFY
      IMPORTING keys FOR ACTION JobHeader~acceptOpportunity RESULT result.

    METHODS rejectOpportunity FOR MODIFY
      IMPORTING keys FOR ACTION JobHeader~rejectOpportunity RESULT result.

ENDCLASS.

CLASS lhc_JobHeader IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD setInitialValues.

    "1. Leemos las instancias que se acaban de crear en memoria
    " IN LOCAL MODE nos permite saltarnos las verificaciones de autorización interna
    READ ENTITIES OF zr_job_head_0130 IN LOCAL MODE
        ENTITY JobHeader
        FIELDS ( Status CurrencyCode ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_job_headers).

    "2. Preparamos una tabla interna con los cambios
    DATA lt_update TYPE TABLE FOR UPDATE zr_job_head_0130.

    LOOP AT lt_job_headers INTO DATA(ls_job).
      " Solo actualizamos si están vacíos
      IF ls_job-Status IS INITIAL OR ls_job-CurrencyCode IS INITIAL.
        APPEND VALUE #( %tky = ls_job-%tky "%tky es la clave mágica transaccional (Draft + Activo)
                        Status = 'O'       " O = Open
                        CurrencyCode = 'EUR' ) TO lt_update.
      ENDIF.
    ENDLOOP.

    "3. Modificamos la entidad en memoria usando EML
    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zr_job_head_0130 IN LOCAL MODE
          ENTITY JobHeader
              UPDATE FIELDS ( Status CurrencyCode ) WITH lt_update
          REPORTED DATA(update_reported).

      LOOP AT update_reported-jobheader INTO DATA(ls_message).
        APPEND CORRESPONDING #( ls_message ) TO reported-jobheader.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.

  METHOD validateAmount.

    "1. Leemos la tarifa de las instancias que se van a guardar
    READ ENTITIES OF zr_job_head_0130 IN LOCAL MODE
       ENTITY JobHeader
       FIELDS ( ProposalAmount ) WITH CORRESPONDING #( keys )
       RESULT DATA(lt_job_headers).

    LOOP AT lt_job_headers INTO DATA(ls_job).

      "2. Nuestra regla de negocio: Tarifa > 0
      IF ls_job-ProposalAmount <= 0.

        "3 Bloqueamos el guardado añadiendo la clave a la tabla FAILED
        APPEND VALUE #( %tky = ls_job-%tky ) TO failed-jobheader.

        "4 Enviamos un mensaje de error a la interfaz Fiori (Reported)
        APPEND VALUE #( %tky = ls_job-%tky
                        %msg = new_message_with_text(
                                severity = if_abap_behv_message=>severity-error
                                text     = '¡Error! La tarifa propuesta debe ser mayor a cero.' )
                        %element-proposalamount = if_abap_behv=>mk-on " Esto pinta el campo de rojo en Fiori
                       ) TO reported-jobheader.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD acceptOpportunity.
    "1. ACTUALIZAR: Cambiamos el estado a 'A' (Aceptado)
    "Usamos EML para modificar la entidad de forma segura
    MODIFY ENTITIES OF zr_job_head_0130 IN LOCAL MODE
        ENTITY JobHeader
          UPDATE FIELDS ( Status )
          WITH VALUE #( FOR key IN keys ( %tky = key-%tky Status = 'A' ) )
          FAILED failed
          REPORTED reported.

    "2. LEER: Obtenemos el registro recién actualizado
    "Fiori necesita que le devolvamos los datos frescos para refrescar la pantalla
    READ ENTITIES OF zr_job_head_0130 IN LOCAL MODE
        ENTITY JobHeader
          ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_jobs).

    "3. RETORNAR: Llenamos el parámetro 'result' esperando por la acción
    result = VALUE #( FOR job IN lt_jobs ( %tky = job-%tky %param = job ) ).


  ENDMETHOD.

  METHOD rejectOpportunity.
    "1. ACTUALIZAR: Cambiamos el estado a 'R' (Rechazado)
    MODIFY ENTITIES OF zr_job_head_0130 IN LOCAL MODE
        ENTITY JobHeader
        UPDATE FIELDS ( Status )
        WITH VALUE #( FOR key IN keys ( %tky = key-%tky Status = 'R' ) )
        FAILED failed
        REPORTED reported.

    "2. LEER: Obtenemos el registro actualizado
    READ ENTITIES OF zr_job_head_0130 IN LOCAL MODE
        ENTITY JobHeader
            ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(lt_job).

    "3. RETORNAR: Llenamos al parámetro 'result'
    result = VALUE #( FOR job IN lt_job ( %tky = job-%tky %param = job ) ).

  ENDMETHOD.

ENDCLASS.
