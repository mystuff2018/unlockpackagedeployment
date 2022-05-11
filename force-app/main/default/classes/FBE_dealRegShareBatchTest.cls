/**************
 * @ Class Name        : FBE_dealRegShareBatchTest
 * @ Description       : This is a test class for FBE_dealRegShareBatch.
 *                       Created as part of TFS Defect #8642038
 * @ CreatedBy         : Deloitte Consulting
 * @ CreatedOn         : 05-21-2020
 * @ Modification Log  : 05-21-2020 [Abhishek Kawle] : Created New for Defect #8642038
*********/
@isTest
private class FBE_dealRegShareBatchTest {
     
    @testSetup
    static void Setup(){
        //create new users
        List<User> users = FBE_UtilityFactory_Test.createUser('System Administrator', 200, 'abc',null);
        
        // Create new Deal. 
        List<Deal_Registration__c> d = FBE_UtilityFactory_Test.createDeal(1);
        insert d;
        
        //Insert a Deal Team Member
        FBE_Deal_Registration_Team__c dt = new FBE_Deal_Registration_Team__c(); 
        dt.Deal_Registration__c =  d[0].Id;
        dt.User__c =  users[0].Id;
        dt.Access_level__c = 'Read'; 
        insert dt; 
        
        //create Deal Sharing records with Manual row cause
        List<Deal_Registration__Share> dealTeamShareInsert = new List<Deal_Registration__Share>();
        for(Integer i=0;i<200;i++){
            Deal_Registration__Share ds = new Deal_Registration__Share();
            ds.ParentId = d[0].Id;
            ds.AccessLevel = 'Edit';
            ds.UserOrGroupId = users[i].Id;
            ds.RowCause = 'Manual';              
            
            dealTeamShareInsert.add(ds);
        }
        insert dealTeamShareInsert;
    }
    
    @isTest
    static void testBatch(){
        Test.startTest();
        
        FBE_dealRegShareBatch b = new FBE_dealRegShareBatch();
        b.query = 'Select Id from Deal_Registration__c';
        Id batchId = Database.executeBatch(b, 1);
        
        Test.stopTest();
        System.assertEquals(0,[Select Id from Deal_Registration__Share WHERE RowCause = 'Manual'].size());
    }
}