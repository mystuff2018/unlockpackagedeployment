/**************
 * @ Class Name        : FBE_FPRM_RelatedListControllerTest
 * @ Description       : This class is created to test code coverage for -  FBE_FRPM_RelatedListController class.
 *                       Created as part of Story #10138414. This script tests for RelatedListController with the Account / Contact Object
 * @ CreatedBy         : Deloitte
 * @ CreatedOn         : 02-24-2020
 * @ Modification Log  : Version 1.0 - [Abhishek Kawle] : Initially created script
*********/

@isTest
private class FBE_FPRM_RelatedListControllerTest {
    //Method for test data setup
    @TestSetup
    static void setUpData() {
        //Login with Integration User Profile to create Account
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        
        Profile adminProfile = [Select Id,Name from profile where Name='System Administrator' limit 1];
        List<FBE_FPRM_Transfer_Deal_Check__c>customSettingList = new List<FBE_FPRM_Transfer_Deal_Check__c>();
        
        FBE_FPRM_Transfer_Deal_Check__c test = new FBE_FPRM_Transfer_Deal_Check__c(
                                      SetupOwnerId = adminProfile.Id, Name = 'Test',Is_Transfer_Deal__c = true); 
		customSettingList.add(test); 
        
        FBE_FPRM_Transfer_Deal_Check__c settings = FBE_FPRM_Transfer_Deal_Check__c.getOrgDefaults();
        settings.Is_Transfer_Deal__c = false;
        customSettingList.add(settings); 
        UPSERT customSettingList;
        
        system.runAs(loginUser[0]){
            List<Account> prmAccountList = FBE_Test_Utility.createAccount(3);
            prmAccountList[0].Name = 'DistributorAccount1';
            prmAccountList[0].FBE_Partner__c = true;
            prmAccountList[0].FBE_Partner_Type__c = 'Distributor';
            prmAccountList[0].FBE_Partner_Relationship__c = 'Titanium';
            prmAccountList[0].FBE_FPRM_Partner_Reg_Status__c = 'Registered';
            
            prmAccountList[1].Name = 'DMP1';
            prmAccountList[1].FBE_Partner__c = true;
            prmAccountList[1].FBE_Partner_Type__c = 'Disty Managed';
            prmAccountList[1].FBE_Partner_Relationship__c = 'Titanium';
            prmAccountList[1].FBE_FPRM_Partner_Reg_Status__c = 'Qualified';
            
            prmAccountList[2].Name = 'DMP2';
            prmAccountList[2].FBE_Partner__c = true;
            prmAccountList[2].FBE_Partner_Type__c = 'Disty Managed';
            prmAccountList[2].FBE_Partner_Relationship__c = 'Titanium';
            prmAccountList[2].FBE_FPRM_Partner_Reg_Status__c = 'Qualified';
            
            insert prmAccountList;
            
            List<Contact> prmContacts = FBE_Test_Utility.createContact(8, prmAccountList[0].Id);
            prmContacts[3].FBE_FPRM_Reseller_Account__c = prmAccountList[1].Id;
            prmContacts[4].FBE_FPRM_Reseller_Account__c = prmAccountList[1].Id;
            prmContacts[5].FBE_FPRM_Reseller_Account__c = prmAccountList[1].Id;
            prmContacts[6].AccountId = prmAccountList[1].Id;
            prmContacts[7].AccountId = prmAccountList[1].Id;
            
            insert prmContacts;
            
            //Create 2 Users, 1 for each Partner profile 
            Profile distributorProfile = [Select Id, Name from profile where Name='FBE FPRM Partner Distributor'];
            Profile DMPProfile = [Select Id, Name from profile where Name='FBE FPRM Partner Disty Managed'];
            
            List<User> userList = new List<User>();
            String uniqueUserName = 'adminuser' + DateTime.now().getTime();
            User user1 = new User(
                firstname = 'TestDistributor', 
                lastName = 'User1', 
                email = prmContacts[0].Email, 
                Username = uniqueUserName + '@test1.com'+'.fprm', 
                EmailEncodingKey = 'ISO-8859-1', 
                Alias = 'di1user1', 
                TimeZoneSidKey = 'America/Los_Angeles', 
                LocaleSidKey = 'en_US', 
                LanguageLocaleKey = 'en_US', 
                ProfileId = distributorProfile.Id,
                ContactId = prmContacts[0].Id,
                FBE_FPRM_OnlineRole__c = 'Site Admin'
            );            
            userList.add(user1);
            User user2 = new User(
                firstname = 'TestDMP', 
                lastName = 'User2', 
                email = prmContacts[3].Email, 
                Username = uniqueUserName + '@test2.com'+'.fprm', 
                EmailEncodingKey = 'ISO-8859-1', 
                Alias = 'dm2user2', 
                TimeZoneSidKey = 'America/Los_Angeles', 
                LocaleSidKey = 'en_US', 
                LanguageLocaleKey = 'en_US', 
                ProfileId = DMPProfile.Id,
                ContactId = prmContacts[3].Id,
                FBE_FPRM_OnlineRole__c = 'Disty Managed Site Admin'
            );
            userList.add(user2);
            insert userList;         
            
            List<Account_Affiliation__c> accAffList = new List<Account_Affiliation__c>();
            Account_Affiliation__c aff1 = new Account_Affiliation__c();
            aff1.FBE_Account__c = prmAccountList[0].Id;
            aff1.FBE_Affilitated_Account__c = prmAccountList[1].Id;
            aff1.FBE_Relationship__c ='Disty Managed';
            aff1.FBE_Start_Date__c = System.today();
            accAffList.add(aff1);
            
            Account_Affiliation__c aff2 = new Account_Affiliation__c();
            aff2.FBE_Account__c = prmAccountList[0].Id;
            aff2.FBE_Affilitated_Account__c = prmAccountList[2].Id;
            aff2.FBE_Relationship__c ='Disty Managed';
            aff2.FBE_Start_Date__c = System.today();
            accAffList.add(aff2);
            
            Account_Affiliation__c aff3 = new Account_Affiliation__c();
            aff3.FBE_Account__c = prmAccountList[1].Id;
            aff3.FBE_Affilitated_Account__c = prmAccountList[0].Id;
            aff3.FBE_Relationship__c ='Distributor';
            aff3.FBE_Start_Date__c = System.today() -1;
            accAffList.add(aff3);
            
            insert accAffList;
        }
    }
    
