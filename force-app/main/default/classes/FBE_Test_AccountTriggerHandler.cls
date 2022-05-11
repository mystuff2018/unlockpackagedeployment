/**************
 *@ Class Name        : FBE_Test_AccountTriggerHandler
 *@ Description       : This class is written to Cover Account Trigger handler functionality 
 *@ CreatedBy         : Deloitte Consulting
 *@ CreatedOn         : 04-10-2017
 *@ Modification Log  :                     
 ***************/
@isTest(seeAllData = false)
public without sharing class FBE_Test_AccountTriggerHandler {
    
    static TestMethod void TestAccountMemberAccountLevelAccess() {
         
        //List < User > lUsr = [Select Id from User where FBE_Integration_User__c = true];
        User lUsr = FBE_UtilityFactory_Test.getIntegrationUser();
        List < User > lUsrNonIntegration = FBE_UtilityFactory_Test.createUser('System Administrator', 2, 'ab',null);
        
        system.runAs(lUsr) {
            //Create an Account
            List < Account > lAcc = FBE_UtilityFactory_Test.createAccount(2,null);
            insert lAcc;
            system.assertNotEquals(null, lAcc[0].id, 'Null check');
            system.assertNotEquals(null, lAcc[1].id, 'Null check');
            
            //add Account team member to Accounts Created
            list<AccountTeamMember> accTeamMemberList = new list<AccountTeamMember>();
            accTeamMemberList.add(new AccountTeamMember(AccountAccessLevel='Read',UserId=lUsrNonIntegration[0].id,TeamMemberRole='SR',AccountId=lAcc[0].id));
            accTeamMemberList.add(new AccountTeamMember(AccountAccessLevel='Read',UserId=lUsrNonIntegration[1].id,TeamMemberRole='AE',AccountId=lAcc[0].id));
            
            insert accTeamMemberList;
            
            test.startTest();
            
                Account acc = [SELECT id,Name,FBE_Set_Account_Access_Level__c FROM Account where id =: lAcc[0].id];
                acc.FBE_Set_Account_Access_Level__c = true;
                update acc;
            
            FBE_AccountTriggerHandler acth = new FBE_AccountTriggerHandler(true,1);
            acth.onAfterUpdate(new List<Account>{acc});
			    
            test.stopTest();
           // system.assertEquals('Edit',[SELECT id , AccountAccessLevel FROM AccountTeamMember][0].AccountAccessLevel, 'Edit access');
        }
    }
}