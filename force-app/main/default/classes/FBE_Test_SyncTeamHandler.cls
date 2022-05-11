/**************
 *@ Class Name        : FBE_Test_SyncTeamHandler
 *@ Description       : Test class to create test data and test for FBE_SyncTeamHandler. The test class covers below scenarios :
                        1. New Account Team Member is added to Account and FBE_SyncTeamHandler Apex Class is called, team member is synchronized to related Open Opportunities
                        2. New Opportunity Team Member is added manually (Assigned by User Flag = TRUE) and FBE_SyncTeamHandler Apex Class is called, Opportunity Team Member is retained
                           as it has been added by User
                        3. Existing Opportunity Team member is no longer a part of Account Team and FBE_SyncTeamHandler is called, Opportunity Team Member is overwritten
 *@ CreatedBy         : Deloitte Consulting
 *@ CreatedOn         : 01-03-2019
 *@ Modification Log  : Version 1.0 - [Abhishek Kawle] : Initially created script to create test data and test for FBE_SyncTeamHandler Apex Class
 ***************/

@isTest(seeAllData = false)
public class FBE_Test_SyncTeamHandler { 
    /**************
     * @MethodName    : testAccountOptyTeamSync
     * @Trigger       : -
     * @Description   : This method covers scenario in which New Account Team Member is added to Account and team member is synchronized to related Open Opportunities
     ***************/
    static TestMethod void testAccountOptyTeamSync(){
        List<User> lUser =  [Select Id from User where FBE_Integration_User__c = true];
        List<User> lUserTeam = FBE_UtilityFactory_Test.createUser('System Administrator', 2, 'cd',null);//[Select Id from User where Alias IN('vredd','ydawane')];
        List<User> lUsrNonIntegration = FBE_UtilityFactory_Test.createUser('System Administrator', 2, 'ab',null);
        set<Id> accIdSet = new set<Id>();
        set<Id> oppIdSet = new set<Id>();
        system.runAs(lUser[0]){
            Test.startTest();
            //Setup Test Data - Accounts
            List<Account> lAcc = FBE_UtilityFactory_Test.createAccount(2,null);          
            
            insert lAcc;
            for(Account acc : [SELECT Id FROM Account WHERE CreatedDate = TODAY AND CreatedById =: lUser[0].Id]){
                accIdSet.add(acc.Id);
            }
            
            system.assertNotEquals(null, lAcc[0].id, 'Null check');
            system.assertNotEquals(null, lAcc[1].id, 'Null check');
            
            //Adding Team Member to Above Accounts
            list<AccountTeamMember> accTeamMemberList = new list<AccountTeamMember>();
            accTeamMemberList.add(new AccountTeamMember(AccountAccessLevel='Read',UserId=lUsrNonIntegration[0].id,TeamMemberRole='AE',AccountId=lAcc[0].id));
            accTeamMemberList.add(new AccountTeamMember(AccountAccessLevel='Read',UserId=lUsrNonIntegration[1].id,TeamMemberRole='AE',AccountId=lAcc[1].id));
            insert accTeamMemberList;
            
            //Setup Test Data - Opportunities
            List<Opportunity> lOpp1 = FBE_UtilityFactory_Test.createOpportunity(2, lAcc[0].id,null,null,null,null,null);
            insert lOpp1;
            Opportunity opp = [SELECT Id,Name, AccountId, FBE_Distributor__c FROM Opportunity WHERE Id =:lOpp1[1].Id];
            opp.FBE_Distributor__c = lAcc[1].id; //Add a Distributor Account To Opportunity
            update opp;
            
            List<AccountTeamMember> accTeamList_1 = new List<AccountTeamMember>();
            accTeamList_1.add(new AccountTeamMember(AccountAccessLevel='Read',UserId=lUserTeam[0].id,TeamMemberRole='SR',AccountId=lAcc[0].id));
            accTeamList_1.add(new AccountTeamMember(AccountAccessLevel='Read',UserId=lUserTeam[1].id,TeamMemberRole='SR',AccountId=lAcc[1].id));
            insert accTeamList_1;
            
            try{
                FBE_SyncTeamHandler handler = new FBE_SyncTeamHandler();
                handler.syncAccountTeam(accIdSet);
            }
            catch(Exception e){
                system.debug(e.getMessage());
            }
            
            //Compare Team Member Counts for Accounts And Opportunities. They should be same.
            Integer oppTeamMemCount,accTeamMemCount;            
            oppTeamMemCount = [SELECT COUNT() FROM OpportunityTeamMember WHERE OpportunityId =:lOpp1[0].Id];
            accTeamMemCount = [SELECT COUNT() FROM AccountTeamMember WHERE AccountId =:lAcc[0].Id];
            System.assertEquals(accTeamMemCount, oppTeamMemCount, 'Count check for sysncing team members');

            oppTeamMemCount = 0;
            accTeamMemCount = 0;
            oppTeamMemCount = [SELECT COUNT() FROM OpportunityTeamMember WHERE OpportunityId =:lOpp1[1].Id];
            accTeamMemCount = [SELECT COUNT() FROM AccountTeamMember WHERE AccountId =:accIdSet];
            System.assertEquals(accTeamMemCount, oppTeamMemCount, 'Count check for sysncing team members'); 
            Test.stopTest();
        }
    }
    
