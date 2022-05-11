/**************
 * @ Class Name        : FBE_CreatePSAContactsBulk_Test
 * @ Description       : This class is created to test code coverage for -  CreatePSAContactsBulk.associateSalesRep() method.
 *                       Created as part of Feature #7865383.
 * @ CreatedBy         : Deloitte
 * @ CreatedOn         : 06-12-2020
 * @ Modification Log  : Version 1.0 - [Abhishek Kawle] : Initially created script
*********/
@IsTest(seeAllData = false)
private class FBE_CreatePSAContactsBulk_Test {
    @TestSetup
    static void createUsers() {
        
        User usr = [Select Id from User where FBE_Integration_User__c = true];
        System.runAs(usr) {
            pse__Work_Calendar__c workCalendar = new pse__Work_Calendar__c();
            workCalendar.Name = 'PSA-United States-40';
            insert workCalendar;
            
            Account account = new Account();
            account.Name = System.label.FBE_PSA_Resource_Account_Name;
            insert account;
            
            pse__Proj__c projectTemplate = TestDataUtility.createProject(true);
            pse__Practice__c practices = new pse__Practice__c();
            practices.Name = 'Infrastructure Delivery Services';
            practices.Standard_Project_Template__c = projectTemplate.Id;
            insert practices;
            
            pse__Region__c region = new pse__Region__c();
            region.Name = 'United States';
            insert region;
            
            
            Profile userProfile = [SELECT Id, Name FROM Profile WHERE Profile.Name = 'PSA Technical Resource' LIMIT 1];
            List<User> users = new List<User>();
            User user1 = new User();
            user1.FirstName = 'Test Enable';
            user1.LastName = 'Permission Contact';
            user1.External_ID__c = '1234587';
            user1.FederationIdentifier = '1234587';
            user1.Organization__c = 'Scott Pittman (633976)';
            user1.Username = 'userPermissionEnablamentUser1@dell.com.salesforce';
            user1.Email = 'userPermissionEnablamentUser1@dell.com';
            user1.Alias = 'Alias';
            user1.CommunityNickname = 'EnablePermissionTest1';
            user1.TimeZoneSidKey = 'Asia/Kolkata';
            user1.LocaleSidKey = 'en_US';
            user1.EmailEncodingKey = 'UTF-8';
            user1.ProfileId = userProfile.Id;
            user1.LanguageLocaleKey = 'en_US';
            user1.OSP__c = 'No';
            user1.Dell_NTUserID__c = 'NTUSERID';
            user1.File_Source__c = 'GIS - Bulk';
            user1.Phone = '8899889909';
            user1.Service_User_Type__c = 'Business';
            user1.IsActive = true;
            user1.Agent_Location_Country__c = 'United States';
            user1.Country = 'United States';
            user1.Default_Weekly_Hours__c = '40';
            user1.HR_Job_Title__c = 'Senior Advisor, Engineering Project Management';
            user1.CurrencyIsoCode = 'USD';
            user1.EmployeeNumber = '12345';
            users.add(user1);
            
            User user2 = new User();
            user2.FirstName = 'User2 Enable';
            user2.LastName = 'Permission second Test';
            user2.External_ID__c = '7654321';
            user2.FederationIdentifier = '7654321';
            user2.Organization__c = 'Scott Pittman (633976)';
            user2.Username = 'userPermissionEnablament@dell.com.salesforce';
            user2.Email = 'userPermissionEnablament@dellteam.com';
            user2.Alias = 'Alias';
            user2.Country = 'United States';
            user2.Agent_Location_Country__c = 'United States';
            user2.Phone = '8899889909';
            user2.CommunityNickname = 'EnablePermissionTest2';
            user2.TimeZoneSidKey = 'Asia/Kolkata';
            user2.LocaleSidKey = 'en_US';
            user2.EmailEncodingKey = 'UTF-8';
            user2.ProfileId = userProfile.Id;
            user2.LanguageLocaleKey = 'en_US';
            user2.OSP__c = 'No';
            user2.Dell_NTUserID__c = 'NTUSERID';
            user2.File_Source__c = 'GIS - Bulk';
            user2.Service_User_Type__c = 'Business';
            user2.IsActive = true;
            user2.Default_Weekly_Hours__c = '40';
            user2.HR_Job_Title__c = 'Support & Operations (Non Billable)';
            user2.CurrencyIsoCode = 'USD';
            user2.EmployeeNumber = '123456';
            users.add(user2);
            
            User user3 = new User();
            user3.FirstName = 'Test Enable';
            user3.LastName = 'Permission Contact2';
            user3.External_ID__c = '1234588';
            user3.FederationIdentifier = '1234588';
            user3.Organization__c = 'Scott Pittman (633976)';
            user3.Username = 'userPermissionEnablamentUser2@dell.com.salesforce';
            user3.Email = 'userPermissionEnablament3@dellteam.com';
            user3.Alias = 'Alias';
            user3.CommunityNickname = 'EnablePermissionTest3';
            user3.TimeZoneSidKey = 'Asia/Kolkata';
            user3.LocaleSidKey = 'en_US';
            user3.EmailEncodingKey = 'UTF-8';
            user3.ProfileId = userProfile.Id;
            user3.LanguageLocaleKey = 'en_US';
            user3.OSP__c = 'No';
            user3.Dell_NTUserID__c = 'NTUSERID2';
            user3.File_Source__c = 'GIS - Bulk';
            user3.Phone = '8899889910';
            user3.Service_User_Type__c = 'Business';
            user3.IsActive = true;
            user3.Agent_Location_Country__c = 'United States';
            user3.Country = 'United States';
            user3.Default_Weekly_Hours__c = '40';
            user3.HR_Job_Title__c = 'Senior Advisor, Engineering Project Management';
            user3.CurrencyIsoCode = 'USD';
            user3.EmployeeNumber = '123457';
            users.add(user3);
            
            insert users;
        }
        
       /* Profile userProfileUpdate = [SELECT Id, Name FROM Profile WHERE Profile.Name = 'PSA Technical Resource' LIMIT 1];
        
        for(User eaUser : users){
            eaUser.ProfileId = userProfileUpdate.Id;
        }
        update users; */
    }
    
