/**************
 *@ Class Name        : FBE_Test_SyncTeamComparator
 *@ Description       : Test class to create test for FBE_Test_SyncTeamComparator. This test class covers below scenarios :
                        1. Test comparator class when FBE_AccountTeamMember object has no records. It should copy all records from AccountTeamMember object.
                        2. Test comparator class logic when FBE_AccountTeamMember and AccountTeamMember object have distinct records. It should sync records from AccountTeamMember Object.
 *@ CreatedBy         : Deloitte Consulting
 *@ CreatedOn         : 04-10-2019
 *@ Modification Log  : Version 1.0 - [Abhishek Kawle] : Initially created script to test for FBE_Test_SyncTeamComparator Apex Class
 ***************/
@isTest(seeAllData = false)
public class FBE_Test_SyncTeamComparator {
/**************
* @MethodName    : testSchedulerNoCustomTeamMembers
* @Trigger       : -
* @Description   : Test comparator class logic when FBE_AccountTeamMember object has no records. Class should copy all records from AccountTeamMember object.
***************/
    static TestMethod void testSchedulerNoCustomTeamMembers(){
        //List<User> lUser =  [Select Id from User where FBE_Integration_User__c = true];
        User lUser = FBE_UtilityFactory_Test.getIntegrationUser();
        List<User> lUsrNonIntegration = FBE_UtilityFactory_Test.createUser('System Administrator', 2, 'ab',null);
        Set<Id> accIdSet = new Set<Id>();
        
        system.runAs(lUser){
            Test.startTest();
            List<Account> lAcc = FBE_UtilityFactory_Test.createAccount(1,null);
            insert lAcc;
            
            system.assertNotEquals(null, lAcc[0].id, 'Null check');
            list<AccountTeamMember> accTeamMemberList = new list<AccountTeamMember>();
            accTeamMemberList.add(new AccountTeamMember(AccountAccessLevel='Read',UserId=lUsrNonIntegration[0].id,TeamMemberRole='AE',AccountId=lAcc[0].id));
            accTeamMemberList.add(new AccountTeamMember(AccountAccessLevel='Read',UserId=lUsrNonIntegration[1].id,TeamMemberRole='AE',AccountId=lAcc[0].id));
            insert accTeamMemberList;
            
            for(Account acc : lAcc){
                accIdSet.add(acc.Id);
            }
            
            try{
                FBE_SyncTeamComparator obj = new FBE_SyncTeamComparator();
                obj.compareTeamMembers(accIdSet); 
                FBE_SyncAccountToDealRegTeams dealHandler = new FBE_SyncAccountToDealRegTeams();
                dealHandler.syncDealRegTeams(accIdSet);
            }

            catch(Exception e){
                System.debug(e.getMessage());
            }
            
            Test.stopTest();
            Integer accTeamMemCount,FBEaccTeamMemCount;
            accTeamMemCount = [SELECT COUNT() FROM AccountTeamMember];
            FBEaccTeamMemCount = [SELECT COUNT() FROM FBE_AccountTeamMember__c];
            System.assertEquals(accTeamMemCount, FBEaccTeamMemCount, 'Team count check'); 
        }       
    }
    
/**************
* @MethodName    : testSchedulerWithCustomTeamMembers
* @Trigger       : -
* @Description   : Test comparator class logic when FBE_AccountTeamMember__c object has some records. 
                   Test script verifies that account team member changes are inserted / deleted from Custom object (FBE_AccountTeamMember__c)
***************/
    static TestMethod void testSchedulerWithCustomTeamMembers(){
        
        //List<User> lUser =  [Select Id from User where FBE_Integration_User__c = true];
        User lUser  = FBE_UtilityFactory_Test.getIntegrationUser();
        List<User> lUsrNonIntegration = FBE_UtilityFactory_Test.createUser('System Administrator', 2, 'ab',null);
        Set<Id> accIdSet = new Set<Id>();
        
        system.runAs(lUser){
            Test.startTest();
            List<Account> lAcc = FBE_UtilityFactory_Test.createAccount(1,null);
            insert lAcc;
            
            system.assertNotEquals(null, lAcc[0].id, 'Null check');
            list<AccountTeamMember> accTeamMemberList = new list<AccountTeamMember>();
            accTeamMemberList.add(new AccountTeamMember(AccountAccessLevel='Read',UserId=lUsrNonIntegration[0].id,TeamMemberRole='AE',AccountId=lAcc[0].id));
            accTeamMemberList.add(new AccountTeamMember(AccountAccessLevel='Read',UserId=lUsrNonIntegration[1].id,TeamMemberRole='AE',AccountId=lAcc[0].id));
            accTeamMemberList.add(new AccountTeamMember(AccountAccessLevel='Read',UserId=lUser.id,TeamMemberRole='AE',AccountId=lAcc[0].id));
            insert accTeamMemberList;
            
            //Delete a Team member from AccountTeamMember Object and verify it is delete from FBE_AccountTeamMember__c
            List<AccountTeamMember> accTeamMemToDelete = [SELECT Id from AccountTeamMember WHERE CreatedDate = TODAY AND CreatedById =:lUser.Id];
            
            //Insert a Team member into FBE_AccountTeamMember__c and remove it from AccountTeamMember object. Test whether it is removed from FBE_AccountTeamMember__c
            List<FBE_AccountTeamMember__c> FBEaccTeamMem = new list<FBE_AccountTeamMember__c>();
            FBEaccTeamMem.add(new FBE_AccountTeamMember__c(FBE_Account_Team_Member_Id__c = accTeamMemToDelete[0].Id, FBE_Account_Access_Level__c = 'Read', FBE_Account_Id__c= lAcc[0].id, FBE_Team_Member_Role__c='AE', FBE_User_Id__c = lUsrNonIntegration[0].id));
            FBEaccTeamMem.add(new FBE_AccountTeamMember__c(FBE_Account_Team_Member_Id__c = accTeamMemToDelete[1].Id, FBE_Account_Access_Level__c = 'Read', FBE_Account_Id__c= lAcc[0].id, FBE_Team_Member_Role__c='AE', FBE_User_Id__c = lUsrNonIntegration[1].id));
            insert FBEaccTeamMem;
            
            for(Account acc : lAcc){
                accIdSet.add(acc.Id);
            }
            
            try{
                delete accTeamMemToDelete[0];
                FBE_SyncTeamComparator obj = new FBE_SyncTeamComparator();
                obj.compareTeamMembers(accIdSet);
                
            }
            catch(Exception e){
                System.debug(e.getMessage());
            }
            
            Test.stopTest();
            Integer accTeamMemCount,FBEaccTeamMemCount;
            accTeamMemCount = [SELECT COUNT() FROM AccountTeamMember WHERE CreatedDate = TODAY AND CreatedById =:lUser.Id];
            FBEaccTeamMemCount = [SELECT COUNT() FROM FBE_AccountTeamMember__c];
            System.assertEquals(accTeamMemCount, FBEaccTeamMemCount,'Team count check');       
        }       
    }
}