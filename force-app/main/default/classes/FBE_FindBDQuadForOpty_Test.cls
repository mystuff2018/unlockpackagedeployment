@istest
public class FBE_FindBDQuadForOpty_Test {
	static testmethod void FindBDQuadForOpty(){
        System.Test.startTest();
        User lUsr = FBE_UtilityFactory_Test.getIntegrationUser();
        List <Account> lAcc = FBE_UtilityFactory_Test.createAccount(1,null);
        Id bdcaprec = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('BD Capture Team Record Type').getRecordTypeId();
        System.debug('BDCaptureRecordTypeId = '+bdcaprec);
        system.runAs(lUsr) {
            lAcc[0].FBE_Partner_Type__c = 'Reseller';
            lAcc[0].name = 'SFDC Test Account for BD Opty';
            insert lAcc;
        }
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity for BD Opty',
            Description = 'Test Opportunity for BD Opt Desc',
            //RecordType.Name = 'BD Capture Team Record Type',
            RecordTypeId = bdcaprec,
            AccountId = lAcc[0].Id,
            Capability__c = 'New',
            Market__c = 'New',
            CloseDate = System.today(),
            StageName = '01 - Identification',
            Opportunity_Leader__c = lUsr.Id,
            Total_Contract_Value__c = 12345,
            Dell_Contract_Value__c = 10000,
            Sales_Segment__c = 'Civilian',
            FBE_Funding_Source__c = 'FUNDED-Current Yr Annl Funding',
            //Type = 'Deal/Bid - Indirect',
            //FBE_Contracting_Status__c = 'Pre RFP',
            FBE_Federal_Alliance_Segment__c = '5G Solutions;Cloud'
        	);
        insert opp;
        BD_Opportunity_QUAD__c Bdq1 = new BD_Opportunity_QUAD__c();
        Bdq1.BD_QUAD_Template__c = 'Deal Review';
        Bdq1.Deal_Overview__c = 'Deal Review Created Overview1';
        Bdq1.Opportunity__c = opp.Id;
        insert Bdq1;
        BD_Opportunity_QUAD__c Bdq2 = new BD_Opportunity_QUAD__c();
        Bdq2.BD_QUAD_Template__c = 'Deal Strategy';
        Bdq2.Deal_Overview__c = 'Deal Review Created Overview2';
        Bdq2.Opportunity__c = opp.Id;
        insert Bdq2;
        BD_Opportunity_QUAD__c Bdq3 = new BD_Opportunity_QUAD__c();
        Bdq1.BD_QUAD_Template__c = 'Partner AE Brief In';
        Bdq3.Deal_Overview__c = 'Deal Review Created Overview3';
        Bdq3.Opportunity__c = opp.Id;
        insert Bdq3;
        BD_Opportunity_QUAD__c Bdq4 = new BD_Opportunity_QUAD__c();
        Bdq4.BD_QUAD_Template__c = 'Deal Review';
        Bdq4.Deal_Overview__c = 'Deal Review Created Overview4';
        Bdq4.Opportunity__c = opp.Id;
        insert Bdq4;
        BD_Opportunity_QUAD__c Bdq5 = new BD_Opportunity_QUAD__c();
        Bdq5.BD_QUAD_Template__c = 'Deal Review';
        Bdq5.Deal_Overview__c = 'Deal Review Created Overview5';
        Bdq5.Opportunity__c = opp.Id;
        insert Bdq5;
        FBE_FindBDQuadForOpty a1 = new FBE_FindBDQuadForOpty();
        BD_Opportunity_QUAD__c aa1 = [select Id,BD_QUAD_Template__c,Deal_Overview__c,Opportunity__c from BD_Opportunity_QUAD__c where BD_QUAD_Template__c='Deal Review' and Opportunity__c=:opp.Id order by createdDate desc limit 1];
        a1.oppid=opp.Id;
        a1.getOptyBDQuad();
        system.assertEquals('Deal Review', aa1.BD_QUAD_Template__c);
        System.Test.stopTest();
    }
}