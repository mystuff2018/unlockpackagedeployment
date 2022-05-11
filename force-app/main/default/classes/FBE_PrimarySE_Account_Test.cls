@isTest
public class FBE_PrimarySE_Account_Test {
    @isTest
    Public Static void testData(){
        /*
        List < User > lUsr = [Select Id, ManagerID from User where FBE_Integration_User__c = true limit 1];
        lUsr[0].ManagerId = Userinfo.getUserId();
        lUsr[0].EmployeeNumber = '123';
        update lUsr[0];
    */
        USer lUsr = FBE_UtilityFactory_Test.getIntegrationUser();
        List<ID> usId = new List<Id>();
        List < User > lUsrNonIntegration = FBE_UtilityFactory_Test.createUser('System Administrator', 4, 'ab',null);
        
        for(user us : lUsrNonIntegration){
            usId.add(us.Id);
        }
        
        List < Account > lAcc = FBE_UtilityFactory_Test.createAccount(3,null);
        system.runAs(lUsr){
            lAcc[0].FBE_AE_ISR__c = lUsr.Id;
            lAcc[0].FBE_Partner_Type__c = 'Distributor';
            lAcc[1].FBE_Partner_Type__c ='System Integrator';
            //lAcc[2].
            
            insert lAcc;
            //List < Account > accnt = [select id from account];
            System.debug('inside profile user');
            //create Opportunity
            AccountTeamMember mem = new AccountTeamMember(
                AccountId=lAcc[0].Id, TeamMemberRole='AE', UserId=lUsr.Id,AccountAccessLevel = 'Edit'
            );
            insert mem;
            AccountTeamMember mem1 = new AccountTeamMember(
                AccountId=lAcc[0].Id, TeamMemberRole='SVC_APOS_SR', UserId=lUsrNonIntegration[0].Id,AccountAccessLevel = 'Edit'
            );
            insert mem1;
            AccountTeamMember mem2 = new AccountTeamMember(
                AccountId=lAcc[0].Id, TeamMemberRole='Primary_SE', UserId=lUsrNonIntegration[1].Id,AccountAccessLevel = 'Edit'
            );
            insert mem2;
            AccountTeamMember mem3 = new AccountTeamMember(
                AccountId=lAcc[0].Id, TeamMemberRole='SVC_APOS_SR', UserId=lUsrNonIntegration[2].Id
            );
            insert mem3;
            List<AccountTeamMember> atm = [Select AccountID,UserId,TeamMemberRole from AccountTeamMember where Account.ID =: lAcc[0].id];
            delete atm[0];
        }
    }
    @isTest
    Public Static void NullData(){
        /*
        List < User > lUsr = [Select Id, ManagerID from User where FBE_Integration_User__c = true limit 1];
        lUsr[0].ManagerId = Userinfo.getUserId();
        lUsr[0].EmployeeNumber = '123';
        update lUsr[0];
    */
        User lUsr = FBE_UtilityFactory_Test.getIntegrationUser();
        List<ID> usId = new List<Id>();
        List < User > lUsrNonIntegration = FBE_UtilityFactory_Test.createUser('System Administrator', 4, 'ab',null);
        
        for(user us : lUsrNonIntegration){
            usId.add(us.Id);
        }
        
        List < Account > lAcc = FBE_UtilityFactory_Test.createAccount(3,null);
        system.runAs(lUsr){
            lAcc[0].FBE_AE_ISR__c = lUsr.Id;
            lAcc[0].FBE_Partner_Type__c = 'Distributor';
            lAcc[1].FBE_Partner_Type__c ='System Integrator';
            //lAcc[2].
            
            insert lAcc;

        }
    }
}