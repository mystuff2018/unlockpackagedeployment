/**************
 *@ Class Name        : FBE_Test_SetDealExpiredBatch
 *@ Description       : Test class to create test data and test for FBE_Test_SetDealExpiredBatch. The test class has following methods :
                        1. A test data setup method to create Deal Registrations.
                        2. A test method to execute batch job for Deal Registration. The method validates Deal Registration with past Expiration Date are updated to Expired status
 *@ CreatedBy         : Deloitte Consulting
 *@ CreatedOn         : 12-11-2019
 *@ Modification Log  : Version 1.0 - [Abhishek Kawle] : Initially created script to create test data and test for FBE_Test_SetDealExpiredBatch APEX Class.
 ***************/
@isTest
private class FBE_Test_SetDealExpiredBatch {
    /**************
     * @MethodName    : setup
     * @Trigger       : -
     * @Description   : This method creates test data for Batch execution.
     ***************/
    @testSetup
    static void setup(){
        //List<User> lUser =  [Select Id from User where FBE_Integration_User__c = true];
        USer lUser = FBE_UtilityFactory_Test.getIntegrationUser();
        system.runAs(lUser){
            List<Deal_Registration__c> dealList = FBE_UtilityFactory_Test.createDeal(3);
            insert dealList;
            //System.debug('Deal List: '+dealList);
            for(Deal_Registration__c deal: dealList){
                deal.FBE_Expiration_Date__c = date.today() - 2;
            }
            
            update dealList;
        }
    }
    
    /**************
     * @MethodName    : testBatchExecution
     * @Trigger       : -
     * @Description   : This method invokes batch job and validates count of Account Team Members is equal to custom object count.
     ***************/ 
    static TestMethod void testBatchExecution(){
        Test.startTest();
        FBE_SetDealExpiredBatch batch = new FBE_SetDealExpiredBatch();
        database.executebatch(batch,2000);
        Test.stopTest();
        System.assertEquals(0, [Select count() from Deal_Registration__c where FBE_Deal_Registration_Status__c != 'Expired' AND FBE_Expiration_Date__c < :date.today()],'Deal Registration count');
        
    }
}