    //Method to Test for Default Queries and with Visibility Flag, Offset Parameter
    @isTest
    private static void testDefaultQuery(){
        //Fetch required test data
        Account acc = [SELECT Id FROM Account WHERE Name = 'DistributorAccount1' LIMIT 1];
        List<Contact> conList = [SELECT Id FROM Contact WHERE AccountId =:acc.Id];
        User currentUser = [SELECT Id FROM User WHERE alias = 'di1user1' LIMIT 1];
        
        Map<String, Object> requestMap = new Map<String, Object>();
        requestMap.put(FBE_FPRM_RelatedListController.OBJAPINAME, 'Contact');
        requestMap.put(FBE_FPRM_RelatedListController.OBJFIELDS, 'Id, Name, Email, Phone, FBE_FPRM_Reseller_Flag__c,FBE_FPRM_Reseller_Account__r.Name');
        requestMap.put(FBE_FPRM_RelatedListController.NUMBER_OF_RECORDS_PARAM, 2);
        requestMap.put(FBE_FPRM_RelatedListController.CONDITION_FIELD_API_NAME, 'AccountId');
        requestMap.put(FBE_FPRM_RelatedListController.VIEW_ALL_RECORDS_FLAG, true);
        requestMap.put(FBE_FPRM_RelatedListController.RECORDID, acc.Id);
        requestMap.put(FBE_FPRM_RelatedListController.PRM_VISIBILITY_FLAG, false);
        requestMap.put(FBE_FPRM_RelatedListController.CURRENT_USER_ID, currentUser.Id);
        requestMap.put(FBE_FPRM_RelatedListController.AFFILIATIONS_FLAG, false);
        
        String jsonData = FBE_FPRM_RelatedListController.setContext(JSON.serialize(requestMap));
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(jsonData);
        List<Object> records = (List<Object>)responseMap.get(FBE_FPRM_RelatedListController.RECORDS);
        List<Object> allRecords = (List<Object>)responseMap.get(FBE_FPRM_RelatedListController.VIEW_ALL_TOTAL_ROWS);
        List<Object> recordNameList = (List<Object>)responseMap.get(FBE_FPRM_RelatedListController.RECORD_NAME);

        System.assert(!records.isEmpty());
        System.assert(!recordNameList.isEmpty());
        System.assertEquals(2, records.size());
        System.assertEquals(conList.size(), allRecords.size());
        
        //Invoke the controller with Visibility Flag = False and Offset = 0
        requestMap.put(FBE_FPRM_RelatedListController.VIEW_ALL_RECORDS_FLAG, false);
        requestMap.put(FBE_FPRM_RelatedListController.VIEW_ALL_OFFSET, 0);
        requestMap.put(FBE_FPRM_RelatedListController.VIEW_ALL_ROW_LIMIT, 2);
        jsonData = FBE_FPRM_RelatedListController.setContext(JSON.serialize(requestMap));
        responseMap = (Map<String, Object>)JSON.deserializeUntyped(jsonData);
        records = (List<Object>)responseMap.get(FBE_FPRM_RelatedListController.RECORDS);
        allRecords = (List<Object>)responseMap.get(FBE_FPRM_RelatedListController.VIEW_ALL_TOTAL_ROWS);
        
        System.assert(!records.isEmpty());
        System.assertEquals(2, records.size());
        System.assertEquals(conList.size(), allRecords.size());
        
        //Invoke the controller with Visibility Flag = False and Offset = 2
        requestMap.put(FBE_FPRM_RelatedListController.VIEW_ALL_RECORDS_FLAG, false);
        requestMap.put(FBE_FPRM_RelatedListController.VIEW_ALL_OFFSET, 2);
        requestMap.put(FBE_FPRM_RelatedListController.VIEW_ALL_ROW_LIMIT, 2);
        jsonData = FBE_FPRM_RelatedListController.setContext(JSON.serialize(requestMap));
        responseMap = (Map<String, Object>)JSON.deserializeUntyped(jsonData);
        records = (List<Object>)responseMap.get(FBE_FPRM_RelatedListController.RECORDS);
        allRecords = (List<Object>)responseMap.get(FBE_FPRM_RelatedListController.VIEW_ALL_TOTAL_ROWS);
        
        System.assert(!records.isEmpty());
        System.assertEquals(2, records.size());
        System.assertEquals(conList.size(), allRecords.size());
        
    }
    
