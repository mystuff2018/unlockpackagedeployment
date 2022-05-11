/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest(IsParallel = true)
private class dlrs_pse_RiskTest
{
    @IsTest
    private static void testTrigger()
    {
pse__Risk__c risk = new pse__Risk__c(
  pse__Risk_Name__c = ' TestRisk');
insert risk;
    }
}