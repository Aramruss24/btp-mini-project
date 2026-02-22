@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS interface - job head'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZR_JOB_HEAD_0130
  as select from ztb_job_he_0130
  composition [0..*] of zr_job_item_0130 as _JobItems
{
  key job_uuid              as JobUuid,
      job_title             as JobTitle,
      client_name           as ClientName,
      status                as Status,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      proposal_amount       as ProposalAmount,
      currency_code         as CurrencyCode,

      //Campos de auditoria
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,

      // Aociaciones
      _JobItems
}
