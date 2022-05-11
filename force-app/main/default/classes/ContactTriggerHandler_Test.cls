/* -----------------------------------------------------------------------------------------------------------------------
 Class Name:       ContactTriggerHandler_Test
 Description:      For ContactTriggerHandler Apex Class
 ----------------------------------------------------------------------------------------------------------------------------
 Date         Version          Author               Summary of Changes 
 -----------  -------  ------------------------  ------------------------------------------------------------------------------
 01/25/2018     1.0         Surya Subramanian         Initial Release
 01/25/2018     1.1         Srikanth Parvathareddy    Changes are based on Code Review Defect #4561229
 03/13/2018     1.3        Srikanth P                System.runas() included  - Defect #4777313 
 07/15/2020     1.4        Abhishek K -               Modified code as part of Contact Management Feature #7868086
                           [Deloitte Consulting]
02/09/2021      1.5        [Deloitte Consulting]      Added test methods for updateSharingAccount, accountContactRelOnInsert,
                           - Abhishek K               accountContactRelOnUpdate test methods
 -------------------------------------------------------------------------------------------------------------------------- 
 */
@isTest
private class ContactTriggerHandler_Test {
    
     //Method to setup test data
    @testSetup static void setUpData() {
        //Login with Integration User Profile to create Account
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        List<FBE_FPRM_Transfer_Deal_Check__c> customSettingList= new List<FBE_FPRM_Transfer_Deal_Check__c>();
        Profile adminProfile =[Select Id from Profile where name in ('System Administrator')];
        
        FBE_FPRM_Transfer_Deal_Check__c test = new FBE_FPRM_Transfer_Deal_Check__c(
                                      SetupOwnerId = adminProfile.Id, Name = 'Test',Is_Transfer_Deal__c = true); 
		customSettingList.add(test); 
        
        FBE_FPRM_Transfer_Deal_Check__c settings = FBE_FPRM_Transfer_Deal_Check__c.getOrgDefaults();
        settings.Is_Transfer_Deal__c = false;
        customSettingList.add(settings); 
        
        upsert customSettingList;
        
        system.runAs(loginUser[0]){
            
            //create a test account record
            Account act = SRVS_CreateTestDataFactory.createSingleAccountRecord();
            insert act;
            Account act1 = SRVS_CreateTestDataFactory.createSingleAccountRecord();
            insert act1;
            
            //create a list of contact test records
            List<contact> ct=SRVS_CreateTestDataFactory.createMultipleContactRecords(act,3);
            ct[1].Account_Id__c=ct[0].AccountId;
            ct[2].Account_Id__c=ct[0].AccountId;
            ct[1].email = 'noemail@dell.com';
            ct[2].email ='noemail@dell.com';
            ct[0].email = null;
            ct[0].Phone = '9876896516';
            ct[1].Phone = '9876896516';
            ct[2].Phone = '9876896516';
            
            contact c2= new contact(FirstName = 'test1', LastName = 'lastName',country_code__c= 'USA & Canada (1)',email='noemail@dell.com', accountId = act.id, Phone = '9876896512');
            ct.add(c2);
            contact c3= new contact(FirstName = 'test1', LastName = 'lastName',country_code__c= 'USA & Canada (1)',email='noemail@dell.com', accountId = act.id, Phone = '9876896513');
            ct.add(c3);
            try{
            insert ct;
            }catch(Exception e){ system.debug('test'+e.getMessage());} 
            
            contact c1= new contact(FirstName = 'test1', LastName = 'lastName1',country_code__c= 'USA & Canada (1)',email='noemail@dell.com', accountId = act.id,TimeZone__c=null, Phone = '9876896513');
            insert c1;
            c1.accountId=act1.id;
            update c1;
                       
            //Setup test data as creation of PSA Technical Resource Users will invoke 'FBE_CreatePSAContactsBulk' Apex Class.
            pse__Work_Calendar__c workCalendar = new pse__Work_Calendar__c();
            workCalendar.Name = 'PSA-India-40';
            insert workCalendar;

            Account account = new Account();
            account.Name = System.label.FBE_PSA_Resource_Account_Name;
            account.Site_Access_Required__c = 'Yes';
            insert account;
			
            pse__Proj__c projectTemplate = TestDataUtility.createProject(true);
            pse__Practice__c practices = new pse__Practice__c();
            practices.Name = 'Infrastructure Delivery Services';
            practices.Standard_Project_Template__c = projectTemplate.Id;
            insert practices;

            pse__Region__c region = new pse__Region__c();
            region.Name = 'India';
            insert region;
            
            pse__Proj__c testProject = new pse__Proj__c(
                Name = 'Test Project',
                pse__Start_Date__c = System.today(),
                pse__End_Date__c = System.today() + 7,
                pse__Project_Phase__c = 'Setup',
                pse__Project_Type__c = 'Standard',
                pse__Stage__c = 'Draft',
                pse__Project_Manager__c = c1.Id,
                pse__Region__c = region.Id,
                pse__Practice__c = practices.Id,
                pse__Is_Active__c = true
        );
        insert testProject;

        testProject.pse__End_Date__c = System.today() + 7;

        update testProject;

        pse__Project_Task__c testProjectTask = new pse__Project_Task__c(
                Name = 'Test Project Task',
                pse__Start_Date_Time__c = System.now(),
                pse__End_Date_Time__c = System.now() + 7,
                pse__Estimated_Hours__c = 8,
                pse__Started__c = true,
                pse__Project__c = testProject.Id
        );
        insert testProjectTask;

        Id installationBadgeRecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('Installation_Badge').getRecordTypeId();
        WorkOrder testWorkOrder = new WorkOrder();
        testWorkOrder.Status = 'FF - Work In Progress';
        testWorkOrder.RecordTypeId = installationBadgeRecordTypeId;
        testWorkOrder.IsConvergeWorkOrder__c=false;
        testWorkOrder.Project_Task__c = testProjectTask.Id;
        testWorkOrder.Account = account;
        testWorkOrder.AccountId = account.Id;
        insert testWorkOrder;
            
        Id installationBadgeRecordType = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByName().get('Installation - Badge').getRecordTypeId();

        ServiceAppointment testSA = new ServiceAppointment(
                Work_Order__c = testWorkOrder.Id,
                EarliestStartTime = System.now(),
                DueDate = System.now() + 7,
                Status = 'New',
                ParentRecordId = testWorkOrder.Id,
                RecordTypeId = installationBadgeRecordType,
                Assignee__c = c1.id
        );
        insert testSA; 
            
            //Insert Two Partner Accounts, one is a Distributor and Other a DMP
            List<Account> prmAccount = FBE_Test_Utility.createAccount(4);
            prmAccount[0].Name = 'DistributorAccount1';
            prmAccount[0].FBE_Partner__c = true;
            prmAccount[0].FBE_Partner_Type__c = 'Distributor';
            prmAccount[0].FBE_Partner_Relationship__c = 'Titanium';
            prmAccount[0].FBE_FPRM_Partner_Reg_Status__c = 'Registered';
            
            prmAccount[1].Name = 'DMP1';
            prmAccount[1].FBE_Partner__c = true;
            prmAccount[1].FBE_Partner_Type__c = 'Disty Managed';
            prmAccount[1].FBE_Partner_Relationship__c = 'Titanium';
            prmAccount[1].FBE_FPRM_Partner_Reg_Status__c = 'Qualified';
            
            prmAccount[2].Name = 'DistributorAccount2';
            prmAccount[2].FBE_Partner__c = true;
            prmAccount[2].FBE_Partner_Type__c = 'Distributor';
            prmAccount[2].FBE_Partner_Relationship__c = 'Titanium';
            prmAccount[2].FBE_FPRM_Partner_Reg_Status__c = 'Registered';
            
            prmAccount[3].Name = 'DMP2';
            prmAccount[3].FBE_Partner__c = true;
            prmAccount[3].FBE_Partner_Type__c = 'Disty Managed';
            prmAccount[3].FBE_Partner_Relationship__c = 'Titanium';
            prmAccount[3].FBE_FPRM_Partner_Reg_Status__c = 'Qualified';
            insert prmAccount;
            
            //Get Partner Profiles
            Profile distributorProfile = [Select Id, Name from profile where Name='FBE FPRM Partner Distributor'];
            Profile DMPProfile = [Select Id, Name from profile where Name='FBE FPRM Partner Disty Managed'];
            
            List<Contact> prmContacts = new List<Contact>();
            contact c4= new contact(FirstName = 'testDisty', LastName = 'PRM',email='noemail4@dell.com', accountId = prmAccount[0].id, Phone = '9876896515');
            prmContacts.add(c4);
            
            contact c5= new contact(FirstName = 'testDMP', LastName = 'PRM',email='noemail5@dell.com', accountId = prmAccount[0].id, FBE_FPRM_Reseller_Account__c = prmAccount[1].id, Phone = '9876896518');
            prmContacts.add(c5);
            insert prmContacts;
            
            //Create Users for these Contacts
            List<User> userList = new List<User>();
            String uniqueUserName = 'adminuser' + DateTime.now().getTime();
            User user1 = new User(
                firstname = 'TestDistributor', 
                         lastName = 'User1', 
                         email = 'noemail4@dell.com', 
                         Username = uniqueUserName + '@test1.com'+'.fprm', 
                         EmailEncodingKey = 'ISO-8859-1', 
                         Alias = 'di1user1', 
                         TimeZoneSidKey = 'America/Los_Angeles', 
                         LocaleSidKey = 'en_US', 
                         LanguageLocaleKey = 'en_US', 
                         ProfileId = distributorProfile.Id,
                         ContactId = c4.Id,
                         FBE_FPRM_OnlineRole__c = 'Site Admin'
            );            
            userList.add(user1);
            User user2 = new User(
                firstname = 'TestDMP', 
                lastName = 'User2', 
                email = 'noemail5@dell.com', 
                Username = uniqueUserName + '@test2.com'+'.fprm', 
                EmailEncodingKey = 'ISO-8859-1', 
                Alias = 'dm2user2', 
                TimeZoneSidKey = 'America/Los_Angeles', 
                LocaleSidKey = 'en_US', 
                LanguageLocaleKey = 'en_US', 
                ProfileId = DMPProfile.Id,
                ContactId = c5.Id,
                FBE_FPRM_OnlineRole__c = 'Disty Managed Sales Rep All Opty'
            );
            userList.add(user2); 
            insert userList;         
        }
    }
    