    //Methods to Test for User Visibility. This script executes in two parts - one for the Distributor / Reseller Admin Profiles and other for Disty Managed
    @isTest
    private static void testUserVisibilityDistributor(){
        //Fetch required test data
        Account acc = [SELECT Id, Name, FBE_Partner_Type__c FROM Account WHERE NAME IN ('DistributorAccount1')];
        List<Contact> prmContactList = [SELECT Id FROM Contact WHERE AccountId =:acc.Id];
        User distributorUser = [SELECT Id, Profile.Name, FBE_FPRM_OnlineRole__c FROM User WHERE alias ='di1user1' LIMIT 1];
        
        //Test For Distributor / Reseller Site Admin User
        Map<String, Object> requestMap = new Map<String, Object>();
        requestMap.put(FBE_FPRM_RelatedListController.OBJAPINAME, 'Contact');
        requestMap.put(FBE_FPRM_RelatedListController.OBJFIELDS, 'Id, Name, Email, Phone, FBE_FPRM_Reseller_Flag__c,FBE_FPRM_Reseller_Account__r.Name');
        requestMap.put(FBE_FPRM_RelatedListController.NUMBER_OF_RECORDS_PARAM, 2);
        requestMap.put(FBE_FPRM_RelatedListController.CONDITION_FIELD_API_NAME, 'AccountId');
        requestMap.put(FBE_FPRM_RelatedListController.VIEW_ALL_RECORDS_FLAG, true);
        requestMap.put(FBE_FPRM_RelatedListController.RECORDID, acc.Id);
        requestMap.put(FBE_FPRM_RelatedListController.PRM_VISIBILITY_FLAG, true);
        requestMap.put(FBE_FPRM_RelatedListController.CURRENT_USER_ID, distributorUser.Id);
        requestMap.put(FBE_FPRM_RelatedListController.AFFILIATIONS_FLAG, false);
        
        String jsonData = FBE_FPRM_RelatedListController.setContext(JSON.serialize(requestMap));
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(jsonData);
        List<Object> records = (List<Object>)responseMap.get(FBE_FPRM_RelatedListController.RECORDS);
        List<Object> allRecords = (List<Object>)responseMap.get(FBE_FPRM_RelatedListController.VIEW_ALL_TOTAL_ROWS);
        List<Object> recordNameList = (List<Object>)responseMap.get(FBE_FPRM_RelatedListController.RECORD_NAME);
        
        System.assert(!records.isEmpty());
        System.assert(!recordNameList.isEmpty());
        System.assertEquals(2, records.size());
        System.assertEquals(prmContactList.size(), allRecords.size());
        
        //Invoke the controller with Visibility Flag = False and Offset = 0
        requestMap.put(FBE_FPRM_RelatedListController.VIEW_ALL_RECORDS_FLAG, false);
        requestMap.put(FBE_FPRM_RelatedListController.VIEW_ALL_OFFSET, 0);
        requestMap.put(FBE_FPRM_RelatedListController.VIEW_ALL_ROW_LIMIT, 4);
        jsonData = FBE_FPRM_RelatedListController.setContext(JSON.serialize(requestMap));
        responseMap = (Map<String, Object>)JSON.deserializeUntyped(jsonData);
        records = (List<Object>)responseMap.get(FBE_FPRM_RelatedListController.RECORDS);
        allRecords = (List<Object>)responseMap.get(FBE_FPRM_RelatedListController.VIEW_ALL_TOTAL_ROWS);
        
        System.assert(!records.isEmpty());
        System.assertEquals(4, records.size());
        System.assertEquals(prmContactList.size(), allRecords.size());
        
        //Invoke the controller with Visibility Flag = False and Offset = 2
        requestMap.put(FBE_FPRM_RelatedListController.VIEW_ALL_RECORDS_FLAG, false);
        requestMap.put(FBE_FPRM_RelatedListController.VIEW_ALL_OFFSET, 4);
        requestMap.put(FBE_FPRM_RelatedListController.VIEW_ALL_ROW_LIMIT, 4);
        jsonData = FBE_FPRM_RelatedListController.setContext(JSON.serialize(requestMap));
        responseMap = (Map<String, Object>)JSON.deserializeUntyped(jsonData);
        records = (List<Object>)responseMap.get(FBE_FPRM_RelatedListController.RECORDS);
        allRecords = (List<Object>)responseMap.get(FBE_FPRM_RelatedListController.VIEW_ALL_TOTAL_ROWS);
        
        System.assert(!records.isEmpty());
        System.assertEquals(2, records.size());
        System.assertEquals(prmContactList.size(), allRecords.size());
    }
    
