@isTest
public class FBE_FPRM_DealExtRelatedList_Test {
@TestSetup
    static void setUpData() {
         User lUsr = FBE_UtilityFactory_Test.getIntegrationUser();
        List < Account > lAcc = FBE_UtilityFactory_Test.createAccount(3,null);
        system.runAs(lUsr){
            lAcc[0].FBE_AE_ISR__c = lUsr.Id;
            lAcc[0].FBE_Partner_Type__c = 'Distributor';
            lAcc[1].FBE_Partner_Type__c ='System Integrator';
            insert lAcc;
        }
        
        Deal_Registration__c Deal = FBE_UtilityFactory_Test.createDeal(1)[0];
            Deal.FBE_Deal_Justification_Statement__c = 'test statement';
            Deal.Name = 'test 1234';
            Deal.FBE_Account__c = lAcc[0].Id;
            Deal.FBE_End_User_Account__c = lAcc[0].Id;
            Deal.FBE_Distributor_Account__c = lAcc[0].Id;
            Deal.FBE_Book_Date__c = system.now().Date();
            Deal.FBE_Funding_Source__c = 'FUNDED-Prior Year Carryover';
            deal.Sales_Stage__c = 'Plan - 1%';
            deal.FBE_Solution_Domain__c = 'Business Solutions';
            Deal.FBE_Deal_Registration_Status__c ='New';
            Deal.FBE_Submission_Date__c = system.now();
            insert Deal;
        
List<Deal_Extension__c> dealext = new List<Deal_Extension__c>();
            Deal_Extension__c deale1 = new Deal_Extension__c();
            deale1.FBE_Deal_Registration__c = Deal.Id;
            deale1.FBE_Sequence_Number__c = 1;
            dealext.add(deale1);   
        Deal_Extension__c deale2 = new Deal_Extension__c();
            deale2.FBE_Deal_Registration__c = Deal.Id;
            deale2.FBE_Sequence_Number__c = 2;
            dealext.add(deale2); 
        Deal_Extension__c deale3 = new Deal_Extension__c();
            deale3.FBE_Deal_Registration__c = Deal.Id;
            deale3.FBE_Sequence_Number__c = 3;
            dealext.add(deale3); 
        Deal_Extension__c deale4 = new Deal_Extension__c();
            deale4.FBE_Deal_Registration__c = Deal.Id;
            deale4.FBE_Sequence_Number__c = 4;
            dealext.add(deale4); 
        insert dealext; 
    }
    
     @isTest
    private static void testDefaultQuery(){
        Deal_Registration__c dea = [SELECT Id FROM Deal_Registration__c WHERE Name = 'test 1234' LIMIT 1];
        FBE_FPRM_DealExtRelatedListController.fetchRecs(dea.id,'Deal_Extension__c','FBE_Deal_Registration__c','');
        FBE_FPRM_DealExtRelatedListController.fetchRecords(dea.id);
        FBE_FPRM_DealExtRelatedListController.getRecords(dea.id);
        
        system.assertNotEquals(null, dea, 'DealRegistration Records not found');
            }
}