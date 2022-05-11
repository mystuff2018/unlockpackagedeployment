/**************
 *@ Class Name        : FBE_Test_SyncTeamBatch
 *@ Description       : Test class to create test data and test for FBE_Test_SyncTeamBatch. The test class has following methods :
                        1. A test data setup method to create Accounts, Users and Account Team Members.
                        2. A test method to execute batch job for Accounts. The method validates Account Team Members are compared and copied into custom object.
 *@ CreatedBy         : Deloitte Consulting
 *@ CreatedOn         : 04-10-2019
 *@ Modification Log  : Version 1.0 - [Abhishek Kawle] : Initially created script to create test data and test for FBE_Test_SyncTeamBatch APEX Class.
 ***************/
@isTest
private class FBE_Test_SyncTeamBatch { 
    /**************
     * @MethodName    : setup
     * @Trigger       : -
     * @Description   : This method creates test data for Batch execution.
     ***************/
    @testSetup
    static void setup(){
        Integer batchSize = Integer.valueOf(Label.Sync_Team_Batch_Size);
        Integer recordCount = batchsize - 5;
        
        if(recordCount == 0 || recordCount < 0){
            recordCount = 1;
        }
        
        //List<User> lUser =  [Select Id from User where FBE_Integration_User__c = true];
        User lUser = FBE_UtilityFactory_Test.getIntegrationUser();
        List<User> lUserTeam = FBE_UtilityFactory_Test.createUser('System Administrator', 10, 'def',null);
        List<AccountTeamMember> accTeamList = new List<AccountTeamMember>();    
        
        system.runAs(lUser){
            List<Account> lAcc = FBE_UtilityFactory_Test.createAccount(recordCount,null);
            insert lAcc;   
            
            system.assertNotEquals(null, lAcc[0].id, 'Null check');
            
            for(integer j= 0; j<lAcc.size(); j++){
                for(integer k=0; k<lUserTeam.size(); k++){
                    accTeamList.add(new AccountTeamMember(AccountAccessLevel='Edit',UserId=lUserTeam[k].id,TeamMemberRole='AE',AccountId=lAcc[j].id));
                    //System.debug(accTeamList);               
                }
            }
        }
        
        insert accTeamList;
    }
    
    /**************
     * @MethodName    : testBatchExecution
     * @Trigger       : -
     * @Description   : This method invokes batch job and validates count of Account Team Members is equal to custom object count.
     ***************/    
    static TestMethod void testBatchExecution(){
        Test.startTest();
        
        Integer batchSize = Integer.valueOf(Label.Sync_Team_Batch_Size);

        FBE_SyncTeamBatch obj = new FBE_SyncTeamBatch();
        obj.query = 'SELECT Id FROM Account';
        Id batchId = database.executeBatch(obj, batchSize);
        
        Test.stopTest();
        
        Integer accTeamMemCount, FBEaccTeamMemCount;
        accTeamMemCount = [SELECT COUNT() FROM AccountTeamMember];
        FBEaccTeamMemCount = [SELECT COUNT() FROM FBE_AccountTeamMember__c];    
        System.assertEquals(accTeamMemCount, FBEaccTeamMemCount, 'Team count check');
    }
}