    @isTest
    private static void testUserVisibilityDMP(){
        //Fetch required test data
        Account acc = [SELECT Id, Name, FBE_Partner_Type__c FROM Account WHERE NAME IN ('DMP1')];
        List<Contact> prmContactList = [SELECT Id FROM Contact WHERE AccountId =:acc.Id OR FBE_FPRM_Reseller_Account__c =:acc.Id];
        User dMPUser = [SELECT Id, Profile.Name, FBE_FPRM_OnlineRole__c FROM User WHERE alias ='dm2user2' LIMIT 1];
        
        //Test For Distributor / Reseller Site Admin User
        Map<String, Object> requestMap = new Map<String, Object>();
        requestMap.put(FBE_FPRM_RelatedListController.OBJAPINAME, 'Contact');
        requestMap.put(FBE_FPRM_RelatedListController.OBJFIELDS, 'Id, Name, Email, Phone, FBE_FPRM_Reseller_Flag__c,FBE_FPRM_Reseller_Account__r.Name');
        requestMap.put(FBE_FPRM_RelatedListController.NUMBER_OF_RECORDS_PARAM, 2);
        requestMap.put(FBE_FPRM_RelatedListController.CONDITION_FIELD_API_NAME, 'AccountId');
        requestMap.put(FBE_FPRM_RelatedListController.VIEW_ALL_RECORDS_FLAG, true);
        requestMap.put(FBE_FPRM_RelatedListController.RECORDID, acc.Id);
        requestMap.put(FBE_FPRM_RelatedListController.PRM_VISIBILITY_FLAG, true);
        requestMap.put(FBE_FPRM_RelatedListController.CURRENT_USER_ID, dMPUser.Id);
        requestMap.put(FBE_FPRM_RelatedListController.AFFILIATIONS_FLAG, false);
        
        String jsonData = FBE_FPRM_RelatedListController.setContext(JSON.serialize(requestMap));
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(jsonData);
        List<Object> records = (List<Object>)responseMap.get(FBE_FPRM_RelatedListController.RECORDS);
        List<Object> allRecords = (List<Object>)responseMap.get(FBE_FPRM_RelatedListController.VIEW_ALL_TOTAL_ROWS);
        List<Object> recordNameList = (List<Object>)responseMap.get(FBE_FPRM_RelatedListController.RECORD_NAME);
        
        System.assert(!records.isEmpty());
        System.assert(!recordNameList.isEmpty());
        System.assertEquals(2, records.size());
        System.assertEquals(prmContactList.size(), allRecords.size());
        
        //Invoke the controller with Visibility Flag = False and Offset = 0
        requestMap.put(FBE_FPRM_RelatedListController.VIEW_ALL_RECORDS_FLAG, false);
        requestMap.put(FBE_FPRM_RelatedListController.VIEW_ALL_OFFSET, 0);
        requestMap.put(FBE_FPRM_RelatedListController.VIEW_ALL_ROW_LIMIT, 4);
        jsonData = FBE_FPRM_RelatedListController.setContext(JSON.serialize(requestMap));
        responseMap = (Map<String, Object>)JSON.deserializeUntyped(jsonData);
        records = (List<Object>)responseMap.get(FBE_FPRM_RelatedListController.RECORDS);
        allRecords = (List<Object>)responseMap.get(FBE_FPRM_RelatedListController.VIEW_ALL_TOTAL_ROWS);
        
        System.assert(!records.isEmpty());
        System.assertEquals(4, records.size());
        System.assertEquals(prmContactList.size(), allRecords.size());
        
        //Invoke the controller with Visibility Flag = False and Offset = 4
        requestMap.put(FBE_FPRM_RelatedListController.VIEW_ALL_RECORDS_FLAG, false);
        requestMap.put(FBE_FPRM_RelatedListController.VIEW_ALL_OFFSET, 4);
        requestMap.put(FBE_FPRM_RelatedListController.VIEW_ALL_ROW_LIMIT, 5);
        jsonData = FBE_FPRM_RelatedListController.setContext(JSON.serialize(requestMap));
        responseMap = (Map<String, Object>)JSON.deserializeUntyped(jsonData);
        records = (List<Object>)responseMap.get(FBE_FPRM_RelatedListController.RECORDS);
        allRecords = (List<Object>)responseMap.get(FBE_FPRM_RelatedListController.VIEW_ALL_TOTAL_ROWS);
        
        System.assert(!records.isEmpty());
        System.assertEquals(1, records.size());
        System.assertEquals(prmContactList.size(), allRecords.size());
    }
    