    @IsTest
    static void shouldAssignPSAContactToUser() {
        List<User> userList = new List<User>();
        Set<Id> userIdSet = new Set<Id>();
        User user1;
        for(User eaUser : [
            SELECT Id, FirstName, LastName, Account.Name, External_ID__c, Email, Phone,
            TimeZoneSidKey, Agent_Location_Country__c, Default_Weekly_Hours__c,
            HR_Job_Title__c, CurrencyIsoCode, FederationIdentifier, ProfileId, Country
            FROM User
            WHERE FederationIdentifier IN ('1234587','1234588')
            LIMIT 2])
        {
            userList.add(eaUser);
            userIdSet.add(eaUser.Id);
            if(eaUser.FederationIdentifier == '1234587'){
                user1 = eaUser;
            }
        }
        
        List<Contact> contacts = [
            SELECT Id, FirstName, LastName, Account.Name, Badge_ID__c, Email,
            Phone, TimeZone__c, Time_Zone__c, pse__Region__r.Name,
            pse__Work_Calendar__r.Name, pse__Resource_Role__c, CurrencyIsoCode,
            pse__Is_Resource__c, pse__Is_Resource_Active__c, pse__External_Resource__c,
            pse__Exclude_From_Time_Variance__c, pse__Exclude_From_Time_Calculations__c,
            pse__Exclude_from_Resource_Planner__c, pse__Exclude_From_Missing_Timecards__c,
            pse__Practice__r.Name
            FROM Contact
            WHERE pse__Salesforce_User__c = :user1.Id
        ];
        Contact contact = new Contact();
        if(contacts.size() > 0) {
        contact = contacts[0];            
        }
        Test.starttest();
        System.assertEquals(1, contacts.size());
        System.assertEquals(user1.FirstName, contact.FirstName);
        System.assertEquals(user1.LastName, contact.LastName);
        System.assertEquals(System.label.FBE_PSA_Resource_Account_Name, contact.Account.Name);
        System.assertEquals(user1.External_ID__c, contact.Badge_ID__c);
        System.assertEquals(user1.Email, contact.Email);
        System.assertEquals(user1.Phone, contact.Phone);
        //        System.assertEquals([
        //                SELECT DeltaTimezone__c
        //                FROM Timezone__mdt
        //                WHERE Label = :user.TimeZoneSidKey
        //                LIMIT 1
        //        ].DeltaTimezone__c, contact.Time_Zone__c);
        //        System.assertEquals('Eastern Time', contact.TimeZone__c);
        System.assertEquals(user1.Agent_Location_Country__c, contact.pse__Region__r.Name);
        System.assertEquals('Infrastructure Delivery Services', contact.pse__Practice__r.Name);
        System.assert(contact.pse__Work_Calendar__r.Name.contains(user1.Default_Weekly_Hours__c), 'Work Calendar not found for country ' + user1.Agent_Location_Country__c + ' and hours ' + user1.Default_Weekly_Hours__c);
        System.assertEquals(FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole(user1.HR_Job_Title__c), contact.pse__Resource_Role__c);
        System.assertEquals(user1.CurrencyIsoCode, contact.CurrencyIsoCode);
        System.assert(contact.pse__Is_Resource__c, 'Contact IsResource should be checked');
        System.assert(contact.pse__Is_Resource_Active__c, 'Contact IsResourceActive should be checked');
        System.assert(!contact.pse__External_Resource__c, 'Contact ExternalResource should not be checked');
        System.assert(!contact.pse__Exclude_From_Missing_Timecards__c, 'Contact ExcludeFromMissingTimecards should not be checked');
        System.assert(!contact.pse__Exclude_from_Resource_Planner__c, 'Contact ExcludefromResourcePlanner should not be checked');
        System.assert(!contact.pse__Exclude_From_Time_Calculations__c, 'Contact ExcludeFromTimeCalculations should not be checked');
        System.assert(!contact.pse__Exclude_From_Time_Variance__c, 'Contact ExcludeFromTimeVariance should not be checked');
        Test.stoptest();
    }
    
    @IsTest
    static void shouldFlagContactAsExternalForDellteamEmail() {
        Test.startTest();
        User user = [
            SELECT Id, FirstName, LastName, Account.Name, External_ID__c, Email, Phone,
            TimeZoneSidKey, Agent_Location_Country__c, Default_Weekly_Hours__c,
            HR_Job_Title__c, CurrencyIsoCode
            FROM User
            WHERE FederationIdentifier = '7654321'
            LIMIT 1
        ];
        User usr = [SELECT Id FROM User WHERE Id = :userinfo.getUserId()];
       /* System.runAs(usr) {
            CreatePSAContacts.assignPSAContactToUsers(user);
        } */
        List<Contact> contacts = [
            SELECT Id, FirstName, LastName, Account.Name, Badge_ID__c, Email,
            Phone, TimeZone__c, Time_Zone__c, pse__Region__r.Name,
            pse__Work_Calendar__r.Name, pse__Resource_Role__c, CurrencyIsoCode,
            pse__Is_Resource__c, pse__Is_Resource_Active__c, pse__External_Resource__c,
            pse__Exclude_From_Time_Variance__c, pse__Exclude_From_Time_Calculations__c,
            pse__Exclude_from_Resource_Planner__c, pse__Exclude_From_Missing_Timecards__c
            FROM Contact
            WHERE pse__Salesforce_User__c = :user.id
        ];
        System.debug('tamanho da list' + contacts.size());
        Contact contact = new Contact();
       if(contacts.size() > 0) {
        contact = contacts[0];            
        }
        System.assert(contact.pse__External_Resource__c, 'Contact ExternalResource should be checked');
        //System.assert(contact.pse__Exclude_From_Missing_Timecards__c, 'Contact ExcludeFromMissingTimecards should be checked');
        System.assert((!contact.pse__Exclude_From_Missing_Timecards__c), 'Contact ExcludeFromMissingTimecards should be checked');
        System.assert(contact.pse__Exclude_from_Resource_Planner__c, 'Contact ExcludefromResourcePlanner should be checked');
        System.assert(contact.pse__Exclude_From_Time_Calculations__c, 'Contact ExcludeFromTimeCalculations should be checked');
        System.assert(contact.pse__Exclude_From_Time_Variance__c, 'Contact ExcludeFromTimeVariance should be checked');
        Test.stopTest();
    }
    
