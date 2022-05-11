/**************
 *@ Class Name        : FBE_Test_UnlockLockOptyRecord
 *@ Description       : Test class to create test data and test for FBE_UnlockOptyRecord. The test class covers below scenarios :
                        1. Create an Opportunity record and test Approval unlocking. Method first programmatically locks the record using class FBE_LockOptyRecord.
                           Assert opportunity record is unlocked.
                        2. Create an Opportunity record and test error handling in FBE_UnlockOptyRecord APEX Class
 *@ CreatedBy         : Deloitte Consulting
 *@ CreatedOn         : 07-29-2019
 *@ Modification Log  : Version 1.0 - [Abhishek Kawle] : Initially created script to create test data and test for FBE_UnlockOptyRecord Apex Class
 ***************/
@isTest(seeAllData = false)
public class FBE_Test_UnlockLockOptyRecord {
        /**************
     * @MethodName    : testUnlockOptyRecordSuccess
     * @Trigger       : -
     * @Description   : This method asserts the Opportunity is unlocked using Approval Class.
     ***************/
    static TestMethod void testUnlockOptyRecordSuccess() {
        User lUser =  FBE_UtilityFactory_Test.getIntegrationUser();
        set<Id> accIdSet = new set<Id>();
        set<Id> oppIdSet = new set<Id>();
        Id optyId;
        system.runAs(lUser){ 
            Test.startTest();
            
            //Setup Test Data - Accounts
            List<Account> lAcc = FBE_UtilityFactory_Test.createAccount(1, null);          
            insert lAcc;
            for(Account acc : [SELECT Id FROM Account WHERE CreatedDate = TODAY AND CreatedById =: lUser.Id]){
                accIdSet.add(acc.Id);
            }
            system.assertNotEquals(null, lAcc[0].id,'Null check');
            
            //Setup Test Data - Opportunities
            List<Opportunity> lOpp1 = FBE_UtilityFactory_Test.createOpportunity(1, lAcc[0].id, null, null, null, null, null);
            insert lOpp1;
            
            system.assertNotEquals(null, lOpp1[0].id,'Null check');
            optyId = lOpp1[0].id;
            try{
                FBE_LockOptyRecord.lockOpty(lOpp1) ; 
                FBE_UnlockOptyRecord.unlockOpty(lOpp1) ; 
            }
            catch(Exception e){
                system.debug(e.getMessage());
            }
            
            System.assertEquals(false, Approval.isLocked(optyId),'Null check');
            Test.stopTest();
        }
    }
   
        /**************
        * @MethodName    : testUnlockOptyRecordError
        * @Trigger       : -
        * @Description   : This method tests error handling code in FBE_UnlockOptyRecord - unlockOpty method.
        ***************/    
        static TestMethod void testUnlockOptyRecordError() {
        List<User> lUser =  [Select Id from User where FBE_Integration_User__c = true];
        set<Id> accIdSet = new set<Id>();
        set<Id> oppIdSet = new set<Id>();
        Id optyId;
        system.runAs(lUser[0]){ 
            Test.startTest();
            
            //Setup Test Data - Accounts
            List<Account> lAcc = FBE_Test_Utility.createAccount(1);          
            insert lAcc;
            for(Account acc : [SELECT Id FROM Account WHERE CreatedDate = TODAY AND CreatedById =: lUser[0].Id]){
                accIdSet.add(acc.Id);
            }
            system.assertNotEquals(null, lAcc[0].id,'Null check');
            
            //Setup Test Data - Opportunities
            List<Opportunity> lOpp1 = FBE_Test_Utility.createOpportunity(1, lAcc[0].id);
            insert lOpp1;
            
            system.assertNotEquals(null, lOpp1[0].id,'Null check');
            optyId = lOpp1[0].id;
            lOpp1[0].id = '006r0000002bMp7AAD'; //Dummy Opportunity Id so that FBE_UnlockOptyRecord errors out in Locking step.
            
            try{
                FBE_UnlockOptyRecord.unlockOpty(lOpp1); 
            }
            catch(Exception e){
                system.debug(e.getMessage());
            }
            
            System.assertEquals(false, Approval.isLocked(optyId),'Approval Locked');
            Test.stopTest();
        }
    }
}