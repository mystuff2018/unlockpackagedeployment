public class FBE_FindBDQuadForOpty {
	public Id oppid {get;set;}
    public List<BD_Opportunity_QUAD__c> getOptyBDQuad(){
        List<BD_Opportunity_QUAD__c> BDQuadQry;
		BDQuadQry = [select Id,Name,Lines_of_Business__c,CONUS_OCONUS_Both__c,DirectIndirect__c,Partners_List__c,Supplier__c,Type__c,Award_Decision_Criteria__c,Non_Standard__c,Dell_Pursuit_Team__c,Procurment_Details__c,Asks__c,Deal_Overview__c,WIN_Strategy__c,SAB__c,Formal_actions_to_date__c,Pricing__c,CompetitiveLandscapeType__c,PricingCompLandscape__c from BD_Opportunity_QUAD__c where Opportunity__c=:oppid and BD_QUAD_Template__c='Deal Review' order by createdDate desc limit 1];
    	return BDQuadQry;
    }
}