    /**************
     * @MethodName    : testOptySyncMemberRetention
     * @Trigger       : -
     * @Description   : This method covers scenario in which New Opportunity Team Member is added manually (Assigned by User Flag = TRUE), Opportunity Team Member is retained
                        as it has been added by User
     ***************/    
    static TestMethod void testOptySyncMemberRetention(){
        List<User> lUser =  [Select Id from User where FBE_Integration_User__c = true];
        List<User> lUserTeam = FBE_UtilityFactory_Test.createUser('System Administrator', 2, 'cd',null);//[Select Id from User where Alias IN('vredd','ydawane')];
        List<User> lUsrNonIntegration = FBE_UtilityFactory_Test.createUser('System Administrator', 2, 'ab',null);
        set<Id> accIdSet = new set<Id>();
        set<Id> oppIdSet = new set<Id>();
        system.runAs(lUser[0]){
            Test.startTest();
            //Setup Test Data - Accounts
            List<Account> lAcc = FBE_UtilityFactory_Test.createAccount(2,null);
            
            insert lAcc;
            for(Account acc : [SELECT Id FROM Account WHERE CreatedDate = TODAY AND CreatedById =: lUser[0].Id]){
                accIdSet.add(acc.Id);
            }
            system.assertNotEquals(null, lAcc[0].id, 'Null check');
            system.assertNotEquals(null, lAcc[1].id, 'Null check');
            
            //Adding Team Member to Above Accounts
            list<AccountTeamMember> accTeamMemberList = new list<AccountTeamMember>();
            accTeamMemberList.add(new AccountTeamMember(AccountAccessLevel='Read',UserId=lUsrNonIntegration[0].id,TeamMemberRole='AE',AccountId=lAcc[0].id));
            accTeamMemberList.add(new AccountTeamMember(AccountAccessLevel='Read',UserId=lUserTeam[0].id,TeamMemberRole='SR',AccountId=lAcc[0].id));
            accTeamMemberList.add(new AccountTeamMember(AccountAccessLevel='Read',UserId=lUsrNonIntegration[1].id,TeamMemberRole='AE',AccountId=lAcc[1].id));
            insert accTeamMemberList;
            
            //Setup Test Data - Opportunities
            List<Opportunity> lOpp1 = FBE_UtilityFactory_Test.createOpportunity(2, lAcc[0].id,null,null,null,null,null);
            insert lOpp1;
            Opportunity opp = [SELECT Id,Name, AccountId, FBE_Distributor__c FROM Opportunity WHERE Id =:lOpp1[1].Id];
            opp.FBE_Distributor__c = lAcc[1].id; //Add a Distributor Account To Opportunity
            update opp;
            
            //Insert an Opportunity Team Member with Assigned By User Flag = TRUE. Verify the team Member is retained in Opportunity Team
            OpportunityTeamMember OptyTeamMem = new OpportunityTeamMember();        
            OptyTeamMem.OpportunityId = lOpp1[1].id;
            OptyTeamMem.UserId = lUserTeam[1].id;
            OptyTeamMem.TeamMemberRole = 'SR';
            OptyTeamMem.OpportunityAccessLevel = 'Edit';
            OptyTeamMem.FBE_Assigned_By_User__c = true;
            insert OptyTeamMem; 
            
            try{
                FBE_SyncTeamHandler handler = new FBE_SyncTeamHandler();
                handler.syncAccountTeam(accIdSet);
            }
            catch(Exception e){
                system.debug(e.getMessage());
            }
            
            //Compare Team Member Counts for Accounts And Opportunities. They should be same.
            Integer oppTeamMemCount,accTeamMemCount;            
            oppTeamMemCount = [SELECT COUNT() FROM OpportunityTeamMember WHERE OpportunityId =:lOpp1[0].Id];
            accTeamMemCount = [SELECT COUNT() FROM AccountTeamMember WHERE AccountId =:lAcc[0].Id];
            System.assertEquals(accTeamMemCount, oppTeamMemCount, 'Count check for sysncing team members');

            oppTeamMemCount = 0;
            accTeamMemCount = 0;
            oppTeamMemCount = [SELECT COUNT() FROM OpportunityTeamMember WHERE OpportunityId =:lOpp1[1].Id];
            accTeamMemCount = [SELECT COUNT() FROM AccountTeamMember WHERE AccountId =:accIdSet];
            System.assertEquals(accTeamMemCount+1, oppTeamMemCount, 'Count check for sysncing team members'); 
            Test.stopTest();
        }
    }

