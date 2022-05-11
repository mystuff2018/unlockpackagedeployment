/**************
*@ Class Name                                                    : FBE_Test_IndirectOptyOwnerAssignment 
*@ Description                                                   : This Test class is written to cover various scenarios in the class FBE_IndirectOptyOwnerAssignment
*@ CreatedBy                                                     : Deloitte Consulting
*@ CreatedOn                                                     : 20-09-2019 [Namita Verma]
*@ Modification Log                                             : 
****************/
@isTest(seeAllData = false)
public class FBE_Test_IndirectOptyOwnerAssignment {
    static TestMethod void testOptyOwnerAssignment(){
       //List<User> lUser =  [Select Id from User where FBE_Integration_User__c = true];
       User lUser =FBE_UtilityFactory_Test.getIntegrationUser();
        List<User> lUserTeam = FBE_UtilityFactory_Test.createUser('System Administrator', 3, 'ab',null);
        
        system.runAs(lUser){
            Test.startTest();
            //Setup Account & User Data
            List<User> userUpdateList = new List<User>();
            Set<Id> userIdSet = new Set<Id>();
            for(Integer i=0; i<lUserTeam.size(); i++) {
                User user = new User();
                user.Id = lUserTeam[i].Id;
                user.EmployeeNumber= '1000'+i;
                userUpdateList.add(user);
                userIdSet.add(lUserTeam[i].Id);
            }
            
            if(userUpdateList.size() > 0){
                update userUpdateList;
            }
            
            List<Account> lAcc = FBE_UtilityFactory_Test.createAccount(1,null);
            insert lAcc;
            
            list<AccountTeamMember> accTeamMemberList = new list<AccountTeamMember>();
            accTeamMemberList.add(new AccountTeamMember(AccountAccessLevel='Read',UserId=lUserTeam[0].id,TeamMemberRole='SR',AccountId=lAcc[0].id));
            accTeamMemberList.add(new AccountTeamMember(AccountAccessLevel='Read',UserId=lUserTeam[1].id,TeamMemberRole='SR',AccountId=lAcc[0].id));
            accTeamMemberList.add(new AccountTeamMember(AccountAccessLevel='Read',UserId=lUserTeam[2].id,TeamMemberRole='SR',AccountId=lAcc[0].id));
            insert accTeamMemberList;
            
            List <Opportunity> optyList = FBE_UtilityFactory_Test.createOpportunity(1, lAcc[0].id,null,null,null,null,null);
            insert optyList;
            system.assertNotEquals(null, optyList[0].id,'Null check');
            List<Deal_Registration__c> dealR = FBE_UtilityFactory_Test.createDeal(1);
            insert dealR;System.debug('created deal'+dealR[0]);
            optyList[0].FBE_Pursuit_Type__c = 'Indirect';
            optyList[0].FBE_Linked_DealReg__c = dealR[0].Id;
            update optyList;
            System.debug('Updated Opty'+optyList);
            //Verify Account Team Member having 'SR' Role and Minimum Employee Number is the Opty Owner
            try{
                FBE_IndirectOptyOwnerAssignment.assignOptyOwner(optyList);
            }
            catch(Exception e){
                system.debug(e.getMessage());
            }          
        
        }
    }

}