     //Method for before insert unit test
     @isTest
     private static void beforeinsert_test(){
         //User u1=SRVS_CreateTestDataFactory.createUser('Service Integration Profile');
         User u1=SRVS_CreateTestDataFactory.createUser('PSA Technical Resource');
         system.runAs(u1){
         Test.startTest();
         List<contact> cts=[select id,AccountId,Account_Id__c from contact limit 3];
         List<contact> ct=[select id,AccountId,Account_Id__c,Primary_Phone__c from contact where LastName='lastName1'];           
         Test.stopTest();
         //system.assertEquals(3,cts.size());
         }    
     }
    
     //Method for before update unit test
     @isTest
     private static void beforeupdate_test(){
         User u2=SRVS_CreateTestDataFactory.createUser('System Administrator');
         system.runAs(u2){
         Test.startTest();
         List<contact> cs=[select id,AccountId,Account_Id__c from contact limit 3];
         for(integer i=0;i<cs.size();i++)
         {
                if(cs[i].AccountId!=cs[i].Account_Id__c)
                {
                    cs[i].Account_Id__c=cs[i].AccountId;
                }  
             
         }      
         //ContactTriggerHandler.beforeUpdate(cs);
         update cs;
         Test.stopTest();
         //system.assertEquals(3,cs.size());
     }
     }
    @isTest
     private static void updateTimeZoneOnSAtest(){
         User u2=SRVS_CreateTestDataFactory.createUser('System Administrator');
         system.runAs(u2){
         Test.startTest();
             List<Contact> updateConts = new List<Contact>();
         List<contact> cs=[select id,FirstName,AccountId,TimeZone__c from contact where LastName='lastName1'];
             for(contact c :cs){
                 c.TimeZone__c = 'Central Time';
                 updateConts.add(c);
             }
             update updateConts;
         Test.stopTest();
         //system.assertEquals(3,cs.size());
     }
     }
    
