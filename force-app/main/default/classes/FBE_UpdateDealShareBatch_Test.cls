/**************
*@ Class Name                                                    : FBE_UpdateDealShareBatch_Test
*@ Description                                                   : Test Class for FBE_UpdateDealShareBatch
*@ CreatedBy                                                     : Dell Team
*@ CreatedOn                                                     : 10-01-2020 [Siva Kumar Valluru]
*@ Modification Log                                              : 
***************/  

@isTest
public class FBE_UpdateDealShareBatch_Test {
    
    static testmethod void FBE_UpdateDeal(){
        
        List < User > nonintegusers = new List < User > ();
        list<Account> lstAcc = new list<Account>();
        list<Deal_Registration__c > lstDeal = new list<Deal_Registration__c >();
        nonintegusers = FBE_UtilityFactory_Test.createUser('System Administrator', 1, 'sys' ,null);
        
        User lstuser = FBE_UtilityFactory_Test.getIntegrationUser();
        System.runAs(lstuser){
            lstAcc = FBE_Test_Utility.createAccount(1);
            Insert lstAcc;
        }        
        
        lstDeal = FBE_Test_Utility.createDeal(1); 
        Insert lstDeal;
        
        List<FBE_Deal_Registration_Team__c> lstdrt = new list<FBE_Deal_Registration_Team__c>();
        FBE_Deal_Registration_Team__c Drt = new FBE_Deal_Registration_Team__c();
        Drt.Deal_Registration__c = lstDeal[0].id;
        Drt.Access_level__c = 'Read';
        Drt.Role__c = 'AE';
        Drt.User__c = nonintegusers[0].id;
        lstdrt.add(Drt);
        Insert lstdrt;
        
        String dealSharingReason = Schema.Deal_Registration__Share.RowCause.Deal_Team_Sharing__c;
        Deal_Registration__Share  dealshare = new Deal_Registration__Share ();
        dealshare.RowCause = dealSharingReason;
        dealshare.parentid = lstDeal[0].id;
        dealshare.UserOrGroupId = lstuser.id;
        dealshare.AccessLevel = 'Edit';
        insert dealshare;
        
        
        Test.starttest();
        
        FBE_UpdateDealShareBatch Dealsharebatch = new FBE_UpdateDealShareBatch();
        FBE_DealHelper dh = new FBE_DealHelper();
        dh.createDealTeamMemberShare(lstdrt);
        Id batchId = Database.executeBatch(Dealsharebatch, 1); 
        
        Test.stoptest();
        
        AsyncApexJob job = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob WHERE ID =: batchId ];
        System.assertEquals('Completed', job.Status, 'Batch did not run');
        
    }
    static testmethod void FBE_UpdatesDeal(){
        
        List < User > nonintegusers = new List < User > ();
        list<Account> lstAcc = new list<Account>();
        list<Deal_Registration__c > lstDeal = new list<Deal_Registration__c >();
        nonintegusers = FBE_UtilityFactory_Test.createUser('System Administrator', 1, 'sys' ,null);
        
        User lstuser = FBE_UtilityFactory_Test.getIntegrationUser();
        System.runAs(lstuser){
            lstAcc = FBE_Test_Utility.createAccount(1);
            Insert lstAcc;
        }        
        
        lstDeal = FBE_Test_Utility.createDeal(1); 
        Insert lstDeal;
        
        List<FBE_Deal_Registration_Team__c> lstdrt = new list<FBE_Deal_Registration_Team__c>();
        FBE_Deal_Registration_Team__c Drt = new FBE_Deal_Registration_Team__c();
        Drt.Deal_Registration__c = lstDeal[0].id;
        Drt.Access_level__c = 'Read';
        Drt.Role__c = 'AE';
        Drt.User__c = nonintegusers[0].id;
        lstdrt.add(Drt);
        Insert lstdrt;
        
        String dealSharingReason = Schema.Deal_Registration__Share.RowCause.Deal_Team_Sharing__c;
        Deal_Registration__Share  dealshare = new Deal_Registration__Share ();
        dealshare.RowCause = dealSharingReason;
        dealshare.parentid = lstDeal[0].id;
        dealshare.UserOrGroupId = lstuser.id;
        dealshare.AccessLevel = 'Edit';
        insert dealshare;
        
        
        Test.starttest();
        FBE_UpdatesDealShareBatch dc = new FBE_UpdatesDealShareBatch();
        FBE_DealHelper dhs = new FBE_DealHelper();
        dhs.createDealTeamMemberShare(lstdrt); 
        Id batchIds = database.executebatch(dc,1);  
        Test.stoptest();
        AsyncApexJob job = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob WHERE ID =: batchIds ];
        System.assertEquals('Completed', job.Status, 'Batch did not run');
    }
    
}