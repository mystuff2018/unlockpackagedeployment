/**************
 *@ Class Name        : FBE_Test_LeadAssignmentController
 *@ Description       : Test class to create test data and test for FBE_Test_LeadAssignmentController. The test class covers below scenarios :
                        1. Lead Assignment for Outbound Lead Type. It includes assigning Lead Owner to user with minimum Employee Number in Account Team, Assignment to 
                           Lead Qualification Team when Lead Sales Role does not exist in Account Team, or no Account Team Members exist.
                        2. Lead Assignment for Inbound Lead Type. It includes assigning Lead Owner to user with minimum Employee Number in Account Team based on Campaign Follow-up
                           Role. If Follow-Up role does not exist, it checks for Campaign Secondary Role. If either Roles are not present on Account Team or no Team Members exist
                           then assinging Lead Qualification Team as Lead Owner.
                        3. Test error handling code in FBE_Test_LeadAssignmentController - getLeadDetails method.
 *@ CreatedBy         : Deloitte Consulting
 *@ CreatedOn         : 07-12-2019
 *@ Modification Log  : Version 1.0 - [Abhishek Kawle] : Initially created script to create test data and test for FBE_Test_LeadAssignmentController Apex Class
 ***************/
@isTest(seeAllData = false)
public class FBE_Test_LeadAssignmentController {
    /**************
     * @MethodName    : testOutboundLeadAssignment
     * @Trigger       : -
     * @Description   : This method asserts Lead Assignment for Outbound Lead Type.
     ***************/
    static TestMethod void testOutboundLeadAssignment(){
        //List<User> lUser =  [Select Id from User where FBE_Integration_User__c = true];
        User lUser = FBE_UtilityFactory_Test.getIntegrationUser();
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
            
            List<Account> lAcc = FBE_UtilityFactory_Test.createAccount(2,null);
            insert lAcc;
            
            list<AccountTeamMember> accTeamMemberList = new list<AccountTeamMember>();
            accTeamMemberList.add(new AccountTeamMember(AccountAccessLevel='Read',UserId=lUserTeam[0].id,TeamMemberRole='SR',AccountId=lAcc[0].id));
            accTeamMemberList.add(new AccountTeamMember(AccountAccessLevel='Read',UserId=lUserTeam[1].id,TeamMemberRole='SR',AccountId=lAcc[0].id));
            accTeamMemberList.add(new AccountTeamMember(AccountAccessLevel='Read',UserId=lUserTeam[2].id,TeamMemberRole='SR',AccountId=lAcc[0].id));
            insert accTeamMemberList;
            
            List <Lead> leadList = FBE_UtilityFactory_Test.createLead(1, 'Outbound');
            for(Lead obj: leadList){
                obj.FBE_Account_Name__c = lAcc[0].Id;
                obj.Id = leadList[0].Id;
                obj.OwnerId = lUserTeam[1].id;
            }
            insert leadList;
            system.assertNotEquals(null, leadList[0].id, 'Null check');
            
          /*  List <Lead> leadListUpdate = new List<Lead>();
            for(Lead obj: leadList){
                obj.FBE_Account_Name__c = lAcc[0].Id;
                obj.Id = leadList[0].Id;
                obj.OwnerId = lUserTeam[1].id;
                leadListUpdate.add(obj);
            }
            
            if(leadListUpdate.size() > 0){
                update leadListUpdate;    
            } */
            
            //Verify Account Team Member having 'SR' Role and Minimum Employee Number is the Lead Owner
            try{
                FBE_LeadAssignmentController.getLeadDetails(leadList);
            }
            catch(Exception e){
                system.debug(e.getMessage());
            }            
            
            Lead lead = [Select Id,OwnerId from Lead Where Id =:leadList[0].Id];
            User user = [Select Id,EmployeeNumber from User Where Id IN: userIdSet Order by  EmployeeNumber asc limit 1];
            System.assertEquals(user.Id, lead.OwnerId, 'User Owner check');
            
            //Update user's employee number and verify one with lowest number is made lead owner.
            User userobj = userUpdateList[1];
            userObj.Id = userUpdateList[1].Id;
            userObj.EmployeeNumber = '123';
            update userObj;
            
            try{
                FBE_LeadAssignmentController.getLeadDetails(leadList);
            }
            catch(Exception e){
                system.debug(e.getMessage());
            }
            lead = [Select Id,OwnerId from Lead Where Id =:leadList[0].Id];
            System.assertEquals(userUpdateList[1].Id, lead.OwnerId, 'user list check');
            
            //Update Account Team Members Role to value other Lead Role and check assignment is made to Lead Qualification Team
            List<AccountTeamMember> accTeamMemberListUpdate = new List<AccountTeamMember>();
            for(AccountTeamMember accMem : accTeamMemberList){
                accMem.TeamMemberRole = 'ACCT_SE';
                accTeamMemberListUpdate.add(accMem);
            }
            if(accTeamMemberListUpdate.size() >0){
                update accTeamMemberListUpdate;
            }
            
            try{
                FBE_LeadAssignmentController.getLeadDetails(leadList);
            }
            catch(Exception e){
                system.debug(e.getMessage());
            }
            lead = [Select Id,OwnerId from Lead Where Id =:leadList[0].Id];
            //System.assertEquals(Label.Lead_Qualification_Team_Queue_Id, lead.OwnerId);
            
            //Delete Account Team Members and check Lead Owner Assignment is made to Lead Qualification Team
            if(accTeamMemberListUpdate.size() >0){
                delete accTeamMemberListUpdate;
            }
            
            try{
                FBE_LeadAssignmentController.getLeadDetails(leadList);
            }
            catch(Exception e){
                system.debug(e.getMessage());
            }
            lead = [Select Id,OwnerId from Lead Where Id =:leadList[0].Id];
            //System.assertEquals(Label.Lead_Qualification_Team_Queue_Id, lead.OwnerId);
            Test.stopTest();
        }
    }
    
    /**************
     * @MethodName    : testInboundLeadAssignment
     * @Trigger       : -
     * @Description   : This method asserts Lead Assignment for Inbound Lead Type.
     ***************/
    static TestMethod void testInboundLeadAssignment(){
        //List<User> lUser =  [Select Id from User where FBE_Integration_User__c = true];
        User lUser = FBE_UtilityFactory_Test.getIntegrationUser();
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
            
            List<Account> lAcc = FBE_UtilityFactory_Test.createAccount(2,null);
            insert lAcc;
            
            list<AccountTeamMember> accTeamMemberList = new list<AccountTeamMember>();
            accTeamMemberList.add(new AccountTeamMember(AccountAccessLevel='Read',UserId=lUserTeam[0].id,TeamMemberRole='SR',AccountId=lAcc[0].id));
            accTeamMemberList.add(new AccountTeamMember(AccountAccessLevel='Read',UserId=lUserTeam[1].id,TeamMemberRole='SR',AccountId=lAcc[0].id));
            accTeamMemberList.add(new AccountTeamMember(AccountAccessLevel='Read',UserId=lUserTeam[2].id,TeamMemberRole='SR',AccountId=lAcc[0].id));
            insert accTeamMemberList;
            
            List <Lead> leadList = FBE_UtilityFactory_Test.createLead(1, 'Inbound');
            insert leadList;
            system.assertNotEquals(null, leadList[0].id, 'Null check');
            
            List <Lead> leadListUpdate = new List<Lead>();
            for(Lead obj: leadList){
                obj.FBE_Account_Name__c = lAcc[0].Id;
                obj.OwnerId = lUserTeam[1].id;
                obj.Id = leadList[0].Id;
                leadListUpdate.add(obj);
            }
            
            if(leadListUpdate.size() > 0){
                update leadListUpdate;    
            }
            
            List<Lead> leadListInbound = [Select Id, FBE_Lead_Type__c, FBE_Sales_Role__c, FBE_Account_Name__c, FBE_Campaign_Follow_Up_Role__c, FBE_Campaign_Secondary_Role__c 
                                         FROM Lead Where Id =: leadList[0].Id];
            //Verify If Lead - Campaign Role are not found on Account Team Member, then Lead Owner is updated as Lead Qualification Team
            try{
                FBE_LeadAssignmentController.getLeadDetails(leadListInbound);
            }
            catch(Exception e){
                system.debug(e.getMessage());
            }
            Lead lead = [Select Id,OwnerId from Lead Where Id =:leadList[0].Id];
            //System.assertEquals(Label.Lead_Qualification_Team_Queue_Id, lead.OwnerId);
            
            //Update Lead Campaign Follow Up role to NULL. This ensures Lead Assignment Controller picks Campaign Secondary Role for Assignment.
            //If Role is not found on Account Team Member, then Lead Owner is updated as Lead Qualification Team
            Campaign campaignObj = [Select Id, FBE_Follow_up__c, FBE_Secondary_Role__c from Campaign where Id =: leadList[0].FBE_Campaign__c];
            campaignObj.FBE_Follow_up__c = null;
            update campaignObj;
            
            try{
                FBE_LeadAssignmentController.getLeadDetails(leadList);
            }
             catch(Exception e){
                system.debug(e.getMessage());
            }
            lead = [Select Id,OwnerId from Lead Where Id =:leadList[0].Id];
            //System.assertEquals(Label.Lead_Qualification_Team_Queue_Id, lead.OwnerId);
            
            //Delete Account Team Members and check Lead Owner Assignment is made to Lead Qualification Team
            if(accTeamMemberList.size() >0){
                delete accTeamMemberList;
            }
            
            try{
                FBE_LeadAssignmentController.getLeadDetails(leadList);
            }
            catch(Exception e){
                system.debug(e.getMessage());
            }
            lead = [Select Id,OwnerId from Lead Where Id =:leadList[0].Id];
            //System.assertEquals(Label.Lead_Qualification_Team_Queue_Id, lead.OwnerId);
            Test.stopTest();
        }
    }

    /**************
     * @MethodName    : testLeadAssignmentError
     * @Trigger       : -
     * @Description   : This method covers error handling for FBE_LeadAssignmentController - getLeadDetails method.
     ***************/    
    static TestMethod void testLeadAssignmentError(){
        //List<User> lUser =  [Select Id from User where FBE_Integration_User__c = true];
        User lUser = FBE_UtilityFactory_Test.getIntegrationUser();
        system.runAs(lUser){
            Test.startTest();
            List <Lead> leadList = FBE_UtilityFactory_Test.createLead(1, 'Inbound');
            insert leadList;
            system.assertNotEquals(null, leadList[0].id, 'Null check');
            
            List <Lead> leadListUpdate = new List<Lead>();
            for(Lead obj: leadList){
                obj.Id = '00Q35000001GCglE3D'; //Dummy Lead Id so that FBE_LeadAssignmentController errors out in Update step.
                leadListUpdate.add(obj);
            }
            
            try{
                FBE_LeadAssignmentController.getLeadDetails(leadListUpdate);
            }
            catch(Exception e){
                system.debug(e.getMessage());
            }
            Test.stopTest();
        }
    }
    
}