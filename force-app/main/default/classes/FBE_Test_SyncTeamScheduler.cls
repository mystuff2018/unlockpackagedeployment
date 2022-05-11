/**************
 *@ Class Name        : FBE_Test_SyncTeamScheduler
 *@ Description       : Test class to create test for FBE_SyncTeamScheduler. This test class covers below scenarios :
                        1. Test scheduled job parameters are set as per expectation by system
                        2. Test scheduled job logic when FBE_AccountTeamMember object has no records. Scheduled job should copy all records from AccountTeamMember object.
                        3. Test scheduled job logic when FBE_AccountTeamMember and AccountTeamMember object have distinct records. Scheduled job should sync records from AccountTeamMember Object.
 *@ CreatedBy         : Deloitte Consulting
 *@ CreatedOn         : 01-03-2019
 *@ Modification Log  : Version 1.0 - [Abhishek Kawle] : Initially created script to test for FBE_SyncTeamScheduler Apex Scheduled Job
                        Version 2.0 - 04/10/2019 - [Abhishek Kawle] : Commented rest of script as test class would only be used to verify Scheduler class - Batch job invocation.
						Version 3.0 - [Abhishek Kawle] 05/02/2020 : Commented code to evaluate Next run time of scheduler, since it will cause issues depending on when the scheduler test class is run.
 ***************/
@isTest(seeAllData=false)
public class FBE_Test_SyncTeamScheduler {
    /**************
     * @MethodName    : testScheduler
     * @Trigger       : -
     * @Description   : Test scheduled job parameters are set as per expectation by system
     ***************/
    static TestMethod void testScheduler(){
        Test.startTest();
        Datetime curTime = System.Now();
        String CRON_EXP = String.valueOf('0' + ' ' + '0' + ' ' + '0' + ' '  + String.valueOf(curTime.day()) +  ' ' + String.valueOf(curTime.month()) + ' '  + '? ' + String.valueOf(curTime.Year() +2));
        //Datetime newDate = curTime.addYears(2);
        //String nextRunTime = (String.valueOf(newDate));
        //String nextRunExp = nextRunTime.substringBefore(' ');
        //nextrunTime = nextRunExp + ' 00:00:00';
        
        String jobId = System.schedule('testSyncTeamScheduledApex', CRON_EXP, new FBE_SyncTeamScheduler());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                         FROM CronTrigger WHERE id= :jobId];
        
        //Verify CRON Expressions are same.
        System.assertEquals(CRON_EXP, ct.CronExpression,'Cron Expression');
        
        //Verify the Job has not run.
        System.assertEquals(0, ct.TimesTriggered,'Times triggered');
        
        //Verify the next time the job will run. 
        //System.assertEquals(nextrunTime, String.valueOf(ct.NextFireTime), 'Time check');
        
        Test.stopTest();
    }
    
/*    static TestMethod void testBatchExecution(){
        
        //Create test Accounts - this simulates one execute
        Datetime curTime = System.Now();
        String CRON_EXP = String.valueOf('0' + ' ' + '0' + ' ' + '0' + ' '  + String.valueOf(curTime.day()) +  ' ' + String.valueOf(curTime.month()) + ' '  + '? ' + String.valueOf(curTime.Year() +2));
        List<User> lUser =  [Select Id from User where FBE_Integration_User__c = true];
        List<User> lUserTeam = FBE_Test_Utility.createUser('System Administrator', 10, 'def');
        system.runAs(lUser[0]){
            List<Account> lAcc = FBE_Test_Utility.createAccount(20);
            insert lAcc;
            
            system.assertNotEquals(null, lAcc[0].id);
            
            List<AccountTeamMember> accTeamList = new List<AccountTeamMember>();
            for(integer j= 0; j<lAcc.size(); j++){
                for(integer k=0; k<lUserTeam.size(); k++){
                    accTeamList.add(new AccountTeamMember(AccountAccessLevel='Edit',UserId=lUserTeam[k].id,TeamMemberRole='AE',AccountId=lAcc[j].id));
                    //System.debug(accTeamList);               
                }
            }
            
            insert accTeamList;
            Test.startTest();
            String jobId = System.schedule('testSyncTeamScheduledApex', CRON_EXP, new FBE_SyncTeamScheduler());
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                              FROM CronTrigger WHERE id= :jobId];
            
            Test.stopTest();
            Integer accTeamMemCount,FBEaccTeamMemCount;
            accTeamMemCount = [SELECT COUNT() FROM AccountTeamMember];
            FBEaccTeamMemCount = [SELECT COUNT() FROM FBE_AccountTeamMember__c];
            System.assertEquals(accTeamMemCount, FBEaccTeamMemCount); 
            
        }
    } */
    
    /**************
     * @MethodName    : testSchedulerNoCustomTeamMembers
     * @Trigger       : -
     * @Description   : Test scheduled job logic when FBE_AccountTeamMember object has no records. Scheduled job should copy all records from AccountTeamMember object.
     ***************/
