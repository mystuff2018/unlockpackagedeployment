/**************
*@ Class Name                                                    : FBE_LeadStatusBatchTest
*@ Description                                                   : Test class for FBE_LeadStatusBatch.
*@ CreatedBy                                                     : Dell Team
*@ CreatedOn                                                     : 02-April-2020 [Sireesha Myla]
*@ Modification Log                                              : 
***************/ 
@isTest
public class FBE_LeadStatusBatchTest 
{
   static testMethod void testMethod1()
   {
       //List < User > lUsr = [Select Id from User where FBE_Integration_User__c = true];
       User lUsr = FBE_UtilityFactory_Test.getIntegrationUser();
        List < User > lUsrNonIntegration = FBE_UtilityFactory_Test.createUser('System Administrator', 4, 'ab',null);
		List < Lead > leadList = new List < Lead > ();
        List < Account > lAcc = FBE_UtilityFactory_Test.createAccount(2,null);
       Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
       User u = new User(Alias = 'st' , Email = 'a' +'trfouser@testorg.com', LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8', LastName = 'Testing',EmployeeNumber='1234', LanguageLocaleKey = 'en_US', ProfileId = p.id,
                TimeZoneSidKey = 'America/Los_Angeles', managerid = lUsrNonIntegration[0].id, UserName = 'a' + 'trfouser@testorg.com');
           insert u;
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
			
            for(Integer i=0 ; i<=1 ; i++){
                Lead leadRecord = new Lead();
            leadRecord.Company = 'Company_';
            leadRecord.FirstName = 'Lead_'+i;
            leadRecord.LastName = 'Test';
            leadRecord.FBE_Lead_Type__c = 'Inbound';
            leadRecord.Email = i+'abc@abc.com';
            leadRecord.FBE_Sales_Role__c = 'SR';
            leadRecord.Status = 'Working';
            leadRecord.FBE_Campaign__c = campaignList[0].Id;
			leadRecord.FBE_Account_Name__c = lAcc[0].id;
            leadRecord.FBE_End_User_Account__c = lAcc[1].id;
            leadRecord.ownerid = lUsrNonIntegration[0].id;
            leadList.add(leadRecord);
            }
            

            insert leadList;
            

        }

        test.startTest();
        List < Lead > ld = [Select id, ownerid, FBE_Account_Name__c from Lead where id IN: leadList];
        //List < user > us = [select id from user];
        //List < Account > accn = [select id from account];
       
                  ld[0].ownerid = u.id; ld[1].ownerid = u.id;
      
		String sch = '0 0 12 1 1 ? *'; 
       system.schedule('test', sch, new FBE_LeadStatusBatch_Schedule());
       
        //FBE_LeadStatusBatch leadBatch = new FBE_LeadStatusBatch();
                       //  Database.executeBatch(leadBatch, 50);
                         //leadBatch.Finish(null);
           
        update ld;
        test.stopTest();
    }
}