    //Methods to Test for Account Affiliations. This script executes in two parts - one for the Distributor Admin Profiles and other for Disty Managed
    @isTest
    private static void testAffiliationsDistributor(){
        Account acc = [SELECT Id, Name, FBE_Partner_Type__c FROM Account WHERE NAME IN ('DistributorAccount1')];
        User distributorUser = [SELECT Id, Profile.Name, FBE_FPRM_OnlineRole__c FROM User WHERE alias ='di1user1' LIMIT 1];
        List<Account_Affiliation__c> affList = [SELECT Id FROM Account_Affiliation__c WHERE FBE_Account__c =: acc.Id AND FBE_Start_Date__c <= Today AND (FBE_End_Date__c >= Today OR FBE_End_Date__c = null)];
        
         //Test For Distributor Site Admin User
        Map<String, Object> requestMap = new Map<String, Object>();
        requestMap.put(FBE_FPRM_RelatedListController.OBJAPINAME, 'Account_Affiliation__c');
        requestMap.put(FBE_FPRM_RelatedListController.OBJFIELDS, 'Id, FBE_Affilitated_Account__c, FBE_Affilitated_Account__r.Name, FBE_Relationship__c');
        requestMap.put(FBE_FPRM_RelatedListController.NUMBER_OF_RECORDS_PARAM, 2);
        requestMap.put(FBE_FPRM_RelatedListController.CONDITION_FIELD_API_NAME, 'FBE_Account__c');
        requestMap.put(FBE_FPRM_RelatedListController.VIEW_ALL_RECORDS_FLAG, true);
        requestMap.put(FBE_FPRM_RelatedListController.RECORDID, acc.Id);
        requestMap.put(FBE_FPRM_RelatedListController.PRM_VISIBILITY_FLAG, true);
        requestMap.put(FBE_FPRM_RelatedListController.CURRENT_USER_ID, distributorUser.Id);
        requestMap.put(FBE_FPRM_RelatedListController.AFFILIATIONS_FLAG, true);
        
        String jsonData = FBE_FPRM_RelatedListController.setContext(JSON.serialize(requestMap));
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(jsonData);
        List<Object> records = (List<Object>)responseMap.get(FBE_FPRM_RelatedListController.RECORDS);
        List<Object> allRecords = (List<Object>)responseMap.get(FBE_FPRM_RelatedListController.VIEW_ALL_TOTAL_ROWS);
        List<Object> recordNameList = (List<Object>)responseMap.get(FBE_FPRM_RelatedListController.RECORD_NAME);
        
        System.assert(!records.isEmpty());
        System.assert(!recordNameList.isEmpty());
        System.assertEquals(2, records.size());
        System.assertEquals(affList.size(), allRecords.size());
        
                //Invoke the controller with Visibility Flag = False and Offset = 0
        requestMap.put(FBE_FPRM_RelatedListController.VIEW_ALL_RECORDS_FLAG, false);
        requestMap.put(FBE_FPRM_RelatedListController.VIEW_ALL_OFFSET, 0);
        requestMap.put(FBE_FPRM_RelatedListController.VIEW_ALL_ROW_LIMIT, 4);
        jsonData = FBE_FPRM_RelatedListController.setContext(JSON.serialize(requestMap));
        responseMap = (Map<String, Object>)JSON.deserializeUntyped(jsonData);
        records = (List<Object>)responseMap.get(FBE_FPRM_RelatedListController.RECORDS);
        allRecords = (List<Object>)responseMap.get(FBE_FPRM_RelatedListController.VIEW_ALL_TOTAL_ROWS);
        
        System.assert(!records.isEmpty());
        System.assertEquals(2, records.size());
        System.assertEquals(affList.size(), allRecords.size());
        
        //Invoke the controller with Visibility Flag = False and Offset = 2
        requestMap.put(FBE_FPRM_RelatedListController.VIEW_ALL_RECORDS_FLAG, false);
        requestMap.put(FBE_FPRM_RelatedListController.VIEW_ALL_OFFSET, 1);
        requestMap.put(FBE_FPRM_RelatedListController.VIEW_ALL_ROW_LIMIT, 4);
        jsonData = FBE_FPRM_RelatedListController.setContext(JSON.serialize(requestMap));
        responseMap = (Map<String, Object>)JSON.deserializeUntyped(jsonData);
        records = (List<Object>)responseMap.get(FBE_FPRM_RelatedListController.RECORDS);
        allRecords = (List<Object>)responseMap.get(FBE_FPRM_RelatedListController.VIEW_ALL_TOTAL_ROWS);
        
        System.assert(!records.isEmpty());
        System.assertEquals(1, records.size());
        System.assertEquals(affList.size(), allRecords.size());
    }
    