    @isTest
    private static void preventCDLfieldupdatetest(){
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){
            List<Account> accountList = FBE_Test_Utility.createAccount(1);
            insert accountList;
        Profile p = [SELECT Id FROM Profile WHERE Name ='PSA Technical Resource'];
            List<User> userList = new List<User>();
            User u1 = new User( email='Test__0@email.com',
                               profileid = p.id, 
                               UserName='trfouser@testorg.com' , 
                               Alias = 'GDS',
                               TimeZoneSidKey='America/New_York',
                               EmailEncodingKey='ISO-8859-1',
                               LocaleSidKey='en_US', 
                               LanguageLocaleKey='en_US',               
                               PortalRole = 'Manager',
                               FirstName = 'Lee',
                               LastName = 'Min Ho',
                               EmployeeNumber ='1234',
                               FBE_FPRM_OnlineRole__c = 'Site Admin');
            
            userList.add(u1);
        insert userList;
        
        List<Contact> objContact = [SELECT Id FROM Contact WHERE pse__Salesforce_User__c = :userList[0].Id];
            
        List<ServiceResource> objResource = [SELECT Id FROM ServiceResource WHERE RelatedRecordId =: userList[0].Id];
       
        List<OperatingHours> ohList = FBE_Test_Utility.createOperatingHours();
        insert ohList;
            
        List <ServiceTerritory> stList = FBE_Test_Utility.createServiceTerritory(ohList);
        insert stList;
       
        List<ServiceTerritoryMember> stmList = FBE_Test_Utility.createServiceTerritoryMember(stList, objResource);
        insert stmList;
    }
    }
    
    //[Deloitte Consulting - Abhishek K] 02/09/2021 : Added new method to test following methods in ContactTriggerHandler: 
    //                                                updateSharingAccount, accountContactRelOnInsert, accountContactRelOnUpdate
    @isTest
    private static void testAccountContactAndSharingAccUpdates(){
        //Login with Integration User Profile to create Account
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){
            List<Account> prmAccList = [SELECT Id, Name, FBE_Partner_Type__c FROM Account WHERE NAME IN ('DistributorAccount2','DMP2')];
            List<Contact> prmContactList = [SELECT Id, FirstName, AccountId, FBE_FPRM_Reseller_Account__c
                                            FROM Contact WHERE FirstName IN ('testDisty','testDMP')];
            List<Contact> prmContactListUpdate = new List<Contact>();
            for(Contact con: prmContactList){
                System.debug('At Contact: '+con.FirstName);
                for(Account acc : prmAccList){
                    if(con.FirstName == 'testDisty' &&  acc.FBE_Partner_Type__c == 'Distributor'){
                        System.debug('Updating contact '+con.FirstName+' with Account: '+acc.Name);
                        con.AccountId = acc.Id;
                        prmContactListUpdate.add(con);
                    }
                    if(con.FirstName == 'testDMP' && acc.FBE_Partner_Type__c == 'Disty Managed'){
                         System.debug('Updating contact '+con.FirstName+' with Account: '+acc.Name);
                        con.FBE_FPRM_Reseller_Account__c = acc.Id;
                        prmContactListUpdate.add(con);
                    }
                }   
            }
           update prmContactList;    
        }
    }
}