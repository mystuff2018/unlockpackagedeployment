@isTest
public class FBE_LeadTriggerHandler_Test {
    static TestMethod void FBE_LeadTriggerHandler_Test_UserChange() {
        //List < User > lUsr = [Select Id from User where FBE_Integration_User__c = true];
        User lUsr = FBE_UtilityFactory_Test.getIntegrationUser();
        List < User > lUsrNonIntegration = FBE_UtilityFactory_Test.createUser('System Administrator', 4, 'ab',null);
		List < Lead > leadList = new List < Lead > ();
        List < Account > lAcc = FBE_UtilityFactory_Test.createAccount(2,null);
        system.runAs(lUsr) {
            //Create an Account
            
            insert lAcc;
            system.assertNotEquals(null, lAcc[0].id, 'Account Record not found');
            system.assertNotEquals(null, lAcc[1].id, 'Account Record not found');

            //add Account team member to Accounts Created
            list < AccountTeamMember > accTeamMemberList = new list < AccountTeamMember > ();
            accTeamMemberList.add(new AccountTeamMember(AccountAccessLevel = 'Edit', UserId = lUsrNonIntegration[0].id, TeamMemberRole = 'SR', AccountId = lAcc[0].id));
            accTeamMemberList.add(new AccountTeamMember(AccountAccessLevel = 'Edit', UserId = lUsrNonIntegration[1].id, TeamMemberRole = 'AE', AccountId = lAcc[0].id));

            insert accTeamMemberList;
            
            List < Campaign > campaignList = FBE_UtilityFactory_Test.createCampaign(1);
            insert campaignList;

            Lead leadRecord = new Lead();
            leadRecord.Company = 'Company_';
            leadRecord.FirstName = 'Lead_';
            leadRecord.LastName = 'Test';
            leadRecord.FBE_Lead_Type__c = 'Inbound';
            leadRecord.Email = 'abc@abc.com';
            leadRecord.FBE_Sales_Role__c = 'SR';
            leadRecord.FBE_Campaign__c = campaignList[0].Id;
			leadRecord.FBE_Account_Name__c = lAcc[0].id;
            leadRecord.FBE_End_User_Account__c = lAcc[1].id;
            leadRecord.ownerid = lUsrNonIntegration[0].id;
            leadList.add(leadRecord);

            insert leadList;
            update leadList;

        }

        test.startTest();
        List < Lead > ld = [Select id, ownerid, FBE_Account_Name__c from Lead where id =: leadList[0].id];
        //List < user > us = [select id from user];
        //List < Account > accn = [select id from account];
       
                  ld[0].ownerid = lUsrNonIntegration[0].id;
           
        update ld[0];
        test.stopTest();
    }
    static TestMethod void FBE_LeadTriggerHandler_Test_AccountChange() {
        //List < User > lUsr = [Select Id from User where FBE_Integration_User__c = true];
        User lUsr = FBE_UtilityFactory_Test.getIntegrationUser();
        List < User > lUsrNonIntegration = FBE_UtilityFactory_Test.createUser('System Administrator', 4, 'ab',null);
		
        List < Account > lAcc = new List<Account>();
        system.runAs(lUsr) {
            //Create an Account
            lAcc = FBE_UtilityFactory_Test.createAccount(2,null);
            insert lAcc;
            system.assertNotEquals(null, lAcc[0].id, 'Account Record not found');
            system.assertNotEquals(null, lAcc[1].id, 'Account Record not found');

            //add Account team member to Accounts Created
            list < AccountTeamMember > accTeamMemberList = new list < AccountTeamMember > ();
            accTeamMemberList.add(new AccountTeamMember(AccountAccessLevel = 'Edit', UserId = lUsrNonIntegration[0].id, TeamMemberRole = 'SR', AccountId = lAcc[0].id));
            accTeamMemberList.add(new AccountTeamMember(AccountAccessLevel = 'Edit', UserId = lUsrNonIntegration[1].id, TeamMemberRole = 'AE', AccountId = lAcc[0].id));

            insert accTeamMemberList;


        }
        List < Lead > leadList = new List < Lead > ();
        system.runAs(lUsrNonIntegration[0]) {
            //List < Account > accnt = [select id from account];
            //List < Account > accnt = [select id from account WHERE Id IN :lAcc];
            
            List < Campaign > campaignList = FBE_UtilityFactory_Test.createCampaign(1);
            insert campaignList;

            Lead leadRecord = new Lead();
            leadRecord.Company = 'Company_';
            leadRecord.FirstName = 'Lead_';
            leadRecord.LastName = 'Test';
            leadRecord.FBE_Account_Name__c = lAcc[0].id;
            leadRecord.FBE_End_User_Account__c = lAcc[1].id;
            leadRecord.FBE_Lead_Type__c = 'Inbound';
            leadRecord.Email = 'abc@abc.com';
            leadRecord.FBE_Sales_Role__c = 'SR';
            leadRecord.FBE_Campaign__c = campaignList[0].Id;
			 leadRecord.ownerid = lUsrNonIntegration[0].id;
            leadList.add(leadRecord);

            insert leadList;
        }

        List < Lead > LeadL = new List < Lead > ();

        test.startTest();
        //List < Lead > ld = [Select id, ownerid, FBE_Account_Name__c from Lead];
        //List < Lead > ld = [Select id, ownerid, FBE_Account_Name__c from Lead WHERE Id IN : leadList];
        List < user > us = [select id from user];
        List < Account > accn = [select id from account];
        for (Lead l: leadList) {
            for (Integer count = 2; count <= 3; count++) {
                l.FBE_Account_Name__c = accn[0].id;
                l.FBE_End_User_Account__c = accn[1].id;
            }
            LeadL.add(l);
        }
        update LeadL;
        test.stopTest();
    }
    static TestMethod void FBE_LeadTriggerHandler_Test_LeadConverted() {
        //List < User > lUsr = [Select Id from User where FBE_Integration_User__c = true];
       USer lUsr = FBE_UtilityFactory_Test.getIntegrationUser();
        List < User > lUsrNonIntegration = FBE_UtilityFactory_Test.createUser('System Administrator', 4, 'ab',null);
		List < Account > lAcc = new List<Account>();
        system.runAs(lUsr) {
            //Create an Account
             lAcc = FBE_UtilityFactory_Test.createAccount(2,null);
            insert lAcc;
            system.assertNotEquals(null, lAcc[0].id, 'Account Record not found');
            system.assertNotEquals(null, lAcc[1].id, 'Account Record not found');

            //add Account team member to Accounts Created
            list < AccountTeamMember > accTeamMemberList = new list < AccountTeamMember > ();
            accTeamMemberList.add(new AccountTeamMember(AccountAccessLevel = 'Edit', UserId = lUsrNonIntegration[0].id, TeamMemberRole = 'SR', AccountId = lAcc[0].id));
            accTeamMemberList.add(new AccountTeamMember(AccountAccessLevel = 'Edit', UserId = lUsrNonIntegration[1].id, TeamMemberRole = 'AE', AccountId = lAcc[0].id));

            insert accTeamMemberList;


        }
        List < Lead > leadList = new List < Lead > ();
        system.runAs(lUsrNonIntegration[0]) {
            //List < Account > accnt = [select id from account];
            //List < Account > accnt = [select id from account WHERE ID IN : lAcc];
            
            List < Campaign > campaignList = FBE_UtilityFactory_Test.createCampaign(1);
            insert campaignList;

            Lead leadRecord = new Lead();
            leadRecord.Company = 'Company_';
            leadRecord.FirstName = 'Lead_';
            leadRecord.LastName = 'Test';
            leadRecord.FBE_Account_Name__c = lAcc[0].id;
            leadRecord.FBE_End_User_Account__c = lAcc[1].id;
            leadRecord.FBE_Lead_Type__c = 'Inbound';
            leadRecord.Email = 'abc@abc.com';
            leadRecord.FBE_Sales_Role__c = 'SR';
            leadRecord.MobilePhone = '6536378309';
            leadRecord.Phone = '2627270987';
            leadRecord.Opportunity_Product_Classification__c = 'Dell Products';
            leadRecord.FBE_Campaign__c = campaignList[0].Id;
			leadRecord.ownerid = lUsrNonIntegration[0].id;
            leadList.add(leadRecord);

            insert leadList;
            update leadList;
        }

        List < Lead > LeadL = new List < Lead > ();

        test.startTest();
        //List < Lead > ld = [Select id, ownerid, FBE_Account_Name__c from Lead WHERE ID IN : leadList];
        //List < user > us = [select id from user];
        //List < Account > accn = [select id from account];
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(leadList[0].id);

        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        lc.setAccountId(leadList[0].FBE_Account_Name__c);
        lc.setDoNotCreateOpportunity(true);

        Database.LeadConvertResult lcr = Database.convertLead(lc);



        System.assert(lcr.isSuccess(),'Lead not Converted');
        test.stopTest();
    }
	static TestMethod void FBE_LeadTriggerHandler_Test_CloseTaskForLead() {
        System.Test.startTest();
        USer ltUsr = FBE_UtilityFactory_Test.getIntegrationUser();
        List < User > ltUsrNonIntegration = FBE_UtilityFactory_Test.createUser('System Administrator', 4, 'ab',null);
		List < Account > ltAcc = new List<Account>();
        system.runAs(ltUsr) {
            //Create an Account
            ltAcc = FBE_UtilityFactory_Test.createAccount(2,null);
            insert ltAcc;
            system.assertNotEquals(null, ltAcc[0].id, 'Account Record not found');
            system.assertNotEquals(null, ltAcc[1].id, 'Account Record not found');
        }
        List < Lead > leadListtask = new List < Lead > ();
        system.runAs(ltUsrNonIntegration[0]) {
            
            List < Campaign > campaignListtask = FBE_UtilityFactory_Test.createCampaign(1);
            insert campaignListtask;

            Lead leadtaskRecord = new Lead();
            List <Task> TaskListRecord = new List <Task>();
            leadtaskRecord.Company = 'Company Lead Task';
            leadtaskRecord.FirstName = 'Lead Task';
            leadtaskRecord.LastName = 'Closure';
            leadtaskRecord.FBE_Account_Name__c = ltAcc[0].id;
            leadtaskRecord.FBE_End_User_Account__c = ltAcc[1].id;
            leadtaskRecord.FBE_Lead_Type__c = 'Inbound';
            leadtaskRecord.Email = 'abc@abc.com';
            leadtaskRecord.FBE_Sales_Role__c = 'SR';
            leadtaskRecord.MobilePhone = '52835639871';
            leadtaskRecord.Phone = '5728382553';
            leadtaskRecord.Opportunity_Product_Classification__c = 'Dell Products';
            leadtaskRecord.FBE_Campaign__c = campaignListtask[0].Id;
			leadtaskRecord.ownerid = ltUsrNonIntegration[0].id;
            leadListtask.add(leadtaskRecord);

            insert leadListtask;
            update leadListtask;
            
            List <Task> TaskConvt = new List<Task>();
			for (Integer count = 0; count < 6; count++) {
				Task TaskList = new Task();
				TaskList.WhoId=leadListtask[0].Id;
				TaskList.OwnerId=leadListtask[0].ownerid;
				TaskList.Status = 'In Progress';
				TaskList.Type = 'ISG Competitive';
				TaskList.Subject = 'Test CK Subject for Task_'+count;
				TaskList.Priority='Low';
				TaskList.Description='Test Description for Lead_'+count;
				TaskConvt.add(TaskList);
			}
            insert TaskConvt;
            update TaskConvt;
            
            List <Task> TaskConvt2 = [SELECT Id, Status, Description from Task where WhoId=:leadtaskRecord.Id and Subject in ('Test CK Subject for Task_2','Test CK Subject for Task_3','Test CK Subject for Task_5')];
            for(Task tcl: TaskConvt2){
                tcl.Description='Auto Closure of Task during Lead Conversion';
                tcl.Status='Closed';
            }
            update TaskConvt2;
        }

        Database.LeadConvert ltc = new Database.LeadConvert();
        ltc.setLeadId(leadListtask[0].id);

        LeadStatus convertleadtaskStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];
        ltc.setConvertedStatus(convertleadtaskStatus.MasterLabel);
        ltc.setAccountId(leadListtask[0].FBE_Account_Name__c);
        ltc.setDoNotCreateOpportunity(true);
        Database.LeadConvertResult ltcr = Database.convertLead(ltc);
        Lead Ldtask = [select Id, ConvertedContactId, IsConverted FROM Lead where Id=:leadListtask[0].id limit 1];
        List <Task> LeadTasks = [SELECT Id, WhoId, Status, Description from Task where WhoId =:Ldtask.ConvertedContactId order by Subject asc];
        System.assertEquals(true,Ldtask.IsConverted);
        system.assertEquals('Test Description for Lead_0', LeadTasks[0].Description);
        system.assertEquals('Test Description for Lead_1', LeadTasks[1].Description);
        system.assertEquals('Auto Closure of Task during Lead Conversion', LeadTasks[2].Description);
        system.assertEquals('Auto Closure of Task during Lead Conversion', LeadTasks[3].Description);
        system.assertEquals('Test Description for Lead_4', LeadTasks[4].Description);
        system.assertEquals('Auto Closure of Task during Lead Conversion', LeadTasks[5].Description);
        system.assertEquals('Closed', LeadTasks[2].Status);
        system.assertEquals('Closed', LeadTasks[3].Status);
        system.assertEquals('Closed', LeadTasks[5].Status);
        System.Test.stopTest();
    }
}