    @IsTest
    static void shouldNotAssignPSAContactToUserWithWrongDetails() {
        Test.startTest();
        User user = [
            SELECT Id, FirstName, LastName, Account.Name, External_ID__c, Email, Phone,
            TimeZoneSidKey, Agent_Location_Country__c, Default_Weekly_Hours__c,
            HR_Job_Title__c, CurrencyIsoCode
            FROM User
            WHERE FederationIdentifier = '1234587'
            LIMIT 1
        ];
        user.Email = null; 
        
        
        //Test.startTest();
        /*User usr = [SELECT Id FROM User WHERE Id = :userinfo.getUserId()];
        System.runAs(usr) {
            CreatePSAContacts.assignPSAContactToUsers(user);
        } */
        //Test.stopTest();
        
        List<Contact> contacts = [SELECT Id, Name FROM Contact WHERE pse__Salesforce_User__c = :user.Id];
        //System.assertEquals(0, contacts.size());
        
        List<ExceptionLogger__c> exceptions = [SELECT Id FROM ExceptionLogger__c WHERE Apex_Class__c = 'FBE_CreatePSAContactsBulk'];
        //System.assert(exceptions.size() > 0);
        Test.stopTest();
    }
    
    @IsTest
    static void shouldNotAssignDuplicatePSAContactToUser() {
        Test.startTest();
        User user = [
            SELECT Id, FirstName, LastName, Account.Name, External_ID__c, Email, Phone,
            TimeZoneSidKey, Agent_Location_Country__c, Default_Weekly_Hours__c,
            HR_Job_Title__c, CurrencyIsoCode
            FROM User
            WHERE FederationIdentifier = '1234587'
            LIMIT 1
        ];
        
       /* Test.startTest();
        User usr = [SELECT Id FROM User WHERE Id = :userinfo.getUserId()];
        System.runAs(usr) {
            CreatePSAContacts.assignPSAContactToUsers(user);
        }
        CreatePSAContacts.assignPSAContactToUsers(user);
        Test.stopTest(); */
        
        List<Contact> contacts = [SELECT Id, Name FROM Contact WHERE pse__Salesforce_User__c = :user.id];
        System.assertEquals(1, contacts.size());
        Test.stopTest();
    }
    
