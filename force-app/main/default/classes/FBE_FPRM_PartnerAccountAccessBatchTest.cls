@isTest
public class FBE_FPRM_PartnerAccountAccessBatchTest {
    @isTest
    static void testPartnerAccountSharing(){
        Profile adminProfile = [Select Id,Name from profile where Name='System Administrator' limit 1];
        List<FBE_FPRM_Transfer_Deal_Check__c>customSettingList = new List<FBE_FPRM_Transfer_Deal_Check__c>();
        
        FBE_FPRM_Transfer_Deal_Check__c test = new FBE_FPRM_Transfer_Deal_Check__c(
            SetupOwnerId = adminProfile.Id, Name = 'Test',Is_Transfer_Deal__c = true); 
        customSettingList.add(test); 
        
        FBE_FPRM_Transfer_Deal_Check__c settings = FBE_FPRM_Transfer_Deal_Check__c.getOrgDefaults();
        settings.Is_Transfer_Deal__c = false;
        customSettingList.add(settings); 
        
        UPSERT customSettingList;
        
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){
            
            List<AccountShare> toShareAccount = new List<AccountShare>();    
            List<Account> accountList = FBE_Test_Utility.createAccount(3);
            accountList[0].Name = 'DistributorAccount1';
            accountList[0].FBE_Partner__c = true;
            accountList[0].FBE_Partner_Type__c = 'Distributor';
            accountList[0].FBE_Partner_Relationship__c = 'Titanium';
            accountList[0].FBE_FPRM_Partner_Reg_Status__c = 'Registered';
            
            accountList[1].Name = 'Reseller1';
            accountList[1].FBE_Partner__c = true;
            accountList[1].FBE_Partner_Type__c = 'Reseller';
            accountList[1].FBE_Partner_Relationship__c = 'Titanium';
            accountList[1].FBE_FPRM_Partner_Reg_Status__c = 'Registered';
            
            accountList[2].Name = 'DMP1';
            accountList[2].FBE_Partner__c = true;
            accountList[2].FBE_Partner_Type__c = 'Disty Managed';
            accountList[2].FBE_Partner_Relationship__c = 'Titanium';
            accountList[2].FBE_FPRM_Partner_Reg_Status__c = 'Qualified';
            
            insert accountList;
            
            List<Contact> contactList = FBE_Test_Utility.createContact(2, accountList[0].Id);
            insert contactList;
            
            Profile p = [SELECT Id FROM Profile WHERE Name ='FBE FPRM Partner Distributor'];
            List<User> userList = new List<User>();
            User u1 = new User( email='Test__0@email.com',
                               profileid = p.id, 
                               UserName='trfouser@testorg.com.fprm' , 
                               Alias = 'GDS',
                               TimeZoneSidKey='America/New_York',
                               EmailEncodingKey='ISO-8859-1',
                               LocaleSidKey='en_US', 
                               LanguageLocaleKey='en_US',
                               ContactId = contactList[0].Id,               
                               PortalRole = 'Manager',
                               FirstName = 'Genelia',
                               LastName = 'Dsouza',
                               EmployeeNumber ='1234',
                               FBE_FPRM_OnlineRole__c = 'Site Admin');
            
            userList.add(u1);
            
            User u2 = new User( email='Test__1@email.com',
                               profileid = p.id, 
                               UserName='trf01ouser@testorg.com.fprm' , 
                               Alias = 'GDS1',
                               TimeZoneSidKey='America/New_York',
                               EmailEncodingKey='ISO-8859-1',
                               LocaleSidKey='en_US', 
                               LanguageLocaleKey='en_US',
                               ContactId = contactList[1].Id,               
                               PortalRole = 'Manager',
                               FirstName = 'Abcdefdd',
                               LastName = 'Dsouza',
                               EmployeeNumber ='12311234',
                               FBE_FPRM_OnlineRole__c = 'Site Admin');
            userList.add(u2);
            
            insert userList;
            
            List<Account_Affiliation__c> affUpdateList = new List<Account_Affiliation__c>();
            
            Account_Affiliation__c aff = new Account_Affiliation__c();
            aff.FBE_Account__c = accountList[0].Id;
            aff.FBE_Affilitated_Account__c = accountList[1].Id;
            aff.FBE_Relationship__c ='Distributor';
            aff.FBE_Start_Date__c = System.today();
            aff.FBE_End_Date__c = System.today()+2;
            insert aff;
            
            Account_Affiliation__c aff2 = new Account_Affiliation__c();
            aff2.FBE_Account__c = accountList[1].Id;
            aff2.FBE_Affilitated_Account__c = accountList[0].Id;
            aff2.FBE_Relationship__c ='Reseller';
            aff2.FBE_Start_Date__c = System.today();
            aff2.FBE_End_Date__c = System.today()+2;
            
            insert aff2;
            
            //Update Affiliation to be picked by Batch
            aff.FBE_End_Date__c = System.today()-1;
            aff2.FBE_Start_Date__c = System.today()- 2;
            aff2.FBE_End_Date__c = System.today()+4;
            
            affUpdateList.add(aff);
            affUpdateList.add(aff2);
            update affUpdateList;
            
            Account_Affiliation__c aff3 = new Account_Affiliation__c();
            aff3.FBE_Account__c = accountList[0].Id;
            aff3.FBE_Affilitated_Account__c = accountList[2].Id;
            aff3.FBE_Relationship__c ='Disty Managed';
            aff3.FBE_Start_Date__c = System.today();
            insert aff3;          
            
            for(Account acc : accountList){
                AccountShare accShare = new AccountShare(); 
                accShare.AccountId = acc.Id;
                accShare.UserOrGroupId = u1.Id;
                accShare.AccountAccessLevel = 'Edit';
                accShare.OpportunityAccessLevel='None';
                toShareAccount.add(accShare);
            } 
            insert toShareAccount;
            
            FBE_FPRM_PartnerAccountAccessBatch obj = new FBE_FPRM_PartnerAccountAccessBatch();
            Id batchJobId = Database.executeBatch(obj);
            
            AsyncApexJob apexjob = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob WHERE ID =: batchJobId ];
            System.debug('Job Status'+apexjob);
            System.assertEquals(0, apexjob.NumberOfErrors, 'No Errors');
            
        }
    }
}