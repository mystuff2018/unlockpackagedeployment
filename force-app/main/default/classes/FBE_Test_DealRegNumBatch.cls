/**************
 *@ Class Name        : FBE_Test_DealRegNumBatch
 *@ Description       : Test class to create test data and test for FBE_DealRegNumBatch. The test class has following methods :
                        1. A test data setup method to create Deal Registrations.
                        2. A test method to execute batch job. The method validates Deal Registration > Deal Reg Num field is updated with Deal Reg #.
 *@ CreatedBy         : Deloitte Consulting
 *@ CreatedOn         : 08-28-2019
 *@ Modification Log  : Version 1.0 - [Abhishek Kawle] : Initially created script to create test data and test for FBE_DealRegNumBatch APEX Class.
 ***************/
@isTest
private class FBE_Test_DealRegNumBatch {
    /**************
     * @MethodName    : setup
     * @Trigger       : -
     * @Description   : This method creates test data for Batch execution.
     ***************/
    @testSetup
    static void setup(){
        //List<User> lUser =  [Select Id from User where FBE_Integration_User__c = true];
        User lUser = FBE_UtilityFactory_Test.getIntegrationUser();
        system.runAs(lUser){
            List<Deal_Registration__c> dealList = new List<Deal_Registration__c>();
            dealList = FBE_UtilityFactory_Test.createDeal(5);
            insert dealList;
            
            List<Deal_Registration__c> dealListUpdate = new List<Deal_Registration__c>();
            for(Deal_Registration__c deal: dealList){
                deal.FBE_Deal_Reg_Num__c = null;
                deal.FBE_Siebel_Deal_Id__c = null;
                dealListUpdate.add(deal);
            }
            update dealListUpdate;
            system.assertNotEquals(null, dealList.size(),'Null check');
        }
    }
    
    /**************
     * @MethodName    : testBatchExecution
     * @Trigger       : -
     * @Description   : This method invokes batch job and validates count of Account Team Members is equal to custom object count.
     ***************/    
    static TestMethod void testBatchExecution(){
        Test.startTest();
        FBE_DealRegNumBatch obj = new FBE_DealRegNumBatch();
        Id batchId = database.executeBatch(obj);
        Test.stopTest();
        
        System.assertEquals(5, [Select Count() from Deal_Registration__c where FBE_Deal_Reg_Num__c != null],'Count check');
        
    }
}