/*    static TestMethod void testSchedulerNoCustomTeamMembers(){
        
        String CRON_EXP = '0 0 0 3 9 ? 2022';
        
        //String jobId = System.schedule('testSyncTeamScheduledApex', CRON_EXP, new FBE_SyncTeamScheduler());
        List<User> lUser =  FBE_Test_Utility.createUser('System Administrator', 1, 'def');//[Select Id from User where Alias='akawl'];
        List<User> lUsrNonIntegration = FBE_Test_Utility.createUser('System Administrator', 2, 'ab');
        
        system.runAs(lUser[0]){
            Test.startTest();
            List<Account> lAcc = FBE_Test_Utility.createAccount(1);
            insert lAcc;
            
            system.assertNotEquals(null, lAcc[0].id);
            list<AccountTeamMember> accTeamMemberList = new list<AccountTeamMember>();
            accTeamMemberList.add(new AccountTeamMember(AccountAccessLevel='Read',UserId=lUsrNonIntegration[0].id,TeamMemberRole='AE',AccountId=lAcc[0].id));
            accTeamMemberList.add(new AccountTeamMember(AccountAccessLevel='Read',UserId=lUsrNonIntegration[1].id,TeamMemberRole='AE',AccountId=lAcc[0].id));
            insert accTeamMemberList;
            
            String jobId = System.schedule('testSyncTeamScheduledApex', CRON_EXP, new FBE_SyncTeamScheduler());
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                              FROM CronTrigger WHERE id= :jobId];
            
            Test.stopTest();
            Integer accTeamMemCount,FBEaccTeamMemCount;
            accTeamMemCount = [SELECT COUNT() FROM AccountTeamMember];
            FBEaccTeamMemCount = [SELECT COUNT() FROM FBE_AccountTeamMember__c];
            System.assertEquals(accTeamMemCount, FBEaccTeamMemCount); 
        }       
    }
    
    /**************
    * @MethodName    : testSchedulerWithCustomTeamMembers
    * @Trigger       : -
    * @Description   : Test comparator class logic when FBE_AccountTeamMember__c object has some records. 
    Test script verifies that account team member changes are inserted / deleted from Custom object (FBE_AccountTeamMember__c)
     ***************/
/*    static TestMethod void testSchedulerWithCustomTeamMembers(){
        
        String CRON_EXP = '0 0 0 3 9 ? 2022';
        
        //String jobId = System.schedule('testSyncTeamScheduledApex', CRON_EXP, new FBE_SyncTeamScheduler());
        List<User> lUser =  FBE_Test_Utility.createUser('System Administrator', 1, 'def');//[Select Id from User where Alias='akawl'];
        List<User> lUsrNonIntegration = FBE_Test_Utility.createUser('System Administrator', 2, 'ab');
        
        system.runAs(lUser[0]){
            Test.startTest();
            List<Account> lAcc = FBE_Test_Utility.createAccount(1);
            insert lAcc;
            
            system.assertNotEquals(null, lAcc[0].id);
            list<AccountTeamMember> accTeamMemberList = new list<AccountTeamMember>();
            accTeamMemberList.add(new AccountTeamMember(AccountAccessLevel='Read',UserId=lUsrNonIntegration[0].id,TeamMemberRole='AE',AccountId=lAcc[0].id));
            accTeamMemberList.add(new AccountTeamMember(AccountAccessLevel='Read',UserId=lUsrNonIntegration[1].id,TeamMemberRole='AE',AccountId=lAcc[0].id));
            accTeamMemberList.add(new AccountTeamMember(AccountAccessLevel='Read',UserId=lUser[0].id,TeamMemberRole='AE',AccountId=lAcc[0].id));
            insert accTeamMemberList;
                                   
            //Delete a Team member from AccountTeamMember Object and verify it is delete from FBE_AccountTeamMember__c
            List<AccountTeamMember> accTeamMemToDelete = [SELECT Id from AccountTeamMember WHERE CreatedDate = TODAY AND CreatedById =:lUser[0].Id];
            
            //Insert a Team member into FBE_AccountTeamMember__c and remove it from AccountTeamMember object. Test whether it is removed from FBE_AccountTeamMember__c
            List<FBE_AccountTeamMember__c> FBEaccTeamMem = new list<FBE_AccountTeamMember__c>();
            FBEaccTeamMem.add(new FBE_AccountTeamMember__c(FBE_Account_Team_Member_Id__c = accTeamMemToDelete[0].Id, FBE_Account_Access_Level__c = 'Read', FBE_Account_Id__c= lAcc[0].id, FBE_Team_Member_Role__c='AE', FBE_User_Id__c = lUsrNonIntegration[0].id));
            FBEaccTeamMem.add(new FBE_AccountTeamMember__c(FBE_Account_Team_Member_Id__c = accTeamMemToDelete[1].Id, FBE_Account_Access_Level__c = 'Read', FBE_Account_Id__c= lAcc[0].id, FBE_Team_Member_Role__c='AE', FBE_User_Id__c = lUsrNonIntegration[1].id));
            insert FBEaccTeamMem;
            
            try{
                delete accTeamMemToDelete[0];
            }
            catch(Exception e){
                System.debug(e.getMessage());
            }
            
            String jobId = System.schedule('testSyncTeamScheduledApex', CRON_EXP, new FBE_SyncTeamScheduler());
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                              FROM CronTrigger WHERE id= :jobId];
            Test.stopTest();
            Integer accTeamMemCount,FBEaccTeamMemCount;
            accTeamMemCount = [SELECT COUNT() FROM AccountTeamMember WHERE CreatedDate = TODAY AND CreatedById =:lUser[0].Id];
            FBEaccTeamMemCount = [SELECT COUNT() FROM FBE_AccountTeamMember__c];
            System.assertEquals(accTeamMemCount, FBEaccTeamMemCount);       
        }       
    } */
}