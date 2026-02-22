@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS interface - job items'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZR_JOB_ITEM_0130
  as select from ztb_job_it_0130
  association to parent zr_job_head_0130 as _JobHead on $projection.JobUuid = _JobHead.JobUuid
{
  key item_uuid             as ItemUuid,
      job_uuid              as JobUuid,
      item_description      as ItemDescription,
      due_date              as DueDate,
      status                as Status,
      completion_ratio      as CompletionRatio,

      // Campos de Auditoria
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

      // Asociaciones
      _JobHead
}
