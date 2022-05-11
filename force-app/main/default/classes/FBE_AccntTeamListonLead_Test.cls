@isTest
public class FBE_AccntTeamListonLead_Test {
  
    @testSetup static void setup() {
        List < User > lUsr = [Select Id from User where FBE_Integration_User__c = true];
        List < User > lUsrNonIntegration = FBE_UtilityFactory_Test.createUser('System Administrator', 4, 'ab',null);
        List<Lead> insLeadList = new List<Lead>();
        List < Account > lAcc = FBE_UtilityFactory_Test.createAccount(2,null);
        for(Integer i=0 ;i <lAcc.size() ; i++){
            lAcc[i].name = 'SFDC Test Account'+i;
        }
        system.runAs(lUsr[0]) {
            //Create an Account
            
            insert lAcc;
            system.assertNotEquals(null, lAcc[0].id, 'Account Record not found');
            system.assertNotEquals(null, lAcc[1].id, 'Account Record not found');
            
            AccountTeamMember atmuser = new AccountTeamMember();
            atmuser.TeamMemberRole = 'SR';
            atmuser.AccountId = lAcc[0].id;
            atmuser.UserId = lUsrNonIntegration[0].Id;
            insert atmuser;
            
            AccountTeamMember atmuser1 = new AccountTeamMember();
            atmuser1.TeamMemberRole = 'SR';
            atmuser1.AccountId = lAcc[1].id;
            atmuser1.UserId = lUsrNonIntegration[0].Id;
            insert atmuser1;
            
            
            List < Campaign > campaignList = FBE_UtilityFactory_Test.createCampaign(1);
            insert campaignList;
            for(Integer i=0 ;i<=1 ;i ++){
                Lead leadRecord = new Lead();
                leadRecord.Company = 'Company_Test'+i;
                leadRecord.FirstName = 'Lead Fname'+i;
                leadRecord.LastName = 'Lead LName'+i;
                leadRecord.FBE_Lead_Type__c = 'Inbound';
                leadRecord.Email = 'testleadabc@abc.com';
                leadRecord.Phone = '1232789';
                leadRecord.FBE_Sales_Role__c = 'SR';
                leadRecord.FBE_Campaign__c = campaignList[0].Id;
                leadRecord.FBE_Account_Name__c = lAcc[0].id;
                leadRecord.FBE_End_User_Account__c = lAcc[1].id;
                leadRecord.ownerid = lUsrNonIntegration[0].id;
                leadRecord.Opportunity_Product_Classification__c = 'Dell Products';
                leadRecord.LeadSource = 'Email';
                leadRecord.FBE_Funding_Source__c = 'FUNDED-Prior Year Carryover';
                leadRecord.FBE_Lead_Type__c ='Inbound';
                insLeadList.add(leadRecord);
            }
            insert insLeadList;
            
            ATMSkipValidation__c skipval = new ATMSkipValidation__c();
            skipval.SkipFieldName__c = 'Test';
            upsert skipval;
        }
    }
    
    @isTest
    static void passLeadId(){
        List<Lead> allLeads = [SELECT Id,FirstName, LastName, Phone, Email,FBE_End_User_Account__c,FBE_Account_Name__c,FBE_End_User_Account__r.Name,FBE_Account_Name__r.Name,
                               FBE_Campaign__c,Opportunity_Product_Classification__c,FBE_Funding_Source__c,FBE_Customer_Comments__c,FBE_Project_ID__c,
                               FBE_Expected_Opportunity_Type__c,Company FROM Lead WHERE FirstName LIKE 'Lead Fname%' AND LastName LIKE 'Lead LName%' AND Email ='testleadabc@abc.com'];
        System.debug('allLeads size: '+allLeads.size()+ ' - ' +allLeads);
        
        List<AccountTeamMember> testTeamMembers = FBE_AccntTeamListonLead.returnAccMember(allLeads[0].Id);
    }
    
     @isTest
    static void passLeadId1(){
        List<Lead> allLeads = [SELECT Id,FirstName, LastName, Phone, Email,FBE_End_User_Account__c,FBE_Account_Name__c,FBE_End_User_Account__r.Name,FBE_Account_Name__r.Name,
                               FBE_Campaign__c,Opportunity_Product_Classification__c,FBE_Funding_Source__c,FBE_Customer_Comments__c,FBE_Project_ID__c,
                               FBE_Expected_Opportunity_Type__c,Company FROM Lead WHERE FirstName LIKE 'Lead Fname%' AND LastName LIKE 'Lead LName%' AND Email ='testleadabc@abc.com'];
        System.debug('allLeads size: '+allLeads.size()+ ' - ' +allLeads);
        
        List<AccountTeamMember> testTeamMembersonPageList = FBE_AccntTeamListonLead.getAccTeam(allLeads[0].FBE_Account_Name__c);
    }
    
     @isTest
    static void passLeadId2(){
        List<Lead> allLeads = [SELECT Id,FirstName, LastName, Phone, Email,FBE_End_User_Account__c,FBE_Account_Name__c,FBE_End_User_Account__r.Name,FBE_Account_Name__r.Name,
                               FBE_Campaign__c,Opportunity_Product_Classification__c,FBE_Funding_Source__c,FBE_Customer_Comments__c,FBE_Project_ID__c,
                               FBE_Expected_Opportunity_Type__c,Company FROM Lead WHERE FirstName LIKE 'Lead Fname%' AND LastName LIKE 'Lead LName%' AND Email ='testleadabc@abc.com'];
        System.debug('allLeads size: '+allLeads.size()+ ' - ' +allLeads);
        List<AccountTeamMember> testTeamMembersforendUserAcnt = FBE_AccntTeamListonLead.returnEndUserAccMember(allLeads[0].Id);
    }
}