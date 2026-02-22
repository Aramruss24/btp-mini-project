@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption - views items'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_JOB_ITEM_0130
  as projection on ZR_JOB_ITEM_0130
{
  key ItemUuid,
      JobUuid,
      ItemDescription,
      DueDate,
      Status,
      CompletionRatio,
      LocalLastChangedAt,
      /* Associations */
      _JobHead : redirected to parent ZC_JOB_HEAD_0130
}