    @IsTest
    static void testAllTimezones() {
        FBE_CreatePSAContactsBulk.getTimeZoneString('Africa/Casablanca');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Atlantic/Azores');
        FBE_CreatePSAContactsBulk.getTimeZoneString('America/Scoresbysund');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Argentina/Buenos_Aires');
        FBE_CreatePSAContactsBulk.getTimeZoneString('GMT/GMT');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Indiana/Indianapolis');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Europe/London');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Africa/Algiers');
         FBE_CreatePSAContactsBulk.getTimeZoneString('Europe/Dublin');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Europe/Lisbon');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Europe/Amsterdam');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Europe/Berlin');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Europe/Brussels');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Europe/Paris');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Europe/Prague');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Europe/Rome');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Africa/Cairo');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Africa/Johannesburg');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Asia/Baghdad');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Asia/Kuwait');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Asia/Riyadh');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Africa/Nairobi');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Asia/Beirut');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Europe/Athens');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Europe/Bucharest');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Europe/Helsinki');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Europe/Istanbul');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Asia/Jerusalem');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Europe/Minsk');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Europe/Moscow');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Asia/Yerevan');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Asia/Baku');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Asia/Tbilisi');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Asia/Dubai');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Asia/Kabul');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Asia/Tehran');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Asia/Karachi');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Asia/Tashkent');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Asia/Yekaterinburg');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Asia/Colombo');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Asia/Kolkata');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Asia/Kathmandu');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Asia/Dhaka');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Asia/Rangoon');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Asia/Bangkok');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Asia/Ho_Chi_Minh');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Asia/Jakarta');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Australia/Perth');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Asia/Shanghai');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Asia/Hong_Kong');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Asia/Kuala_Lumpur');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Asia/Manila');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Asia/Singapore');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Asia/Taipei');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Asia/Tokyo');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Asia/Seoul');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Australia/Adelaide');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Australia/Darwin');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Australia/Brisbane');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Australia/Sydney');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Australia/Lord_Howe'); 
        FBE_CreatePSAContactsBulk.getTimeZoneString('Pacific/Norfolk');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Pacific/Guadalcanal');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Pacific/Fiji');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Pacific/Auckland');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Asia/Kamchatka');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Pacific/Chatham');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Pacific/Enderbury');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Pacific/Tongatapu');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Pacific/Kiritimati');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Atlantic/Cape_Verde');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Atlantic/South_Georgia');
        FBE_CreatePSAContactsBulk.getTimeZoneString('America/St_Johns');
        FBE_CreatePSAContactsBulk.getTimeZoneString('America/Halifax');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Atlantic/Bermuda');
        FBE_CreatePSAContactsBulk.getTimeZoneString('America/Sao_Paulo');
        FBE_CreatePSAContactsBulk.getTimeZoneString('America/Puerto_Rico');
        FBE_CreatePSAContactsBulk.getTimeZoneString('America/Santiago');
        FBE_CreatePSAContactsBulk.getTimeZoneString('America/New_York');
        FBE_CreatePSAContactsBulk.getTimeZoneString('America/Caracas');
        FBE_CreatePSAContactsBulk.getTimeZoneString('America/Chicago');
        FBE_CreatePSAContactsBulk.getTimeZoneString('America/Mexico_City');
        FBE_CreatePSAContactsBulk.getTimeZoneString('America/Bogota');
        FBE_CreatePSAContactsBulk.getTimeZoneString('America/Panama');
        FBE_CreatePSAContactsBulk.getTimeZoneString('America/Lima');
        FBE_CreatePSAContactsBulk.getTimeZoneString('America/El_Salvador');
        FBE_CreatePSAContactsBulk.getTimeZoneString('America/Mazatlan');
        FBE_CreatePSAContactsBulk.getTimeZoneString('America/Denver');
        FBE_CreatePSAContactsBulk.getTimeZoneString('America/Phoenix');
        FBE_CreatePSAContactsBulk.getTimeZoneString('America/Los_Angeles');
        FBE_CreatePSAContactsBulk.getTimeZoneString('America/Tijuana');
        FBE_CreatePSAContactsBulk.getTimeZoneString('America/Anchorage');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Pacific/Pitcairn');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Pacific/Gambier');
        FBE_CreatePSAContactsBulk.getTimeZoneString('America/Adak');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Pacific/Marquesas');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Pacific/Honolulu');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Pacific/Niue');
        FBE_CreatePSAContactsBulk.getTimeZoneString('Pacific/Pago_Pago');

    }
    
    @IsTest
    static void testAllHRRoles() {
System.assertEquals('Project Manager Advisor', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Advisor, Engineering Project Management'));
        System.assertEquals('Project Manager Advisor', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Advisor, Project/Program Management'));
        System.assertEquals('Project Manager Advisor', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Advisor, Services Project/Program Management'));
        System.assertEquals('Project Manager Analyst', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Analyst, Project/Program Management'));
        System.assertEquals('Project Manager Analyst', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Analyst, Services Project/Program Management'));
        System.assertEquals('Project Manager Consultant', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Consultant, Engineering Project Management'));
        System.assertEquals('Project Manager Consultant', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Consultant, Project/Program Management'));
        System.assertEquals('Project Manager Consultant', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Consultant, Services Project/Program Management'));
        System.assertEquals('Project Manager Sr. Advisor', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Advisor, Engineering Project Management'));
        System.assertEquals('Project Manager Sr. Advisor', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Advisor, Project/Program Management'));
        System.assertEquals('Project Manager Sr. Advisor', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Advisor, Services Project/Program Management'));
        System.assertEquals('Project Manager Sr. Analyst', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Analyst, Project/Program Management'));
        System.assertEquals('Project Manager Sr. Analyst', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Analyst, Services Project/Program Management'));
        System.assertEquals('Project Manager Sr. Consultant', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Consultant, Project/Program Management'));
        System.assertEquals('Project Manager Sr. Consultant', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Consultant, Services Project/Program Management'));
        System.assertEquals('Service Delivery Advisor', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Advisor, Service Delivery'));
        System.assertEquals('Service Delivery Analyst', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Analyst, Service Delivery'));
        System.assertEquals('Service Delivery Engineer 1', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Service Delivery Engineer 1'));
        System.assertEquals('Service Delivery Engineer 2', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Service Delivery Engineer 2'));
        System.assertEquals('Service Delivery Principle Engineer', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Principal Engineer, Service Delivery'));
        System.assertEquals('Service Delivery Sr. Advisor', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Advisor, Service Delivery'));
        System.assertEquals('Service Delivery Sr. Engineer', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Engineer, Service Delivery'));
        System.assertEquals('Service Delivery Sr. Principle Engineer', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Principal Engineer, Service Delivery'));
        System.assertEquals('Service Delivery Technical Staff Engineer', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Technical Staff, Service Delivery'));
        System.assertEquals('Solution Architecture Advisor', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Advisor, IT Architecture'));
        System.assertEquals('Solution Architecture Advisor', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Advisor, Solutions Architect'));
        System.assertEquals('Solution Architecture Analyst', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Analyst, IT Architecture'));
        System.assertEquals('Solution Architecture Analyst', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Analyst, Solutions Architect'));
        System.assertEquals('Solution Architecture Consultant', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Consultant Solutions Architecture'));
        System.assertEquals('Solution Architecture Consultant', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Consultant, IT Architecture'));
        System.assertEquals('Solution Architecture Engineer 1', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Solutions Architecture Engineer 1'));
        System.assertEquals('Solution Architecture Engineer 2', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Solutions Architecture Engineer 2'));
        System.assertEquals('Solution Architecture Principle Engineer', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Principal Engineer, Solutions Architecture'));
        System.assertEquals('Solution Architecture Sr. Advisor', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Advisor Solutions Architecture'));
        System.assertEquals('Solution Architecture Sr. Advisor', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Advisor, IT Architecture'));
        System.assertEquals('Solution Architecture Sr. Analyst', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Analyst, IT Architecture'));
        System.assertEquals('Solution Architecture Sr. Consultant', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Consultant, IT Architecture'));
        System.assertEquals('Solution Architecture Sr. Consultant', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Consultant, Solutions Architecture'));
        System.assertEquals('Solution Architecture Sr. Engineer', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Engineer, Solutions Architecture'));
        System.assertEquals('Solution Architecture Sr. Principle Engineer', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Principal Engineer, Solutions Architecture'));
        System.assertEquals('Solution Architecture Technical Staff Engineer', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Technical Staff, Solutions Architecture'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Account Executive 1, Alliances'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Account Executive 1, Direct Sales'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Account Executive 2, Business Development - Sales'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Account Executive 3, Business Development - Sales'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Account Executive 3, Services Sales'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Account Executive 4, Business Development - Sales'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Account Executive 5, Business Development - Sales'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Account Executive 6, Business Development - Sales'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Account Manager 1, Inside Sales Renewals'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Account Manager 1, Inside Sales'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Account Manager 2, Inside Sales Renewals'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Account Manager 3, Inside Sales Renewals'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Account Manager 4, Inside Sales Channel'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Account Representative 1, Inside Sales'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Administrative Assistant 1'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Administrative Assistant 2'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Advisor, Account Services Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Advisor, Accounts Receivable'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Advisor, Business Intelligence'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Advisor, Business Operations'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Advisor, Business Process Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Advisor, Business Systems Analysis'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Advisor, Command Center'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Advisor, Customer Services'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Advisor, Customer/Technical Training'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Advisor, Cybersecurity Engineering & Operations'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Advisor, Data Engineering'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Advisor, Data Intelligence Engineer'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Advisor, Data Science'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Advisor, E-Business'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Advisor, Finance Operations'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Advisor, Global Supply Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Advisor, Inventory Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Advisor, IT Application Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Advisor, IT Service Operations'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Advisor, IT Technical Analysis'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Advisor, Marketing Communications'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Advisor, Network Systems Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Advisor, Order Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Advisor, Partner Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Advisor, Product Management - IT'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Advisor, Product Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Advisor, Program Management - IT'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Advisor, Resource Deployment Manager'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Advisor, Resource Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Advisor, Sales Operations'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Advisor, Sales Planning & Strategy'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Advisor, Supply Chain'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Advisor, Technical Account Manager'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Advisor, Technical Program Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Advisor, Technical Support'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Advisor, Vendor Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Advisory Consultant'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Advisory Solutions Principal'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Advisory Systems Engineer'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Analyst, Account Services Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Analyst, Business Intelligence'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Analyst, Business Operations'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Analyst, Business Process Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Analyst, Business Systems Analysis'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Analyst, Buyer'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Analyst, Command Center'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Analyst, Customer Services'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Analyst, Data Intelligence Engineer'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Analyst, Field Service'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Analyst, IT Data Center Operations'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Analyst, IT Service Operations'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Analyst, IT Technical Analysis'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Analyst, Learning & Development'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Analyst, Marketing Operations'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Analyst, Material Planning'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Analyst, Multi-Media'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Analyst, Partner Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Analyst, Program Management - IT'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Analyst, Purchasing'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Analyst, Resource Deployment Manager'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Analyst, Resource Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Analyst, Sales Operations'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Analyst, Supply Chain'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Analyst, Technical Program Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Analyst, Vendor Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Analyst, Web Production'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Associate Consultant 1'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Associate Consultant 2'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Associate Systems Engineer II'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Associate Technician, Field Service'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Associate, Customer Services'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Consultant Business Operations'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Consultant'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Consultant, Account Services Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Consultant, Business Development'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Consultant, Business Intelligence'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Consultant, Business Process Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Consultant, Business Systems Analysis'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Consultant, Client Relationship Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Consultant, Commodity Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Consultant, Customer Services'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Consultant, Cybersecurity Engineering & Operations'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Consultant, Data Engineering'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Consultant, Data Intelligence Engineer'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Consultant, Data Science'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Consultant, Database Administrator'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Consultant, Financial Analysis'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Consultant, Global Supply Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Consultant, IT Application Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Consultant, IT Business Consulting'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Consultant, IT Security'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Consultant, IT Service Operations'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Consultant, Marketing Operations'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Consultant, Partner Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Consultant, Pricing'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Consultant, Product Management - IT'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Consultant, Product Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Consultant, Product Marketing'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Consultant, Program Management - IT'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Consultant, Resource Deployment Manager'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Consultant, Resource Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Consultant, Sales Operations'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Consultant, Strategic Business Development'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Consultant, Supply Chain'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Consultant, Technical Account Manager'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Consultant, Technical Program Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Consultant, Technical Support'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Consultant, Technical Writer'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Consultant, Vendor Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Consulting Services'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Director, Account Services Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Director, Business Development - Sales'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Director, Business Development'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Director, Business Intelligence'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Director, Business Operations'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Director, Business Process Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Director, Client Relationship Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Director, Command Center'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Director, Consulting'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Director, Data Intelligence Engineer'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Director, Data Science'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Director, Direct Sales'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Director, Engineering Project Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Director, Field Marketing'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Director, Field Service'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Director, Inside Sales Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Director, Inside Sales Renewals'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Director, International Product Support'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Director, IT Architecture'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Director, Logistics'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Director, Partner Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Director, Pricing'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Director, Procurement'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Director, Product Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Director, Product Operations Engineering'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Director, Project/Program Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Director, Quality Engineering'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Director, Resource Deployment Manager'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Director, Sales Operations'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Director, Service Delivery'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Director, Services Project/Program Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Director, Services Sales'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Director, Software Engineer IT'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Director, Software Engineering'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Director, Solutions Architect'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Director, Strategic Business Development'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Director, Supply Chain'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Director, Systems Development Engineering'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Director, Systems Engineering'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Director, Technical Program Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Director, Technical Support'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Distinguished Engineer'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Distribution Associate'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Distribution Senior Associate'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Distribution Specialist'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Executive Assistant 1'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Executive Assistant 2'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Executive Assistant 3'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Field Service Engineer 1'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Field Service Engineer 2'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('General Services Provider'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Graduate Intern'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Interactive/Visual Design Principal Engineer'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Intern Undergraduate 1'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Intern Undergraduate 2'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Lab Support Engineer 1'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Lab Support Engineer 2'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Lab Support Principal Engineer'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Lab Support Senior Engineer'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Lab Support Senior Principal Engineer'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Lead Specialist, Order Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Manager 1, Account Services Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Manager 1, Business Intelligence'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Manager 1, Business Operations'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Manager 1, Customer Services'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Manager 1, Field Service'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Manager 1, Inside Sales Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Manager 1, Inside Sales Renewals'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Manager 1, Project/Program Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Manager 1, Resource Deployment Manager'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Manager 1, Sales Operations'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Manager 1, Service Delivery'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Manager 1, Services Project/Program Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Manager 1, Solutions Architect'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Manager 1, Technical Support'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Manager 2, Account Services Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Manager 2, Business Intelligence'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Manager 2, Business Operations'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Manager 2, Command Center'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Manager 2, Customer Services'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Manager 2, Field Service'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Manager 2, Inside Sales Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Manager 2, Inside Sales Renewals'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Manager 2, Inventory Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Manager 2, IT Architecture'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Manager 2, IT Service Operations'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Manager 2, Partner Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Manager 2, Procurement'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Manager 2, Product Operations Engineering'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Manager 2, Project/Program Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Manager 2, Resource Deployment Manager'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Manager 2, Sales Operations'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Manager 2, Service Delivery'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Manager 2, Services Project/Program Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Manager 2, Services Sales'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Manager 2, Software Engineer IT'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Manager 2, Software Engineering'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Manager 2, Solutions Architect'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Manager 2, Supply Chain'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Manager 2, Technical Program Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Manager 2, Technical Support'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Outsourced Services Provider'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Outsourced Services Provider-Sales'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Principal Consultant'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Principal Engineer International Product Support'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Principal Engineer, Field Service'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Principal Engineer, Technical Support'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Principal Software Engineer - IT'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Principal Solutions Principal'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Principal Supplier Process Engineer'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Principal Systems Development Engineer'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Process Development Principal Engineer'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Process Development Senior Principal Engineer'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Product Operations Engineer 1'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Product Operations Engineer 2'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Product Operations Principal Engineer'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Product Operations Senior Engineer'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Product Operations Senior Principal Engineer'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Product Specialist 2'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Product Specialist 3'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Product Specialist 4'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Product Specialist 5'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Quality Engineer 2'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Quality Principal Engineer'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Quality Senior Engineer'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Quality Senior Principal Engineer'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Representative 1, Inside Sales'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Representative 2, Inside Sales'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Representative 3, Inside Sales'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Representative, Business Operations'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Representative, Command Center'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Advisor Business Operations'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Advisor Program Management - IT'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Advisor, Account Services Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Advisor, Accounting'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Advisor, Business Development'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Advisor, Business Intelligence'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Advisor, Business Process Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Advisor, Business Systems Analysis'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Advisor, Client Relationship Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Advisor, Command Center'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Advisor, Customer Services'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Advisor, Data Intelligence Engineer'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Advisor, Data Science'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Advisor, Database Administrator'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Advisor, E-Business'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Advisor, Field Service'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Advisor, Global Supply Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Advisor, Inventory Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Advisor, IT Application Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Advisor, IT Data Center Operations'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Advisor, IT Service Operations'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Advisor, IT Technical Analysis'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Advisor, Material Planning'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Advisor, Network Systems Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Advisor, Partner GSL'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Advisor, Partner Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Advisor, Pricing'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Advisor, Product Management - IT'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Advisor, Product Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Advisor, Product Marketing'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Advisor, Resource Deployment Manager'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Advisor, Resource Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Advisor, Sales Operations'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Advisor, Strategic Business Development'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Advisor, Supply Chain'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Advisor, Technical Account Manager'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Advisor, Technical Program Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Advisor, Technical Support'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Advisor, Vendor Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Analyst Business Operations'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Analyst Program Management - IT'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Analyst, Account Services Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Analyst, Business Development'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Analyst, Business Intelligence'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Analyst, Business Process Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Analyst, Business Systems Analysis'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Analyst, Command Center'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Analyst, Customer Services'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Analyst, Customer/Technical Training'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Analyst, Data Intelligence Engineer'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Analyst, Data Science'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Analyst, Field Service'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Analyst, Finance Operations'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Analyst, HR Shared Services'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Analyst, Inventory Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Analyst, IT Security'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Analyst, IT Service Operations'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Analyst, Marketing Communications'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Analyst, Material Planning'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Analyst, Multi-Media'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Analyst, Network Systems Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Analyst, Partner Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Analyst, Product Marketing'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Analyst, Purchasing'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Analyst, Resource Deployment Manager'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Analyst, Resource Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Analyst, Sales Operations'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Analyst, Supply Chain'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Analyst, Technical Program Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Analyst, Technical Support'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Assistant, Project/Program Administrator'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Assistant, Sales Operations'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Associate, Customer Services'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Consultant'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Consultant, Account Services Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Consultant, Business Intelligence'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Consultant, Business Operations'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Consultant, Business Process Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Consultant, Client Relationship Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Consultant, Data Engineering'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Consultant, Data Intelligence Engineer'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Consultant, Data Science'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Consultant, Field Marketing'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Consultant, Marketing Operations'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Consultant, Partner Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Consultant, Product Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Consultant, Product Marketing'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Consultant, Program Management - IT'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Consultant, Sales Operations'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Consultant, Sales Planning & Strategy'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Consultant, Strategic Business Development'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Consultant, Technical Account Manager'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Consultant, Technical Program Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Consultant, Transformation PM'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Director Inside Sales Renewals'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Director, Account Services Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Director, Business Development - Sales'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Director, Business Operations'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Director, Business Process Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Director, Channel Sales'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Director, Client Relationship Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Director, Consulting'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Director, Customer Services'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Director, Data Intelligence Engineer'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Director, Direct Sales'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Director, Engineering Technologist'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Director, Field Service'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Director, General Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Director, Logistics'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Director, Partner Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Director, Product Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Director, Product Operations Engineering'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Director, Project/Program Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Director, Quality Engineering'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Director, Resource Deployment Manager'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Director, Sales Operations'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Director, Service Delivery'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Director, Strategic Business Development'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Director, Systems Development Engineering'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Director, Technical Program Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Director, Technical Support'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Engineer International Product Support'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Engineer, Field Service'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Engineer, Technical Support'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Manager Inside Sales Renewals'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Manager, Account Services Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Manager, Business Intelligence'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Manager, Business Operations'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Manager, Business Process Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Manager, Client Relationship Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Manager, Command Center'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Manager, Consulting'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Manager, Customer Services'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Manager, Data Engineering'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Manager, Data Intelligence Engineer'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Manager, Direct Sales'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Manager, Field Marketing'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Manager, Field Service'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Manager, Inside Sales Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Manager, IT Architecture'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Manager, IT Data Center Operations'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Manager, Lab Support Engineering'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Manager, Material Planning'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Manager, Partner Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Manager, Product Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Manager, Product Operations Engineering'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Manager, Project/Program Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Manager, Quality Engineering'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Manager, Resource Deployment Manager'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Manager, Sales Operations'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Manager, Service Delivery'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Manager, Services Project/Program Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Manager, Services Sales'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Manager, Software Engineer IT'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Manager, Software Engineering'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Manager, Solutions Architect'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Manager, Supply Chain'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Manager, Systems Development Engineering'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Manager, Technical Program Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Manager, Technical Support'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Principal Engineer International Product Support'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Principal Engineer, Field Service'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Principal Engineer, Product Technologist'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Principal Engineer, Technical Support'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Principal Engineering Technologist'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Principal Software Engineer - IT'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Principal Supplier Process Engineer'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Principal Systems Development Engineer'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Representative, Business Operations'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Software Engineer - IT'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Solutions Principal'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Specialist, Accounts Receivable'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Specialist, Inventory Coordinator'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Specialist, Order Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Supplier Process Engineer'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Systems Development Engineer'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Systems Engineer'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Technician, Field Service'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Technician, Technical Support'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Vice President, Channel Sales'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Vice President, General Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Senior Vice President, Services Sales'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Software Engineer 1 - IT'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Software Engineer 1'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Software Engineer 2 - IT'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Software Engineer 2'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Software Principal Engineer'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Software Quality Principal Engineer'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Software Quality Senior Engineer'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Software Quality Senior Principal Engineer'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Software Senior Developer'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Software Senior Engineer'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Software Senior Principal Engineer'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Software System Engineer 2'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Software System Principal Engineer'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Software System Senior Engineer'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Solutions Principal'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Specialist 1, Inside Product'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Specialist 2, Inside Product'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Specialist 3, Inside Product'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Specialist 4, Inside Product'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Specialist Business Operations'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Specialist, Accounts Payable'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Specialist, Accounts Receivable'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Specialist, Client Technical Support'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Specialist, Customer Services'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Specialist, HR Shared Services'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Specialist, IT Application Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Specialist, IT Technical Analysis'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Specialist, Order Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Specialist, Project/Program Administrator'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Specialist, Resource Deployment Manager'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Specialist, Resource Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Specialist, Sales Operations'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Specialist, Supply Chain'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Specialty Contracted Services'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Staff Augmentation'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Supervisor, Customer Services'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Supervisor, Field Service'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Supervisor, Inside Sales Management'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Supervisor, Sales Operations'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Supervisor, Technical Support'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Systems Development Engineer 1'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Systems Development Engineer 2'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Systems Engineer'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Technical Content Developer 2'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Technical Content Developer 3'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Technical Content Developer 4'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Technical Staff, Engineering Technologist'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Technical Staff, Quality Engineering'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Technical Staff, Software Quality Engineering'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Technical Staff, Systems Development Engineering'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Technical Staff, Technical Support'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Technical Support Engineer 1'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Technical Support Engineer 2'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Technician, Field Service'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Technician, Technical Support'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Test Engineer 2'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Test Principal Engineer'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Test Senior Engineer'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Third-Party Intern'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('User Interface Senior Engineer'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Vendor Access'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Vendor Access-Limited Internal'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Vendor Access-RUI-Automation Anywhere'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Vice President, Business Development - Sales'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Vice President, Client Services'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Vice President, Enterprise Services'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Vice President, Inside Sales - Renewals'));
        System.assertEquals('Support & Operations (Non Billable)', FBE_CreatePSAContactsBulk.getResourceRoleFromHRRole('Vice President, Service Delivery'));
    }
   @IsTest(seeAllData = false)
    static void shouldAssignPSAPermissionControlToUser() {
        	pse__Proj__c projectTemplate1 = TestDataUtility.createProject(true);
        
            pse__Practice__c practices = new pse__Practice__c();
            practices.Name = 'Global Practice';
        	practices.Standard_Project_Template__c = projectTemplate1.Id;
            insert practices;
            
            pse__Region__c region = new pse__Region__c();
            region.Name = 'Global';
            insert region;
        
			Profile userProfile = [SELECT Id, Name FROM Profile WHERE Profile.Name = 'PSA Business Lead'];
			Profile userProfile1 = [SELECT Id, Name FROM Profile WHERE Profile.Name = 'PSA Intake'];
			Profile userProfile2 = [SELECT Id, Name FROM Profile WHERE Profile.Name = 'PSA Project Manager'];
			Profile userProfile3 = [SELECT Id, Name FROM Profile WHERE Profile.Name = 'PSA Resource Manager'];
		Test.starttest();
			List<User> userList = new List<User>();
            User user1 = new User();
            user1.FirstName = 'Xiao';
            user1.LastName = 'Nai';
            user1.External_ID__c = '37395';
            user1.FederationIdentifier = '59337';
            user1.Organization__c = 'Scott Pitman (633976)';
            user1.Username = 'xiaonai@dell.com.salesforce';
            user1.Email = 'xiaonai@dell.com';
            user1.Alias = 'naixi';
            user1.CommunityNickname = 'xiaoni';
            user1.TimeZoneSidKey = 'Asia/Kolkata';
            user1.LocaleSidKey = 'en_US';
            user1.EmailEncodingKey = 'UTF-8';
            user1.ProfileId = userProfile.Id;
            user1.LanguageLocaleKey = 'en_US';
            user1.OSP__c = 'No';
            user1.Dell_NTUserID__c = 'XIAO_NAI';
            user1.File_Source__c = 'GIS - Bulk';
            user1.Phone = '8899889908';
            user1.Service_User_Type__c = 'Business';
            user1.IsActive = true;
            user1.Agent_Location_Country__c = 'United States';
            user1.Country = 'United States';
            user1.Default_Weekly_Hours__c = '40';
            user1.HR_Job_Title__c = 'Senior Advisor, Engineering Project Management';
            user1.CurrencyIsoCode = 'USD';
            user1.EmployeeNumber = '87421';
            userList.add(user1);
			insert userList;
			
			List<User> userList1 = new List<User>();
			User user2 = new User();
            user2.FirstName = 'Zheng';
            user2.LastName = 'Shaung';
            user2.External_ID__c = '65438';
            user2.FederationIdentifier = '8867';
            user2.Organization__c = 'Scott Pitman (633976)';
            user2.Username = 'zhengshaung@dell.com.salesforce';
            user2.Email = 'zhengshaung@dell.com';
            user2.Alias = 'shauz';
            user2.CommunityNickname = 'shauzi';
            user2.TimeZoneSidKey = 'Asia/Kolkata';
            user2.LocaleSidKey = 'en_US';
            user2.EmailEncodingKey = 'UTF-8';
            user2.ProfileId = userProfile1.Id;
            user2.LanguageLocaleKey = 'en_US';
            user2.OSP__c = 'No';
            user2.Dell_NTUserID__c = 'ZHENG_SHAUN';
            user2.File_Source__c = 'GIS - Bulk';
            user2.Phone = '8859678908';
            user2.Service_User_Type__c = 'Business';
            user2.IsActive = true;
            user2.Agent_Location_Country__c = 'United States';
            user2.Country = 'United States';
            user2.Default_Weekly_Hours__c = '40';
            user2.HR_Job_Title__c = 'Senior Advisor, Engineering Project Management';
            user2.CurrencyIsoCode = 'USD';
            user2.EmployeeNumber = '9720';
            userList1.add(user2);
			insert userList1;
			
            List<User> userList2 = new List<User>();
			User user3 = new User();
            user3.FirstName = 'Yoona';
            user3.LastName = 'Shijin';
            user3.External_ID__c = '1234333';
            user3.FederationIdentifier = '1434583';
            user3.Organization__c = 'Scott Pitman (633976)';
            user3.Username = 'yoonashijin@dell.com.salesforce';
            user3.Email = 'yoonashijin@dell.com';
            user3.Alias = 'yoonas';
            user3.CommunityNickname = 'jinah';
            user3.TimeZoneSidKey = 'Asia/Kolkata';
            user3.LocaleSidKey = 'en_US';
            user3.EmailEncodingKey = 'UTF-8';
            user3.ProfileId = userProfile2.Id;
            user3.LanguageLocaleKey = 'en_US';
            user3.OSP__c = 'No';
            user3.Dell_NTUserID__c = 'YOONA_SHI';
            user3.File_Source__c = 'GIS - Bulk';
            user3.Phone = '8899688678';
            user3.Service_User_Type__c = 'Business';
            user3.IsActive = true;
            user3.Agent_Location_Country__c = 'United States';
            user3.Country = 'United States';
            user3.Default_Weekly_Hours__c = '40';
            user3.HR_Job_Title__c = 'Senior Advisor, Engineering Project Management';
            user3.CurrencyIsoCode = 'USD';
            user3.EmployeeNumber = '9986';
            userList2.add(user3);
			insert userList2;
			
			List<User> userList3 = new List<User>();
			User userRm = new User();
            userRm.FirstName = 'Gumiho';
            userRm.LastName = 'Odochin';
            userRm.External_ID__c = '1284573';
            userRm.FederationIdentifier = '1234583';
            userRm.Organization__c = 'Scott Pitman (633976)';
            userRm.Username = 'gumihoodochin@dell.com.salesforce';
            userRm.Email = 'gumihoodochin@dell.com';
            userRm.Alias = 'Alias1a';
            userRm.CommunityNickname = 'Oduchin';
            userRm.TimeZoneSidKey = 'Asia/Kolkata';
            userRm.LocaleSidKey = 'en_US';
            userRm.EmailEncodingKey = 'UTF-8';
            userRm.ProfileId = userProfile3.Id;
            userRm.LanguageLocaleKey = 'en_US';
            userRm.OSP__c = 'No';
            userRm.Dell_NTUserID__c = 'GUMIHO_ODU';
            userRm.File_Source__c = 'GIS - Bulk';
            userRm.Phone = '8899689708';
            userRm.Service_User_Type__c = 'Business';
            userRm.IsActive = true;
            userRm.Agent_Location_Country__c = 'United States';
            userRm.Country = 'United States';
            userRm.Default_Weekly_Hours__c = '40';
            userRm.HR_Job_Title__c = 'Senior Advisor, Engineering Project Management';
            userRm.CurrencyIsoCode = 'USD';
            userRm.EmployeeNumber = '12397';
            userList3.add(userRm);
            insert userList3;
        
        pse__Permission_Control__c permissionControl = new pse__Permission_Control__c();
            permissionControl.pse__Practice__c = practices.id;
            permissionControl.pse__User__c = userList[0].Id;
            permissionControl.pse__Cascading_Permission__c = true;
            permissionControl.pse__Resource_Request_Entry__c = true;
            permissionControl.pse__Staffing__c = true;
			permissionControl.pse__Skills_And_Certifications_Entry__c = true;
            permissionControl.pse__Skills_And_Certifications_View__c= true;
            permissionControl.pse__Edit_Task_Manager__c= true;
            permissionControl.pse__View_Task_Manager__c= true;
            permissionControl.pse__Billing__c= true;
            permissionControl.pse__Forecast_Edit__c= true;
            permissionControl.pse__Forecast_View__c= true;
            permissionControl.pse__Timecard_Entry__c= true;  
            permissionControl.pse__Timecard_Ops_Edit__c= true;
            permissionControl.pse__Expense_Entry__c= true;
            permissionControl.pse__Expense_Ops_Edit__c= true;
            permissionControl.pse__Invoicing__c= true;
            permissionControl.pse__Team_View__c= true;
            permissionControl.pse__Team_Edit__c= true;
            permissionControl.pse__Team_Create__c= true;
            permissionControl.pse__Compare_Project_Version__c= true;
            permissionControl.pse__Create_Project_Version__c= true;
            permissionControl.pse__Delete_Project_Version__c= true;
        insert permissionControl;

        pse__Permission_Control__c permissionControl1 = new pse__Permission_Control__c();
            permissionControl1.pse__Practice__c = practices.id;
            permissionControl1.pse__User__c = userList1[0].Id;
            permissionControl1.pse__Cascading_Permission__c = true;
            permissionControl1.pse__Resource_Request_Entry__c = true;
            permissionControl1.pse__Staffing__c = true;
			permissionControl1.pse__Skills_And_Certifications_Entry__c = true;
            permissionControl1.pse__Skills_And_Certifications_View__c= true;
            permissionControl1.pse__Edit_Task_Manager__c= true;
            permissionControl1.pse__View_Task_Manager__c= true;
            permissionControl1.pse__Billing__c= true;
            permissionControl1.pse__Forecast_Edit__c= true;
            permissionControl1.pse__Forecast_View__c= true;
            permissionControl1.pse__Expense_Entry__c= true;
            permissionControl1.pse__Expense_Ops_Edit__c= true;
            permissionControl1.pse__Invoicing__c= true;
            permissionControl1.pse__Team_View__c= true;
            permissionControl1.pse__Team_Edit__c= true;
            permissionControl1.pse__Team_Create__c= true;
            permissionControl1.pse__Compare_Project_Version__c= true;
            permissionControl1.pse__Create_Project_Version__c= true;
            permissionControl1.pse__Delete_Project_Version__c= true;
        insert permissionControl1;
        
        pse__Permission_Control__c permissioncontrolpractice13 = new pse__Permission_Control__c();
        permissioncontrolpractice13.pse__Practice__c = practices.id;
            permissioncontrolpractice13.pse__User__c = userList2[0].Id;
            permissioncontrolpractice13.pse__Cascading_Permission__c = true;
            permissioncontrolpractice13.pse__Resource_Request_Entry__c = true;
                permissioncontrolpractice13.pse__Staffing__c = true;
                permissioncontrolpractice13.pse__Skills_And_Certifications_View__c= true;
                permissioncontrolpractice13.pse__Edit_Task_Manager__c= true;
                permissioncontrolpractice13.pse__View_Task_Manager__c= true;
                permissioncontrolpractice13.pse__Timecard_Entry__c= true;  
                permissioncontrolpractice13.pse__Expense_Entry__c= true;
                permissioncontrolpractice13.pse__Invoicing__c= true;
                permissioncontrolpractice13.pse__Compare_Project_Version__c= true;
                permissioncontrolpractice13.pse__Create_Project_Version__c= true;
                permissioncontrolpractice13.pse__Delete_Project_Version__c= true;
        insert permissioncontrolpractice13;
        
        pse__Permission_Control__c permissioncontrolpracticeRm = new pse__Permission_Control__c();
        permissioncontrolpracticeRm.pse__Practice__c = practices.id;
            permissioncontrolpracticeRm.pse__User__c = userList3[0].Id;
            permissioncontrolpracticeRm.pse__Cascading_Permission__c = true;
            permissioncontrolpracticeRm.pse__Resource_Request_Entry__c = true;
                permissioncontrolpracticeRm.pse__Staffing__c = true;
                permissioncontrolpracticeRm.pse__Skills_And_Certifications_View__c= true;
                permissioncontrolpracticeRm.pse__Edit_Task_Manager__c= true;
                permissioncontrolpracticeRm.pse__View_Task_Manager__c= true;
                permissioncontrolpracticeRm.pse__Timecard_Entry__c= true;  
                permissioncontrolpracticeRm.pse__Expense_Entry__c= true;
                permissioncontrolpracticeRm.pse__Invoicing__c= true;
                permissioncontrolpracticeRm.pse__Compare_Project_Version__c= true;
                permissioncontrolpracticeRm.pse__Create_Project_Version__c= true;
                permissioncontrolpracticeRm.pse__Delete_Project_Version__c= true;
        insert permissioncontrolpracticeRm;
        Test.stoptest();
    }
}