        @isTest
    private static void testAffiliationsDMP(){
        Account acc = [SELECT Id, Name, FBE_Partner_Type__c FROM Account WHERE NAME IN ('DMP1')];
        User dMPUser = [SELECT Id, Profile.Name, FBE_FPRM_OnlineRole__c, Contact.AccountId, Contact.FBE_FPRM_Reseller_Account__c FROM User WHERE alias ='dm2user2' LIMIT 1];
       
        String contactResellerAcc = dMPUser.Contact.FBE_FPRM_Reseller_Account__c;
        String contactAccount = dMPUser.Contact.AccountId;
        List<Account_Affiliation__c> affList = [SELECT Id FROM Account_Affiliation__c WHERE FBE_Account__c =: acc.Id AND (FBE_Affilitated_Account__c =:contactResellerAcc OR FBE_Affilitated_Account__c =:contactAccount) AND FBE_Start_Date__c <= Today AND (FBE_End_Date__c >= Today OR FBE_End_Date__c = null)];
        
         //Test For DMP
        Map<String, Object> requestMap = new Map<String, Object>();
        requestMap.put(FBE_FPRM_RelatedListController.OBJAPINAME, 'Account_Affiliation__c');
        requestMap.put(FBE_FPRM_RelatedListController.OBJFIELDS, 'Id, FBE_Affilitated_Account__c, FBE_Affilitated_Account__r.Name, FBE_Relationship__c');
        requestMap.put(FBE_FPRM_RelatedListController.NUMBER_OF_RECORDS_PARAM, 2);
        requestMap.put(FBE_FPRM_RelatedListController.CONDITION_FIELD_API_NAME, 'FBE_Account__c');
        requestMap.put(FBE_FPRM_RelatedListController.VIEW_ALL_RECORDS_FLAG, true);
        requestMap.put(FBE_FPRM_RelatedListController.RECORDID, acc.Id);
        requestMap.put(FBE_FPRM_RelatedListController.PRM_VISIBILITY_FLAG, true);
        requestMap.put(FBE_FPRM_RelatedListController.CURRENT_USER_ID, dMPUser.Id);
        requestMap.put(FBE_FPRM_RelatedListController.AFFILIATIONS_FLAG, true);
        
        String jsonData = FBE_FPRM_RelatedListController.setContext(JSON.serialize(requestMap));
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(jsonData);
        List<Object> records = (List<Object>)responseMap.get(FBE_FPRM_RelatedListController.RECORDS);
        List<Object> allRecords = (List<Object>)responseMap.get(FBE_FPRM_RelatedListController.VIEW_ALL_TOTAL_ROWS);
        List<Object> recordNameList = (List<Object>)responseMap.get(FBE_FPRM_RelatedListController.RECORD_NAME);
        
        System.assert(!records.isEmpty());
        System.assert(!recordNameList.isEmpty());
        System.assertEquals(1, records.size());
        System.assertEquals(affList.size(), allRecords.size());
        
                //Invoke the controller with Visibility Flag = False and Offset = 0
        requestMap.put(FBE_FPRM_RelatedListController.VIEW_ALL_RECORDS_FLAG, false);
        requestMap.put(FBE_FPRM_RelatedListController.VIEW_ALL_OFFSET, 0);
        requestMap.put(FBE_FPRM_RelatedListController.VIEW_ALL_ROW_LIMIT, 4);
        jsonData = FBE_FPRM_RelatedListController.setContext(JSON.serialize(requestMap));
        responseMap = (Map<String, Object>)JSON.deserializeUntyped(jsonData);
        records = (List<Object>)responseMap.get(FBE_FPRM_RelatedListController.RECORDS);
        allRecords = (List<Object>)responseMap.get(FBE_FPRM_RelatedListController.VIEW_ALL_TOTAL_ROWS);
        
        System.assert(!records.isEmpty());
        System.assertEquals(1, records.size());
        System.assertEquals(affList.size(), allRecords.size());
        
        //Invoke the controller with Visibility Flag = False and Offset = 2
        requestMap.put(FBE_FPRM_RelatedListController.VIEW_ALL_RECORDS_FLAG, false);
        requestMap.put(FBE_FPRM_RelatedListController.VIEW_ALL_OFFSET, 1);
        requestMap.put(FBE_FPRM_RelatedListController.VIEW_ALL_ROW_LIMIT, 4);
        jsonData = FBE_FPRM_RelatedListController.setContext(JSON.serialize(requestMap));
        responseMap = (Map<String, Object>)JSON.deserializeUntyped(jsonData);
        records = (List<Object>)responseMap.get(FBE_FPRM_RelatedListController.RECORDS);
        allRecords = (List<Object>)responseMap.get(FBE_FPRM_RelatedListController.VIEW_ALL_TOTAL_ROWS);
        
        System.assert(records.isEmpty());
        System.assertEquals(0, records.size());
        System.assertEquals(affList.size(), allRecords.size());
    }
}