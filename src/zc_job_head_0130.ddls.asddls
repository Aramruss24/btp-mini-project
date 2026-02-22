@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption - views head'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_JOB_HEAD_0130
  provider contract transactional_query
  as projection on ZR_JOB_HEAD_0130
{
  key JobUuid,
      @Search.defaultSearchElement: true
      JobTitle,
      @Search.defaultSearchElement: true
      ClientName,
      Status,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      ProposalAmount,
      CurrencyCode,
      CreatedBy,
      CreatedAt,
      LocalLastChangedAt,
      /* Associations */
      _JobItems : redirected to composition child ZC_JOB_ITEM_0130
}
