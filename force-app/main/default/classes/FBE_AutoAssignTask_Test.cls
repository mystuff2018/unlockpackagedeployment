/**************
*@ Class Name                                                    : FBE_AutoAssignTask_Test
*@ Description                                                   : Test Class for FBE_AutoAssignTask
*@ CreatedBy                                                     : Dell Team
*@ CreatedOn                                                     : 03-23-2020 [Rakesh Reddy Mula]
*@ Modification Log                                              : 
***************/  
@isTest
public class FBE_AutoAssignTask_Test {
    
    public static string taskRecordType = System.Label.Task_Support_Request_record_type;
    public static ID supportReqrecTypeId = FBE_Utility.getSupportReqrecTypeId(taskRecordType);
    
    @isTest    
    public static void checkAutoTaskAssignment(){
        
        List<User> usr = FBE_UtilityFactory_Test.createUser('System Administrator', 1, 'sys' ,null );       
        List<User> ProposalUser = FBE_UtilityFactory_Test.createUser('Federal Core Sales Group', 2, 'Pmg' ,null);       
        //List<User> u =  [Select Id from User where FBE_Integration_User__c = true];
        User u = FBE_UtilityFactory_Test.getIntegrationUser();
        system.runAs(u){
            
            Account Acc = new Account(Name='Test Account',FBE_Account_Class__c='Direct',FBE_Status__c='Active');
            insert Acc;
            system.debug('TestSetup-Acc===> ' +Acc); 
            
            //List<AccountTeamMember> atmList = new List<AccountTeamMember>();
            AccountTeamMember atm1 = new AccountTeamMember();
            atm1.AccountId = Acc.id;
            atm1.UserId = ProposalUser[0].id;
            atm1.TeamMemberRole ='PROP_MGR';
            atm1.AccountAccessLevel = 'Read';
            atm1.OpportunityAccessLevel = 'Read';
            atm1.CaseAccessLevel = 'Read';
            //atmList.add(atm1);
            insert atm1;
            
            List<opportunity> opp = FBE_UtilityFactory_Test.createOpportunity(1, Acc.Id,null,null,null,null,null);
            insert opp; 
            system.debug('TestData- opp==> '+opp);
            
            List<Task> pTskList = new List<Task>();
            Task pTsk1 = new Task();
            pTsk1.RecordTypeId = supportReqrecTypeId;
            pTsk1.FBE_End_Date_del__c = System.Today();
            pTsk1.Description = 'TestTask1';
            pTsk1.Status = 'Draft';
            pTsk1.OwnerId = usr[0].Id;
            pTsk1.Type = 'Proposal';
            pTsk1.ActivityDate = System.Today();
            pTsk1.whatId = opp[0].Id;
            pTsk1.fbe_assigned_To__c = usr[0].Id;
            pTsk1.FBE_Opportunity__c = opp[0].Id;      
            pTskList.add(pTsk1);
            
            Task pTsk2 = new Task();
            pTsk2.RecordTypeId = supportReqrecTypeId;
            pTsk2.FBE_End_Date_del__c = System.Today();
            pTsk2.Description = 'TestTask2';
            pTsk2.Status = 'Draft';
            pTsk2.OwnerId = usr[0].Id;
            pTsk2.Type = 'Proposal';
            pTsk2.ActivityDate = System.Today();
            pTsk2.whatId = opp[0].Id;
            pTsk2.FBE_Opportunity__c = opp[0].Id;        
            //pTskList.add(pTsk2); 
            
            Task pTsk3 = new Task();
            pTsk3.RecordTypeId = supportReqrecTypeId;
            pTsk3.FBE_End_Date_del__c = System.Today();
            pTsk3.Description = 'TestTask3';
            pTsk3.Status = 'Closed';
            pTsk3.OwnerId = usr[0].Id;
            pTsk3.Type = 'Proposal';
            pTsk3.ActivityDate = System.Today();
            pTsk3.whatId = opp[0].Id;
            pTsk3.FBE_Opportunity__c = opp[0].Id; 
            pTsk3.fbe_assigned_To__c = usr[0].Id;
            pTskList.add(pTsk3);
            
           Test.startTest();
            insert pTskList;
            system.debug('Status===> ' +pTsk2.Status); 
           Test.stopTest();
            
            // Coverage for FBE_ProposalTaskEmailNotification 
            System.debug('pTskList[0].FBE_Assigned_To__c:: '+pTskList[0].FBE_Assigned_To__c);    
            System.debug('ProposalUser[0].id:::'+ProposalUser[0].id);
            pTskList[0].FBE_Assigned_To__c = ProposalUser[1].id;
            
            update pTskList[0];
			
            Task closedTask = [Select status,Description from Task where Id =:pTskList[1].Id];
            closedTask.status ='Closed';
            closedTask.Description ='TestTask4';
            update closedTask;
			
            
           // FBE_ProposalTaskEmailNotifications.emailOnClosedTask(newRecords);
        }
    }       
    /*    @isTest
        public static void checkEmailAlerts(){
             List<User> usr = FBE_Test_Utility.createUser('System Administrator', 1, 'sys');       
        List<User> ProposalUser = FBE_Test_Utility.createUser('Federal Core Sales Group', 1, 'Pmg');       
        List<User> u =  [Select Id from User where FBE_Integration_User__c = true];
        
        system.runAs(u[0]){
            
            Account Acc = new Account(Name='Test Account',FBE_Account_Class__c='Direct',FBE_Status__c='Active');
            insert Acc;
            system.debug('TestSetup-Acc===> ' +Acc);
            
            //List<AccountTeamMember> atmList = new List<AccountTeamMember>();
            AccountTeamMember atm1 = new AccountTeamMember();
            atm1.AccountId = Acc.id;
            atm1.UserId = ProposalUser[0].id;
            atm1.TeamMemberRole ='PROP_MGR';
            atm1.AccountAccessLevel = 'Read';
            atm1.OpportunityAccessLevel = 'Read';
            atm1.CaseAccessLevel = 'Read';
            //atmList.add(atm1);
            insert atm1;
            
            List<opportunity> opp = FBE_Test_Utility.createOpportunity(1, Acc.Id);
            insert opp;
            system.debug('TestData- opp==> '+opp);
            
            List<task> tskList = new List<Task>();
            Task pTsk1 = new Task();
            pTsk1.RecordTypeId = supportReqrecTypeId;
            pTsk1.FBE_End_Date_del__c = System.Today();
            pTsk1.Description = 'TestTask1';
            pTsk1.Status = 'Closed';
            pTsk1.OwnerId = usr[0].Id;
            pTsk1.Type = 'Proposal';
            pTsk1.ActivityDate = System.Today();
            pTsk1.whatId = opp[0].Id;
            pTsk1.fbe_assigned_To__c = usr[0].Id;
            pTsk1.FBE_Opportunity__c = opp[0].Id;      
            tskList.add(pTsk1);
            
            test.startTest();
            insert tskList;
            test.stopTest();
            FBE_ProposalTaskEmailNotifications.emailOnClosedTask(tskList);
        }
    }  */  
}