    /**************
     * @MethodName    : testOptySyncMemberDeletion
     * @Trigger       : -
     * @Description   : This method covers scenario in which Existing Opportunity Team member is no longer a part of Account Team, Opportunity Team Member is overwritten
     ***************/      
    static TestMethod void testOptySyncMemberDeletion(){
        List<User> lUser =  [Select Id from User where FBE_Integration_User__c = true];
        List<User> lUserTeam = FBE_UtilityFactory_Test.createUser('System Administrator', 2, 'cd',null);//[Select Id from User where Alias IN('vredd','ydawane')];
        List<User> lUsrNonIntegration = FBE_UtilityFactory_Test.createUser('System Administrator', 2, 'ab',null);
        set<Id> accIdSet = new set<Id>();
        set<Id> oppIdSet = new set<Id>();
        system.runAs(lUser[0]){
            Test.startTest();
            //Setup Test Data - Accounts
            List<Account> lAcc = FBE_UtilityFactory_Test.createAccount(2,null);
            
            insert lAcc;
            for(Account acc : [SELECT Id FROM Account WHERE CreatedDate = TODAY AND CreatedById =: lUser[0].Id]){
                accIdSet.add(acc.Id);
            }
            system.assertNotEquals(null, lAcc[0].id, 'Null check');
            system.assertNotEquals(null, lAcc[1].id, 'Null check');
            
            //Adding Team Member to Above Accounts
            list<AccountTeamMember> accTeamMemberList = new list<AccountTeamMember>();
            accTeamMemberList.add(new AccountTeamMember(AccountAccessLevel='Read',UserId=lUsrNonIntegration[0].id,TeamMemberRole='AE',AccountId=lAcc[0].id));
            accTeamMemberList.add(new AccountTeamMember(AccountAccessLevel='Read',UserId=lUserTeam[0].id,TeamMemberRole='SR',AccountId=lAcc[0].id));
            accTeamMemberList.add(new AccountTeamMember(AccountAccessLevel='Read',UserId=lUsrNonIntegration[1].id,TeamMemberRole='AE',AccountId=lAcc[1].id));
            insert accTeamMemberList;
            
            //Setup Test Data - Opportunities
            List<Opportunity> lOpp1 = FBE_UtilityFactory_Test.createOpportunity(2, lAcc[0].id,null,null,null,null,null);
            insert lOpp1;
            Opportunity opp = [SELECT Id,Name, AccountId, FBE_Distributor__c FROM Opportunity WHERE Id =:lOpp1[1].Id];
            opp.FBE_Distributor__c = lAcc[1].id; //Add a Distributor Account To Opportunity
            update opp;
            
            //Insert an Opportunity Team Member with Assigned By User Flag = False. Verify the team Member is deleted from Opportunity Team
            OpportunityTeamMember OptyTeamMem = new OpportunityTeamMember();        
            OptyTeamMem.OpportunityId = lOpp1[1].id;
            OptyTeamMem.UserId = lUserTeam[1].id;
            OptyTeamMem.TeamMemberRole = 'SR';
            OptyTeamMem.OpportunityAccessLevel = 'Edit';
            OptyTeamMem.FBE_Assigned_By_User__c = false;
            insert OptyTeamMem;
            
            try{
                FBE_SyncTeamHandler handler = new FBE_SyncTeamHandler();
                handler.syncAccountTeam(accIdSet);
            }
            catch(Exception e){
                system.debug(e.getMessage());
            }
            
            //Compare Team Member Counts for Accounts And Opportunities. Member with Assigned By User Flag = FALSE should be deleted from Opportunity Team.
            Integer oppTeamMemCount,accTeamMemCount;            
            oppTeamMemCount = [SELECT COUNT() FROM OpportunityTeamMember WHERE OpportunityId =:lOpp1[0].Id];
            accTeamMemCount = [SELECT COUNT() FROM AccountTeamMember WHERE AccountId =:lAcc[0].Id];
            System.assertEquals(accTeamMemCount, oppTeamMemCount, 'Count check for sysncing team members');

            oppTeamMemCount = 0;
            accTeamMemCount = 0;
            oppTeamMemCount = [SELECT COUNT() FROM OpportunityTeamMember WHERE OpportunityId =:lOpp1[1].Id];
            accTeamMemCount = [SELECT COUNT() FROM AccountTeamMember WHERE AccountId =:accIdSet];
            System.assertEquals(accTeamMemCount, oppTeamMemCount, 'Count check for sysncing team members'); 
            Test.stopTest();
        }
    }
}