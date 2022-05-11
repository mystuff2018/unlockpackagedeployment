/**************
* @ Class Name        : FBE_CreatePSAContactsBulk
* @ Description       : This class creates Contact records when PSA Resource Users are created. 
*                       Developed as part of IDS Feature #7868086.
* @ CreatedBy         : Deloitte
* @ CreatedOn         : 07-09-2020
* @ Modification Log  : Version 1.0 - [Abhishek Kawle] : Initially created script
*                                     07/09/2020 : Updated practice to - 'Infrastructure Delivery Services' from 'Dell Services' as
*                                     per business confirmation.
*********/
public with sharing class FBE_CreatePSAContactsBulk {
    
    public static void assignPSAContactToUsers(List<User> userList) {
        
        if(Trigger.isInsert){
            Set<Id> userIdSet = new Set<Id>();
            set<String> userRegionSet = new Set<String>();
            set<String> userTimezoneSet = new Set<String>();
            List<User> psaResourceUsers = new List<User>();
            Map<Id, List<Contact>> userContactsMap = new Map<Id, List<Contact>>();
            Map<String, pse__Region__c> userRegionMap = new Map<String, pse__Region__c>();
            Map<String, Timezone__mdt> timezoneMap = new Map<String, Timezone__mdt>();
            List<Profile> userProfile = new List<Profile>();
            Set<ID> profileIds = new Set<ID>();
            Id PSA_Technical_Resource_Id;
            userProfile = [SELECT Id, Name 
                           FROM Profile 
                           WHERE Name LIKE 'PSA%']; 
            for(Profile prof : userProfile){
               profileIds.add(prof.Id);
                if(prof.name == 'PSA Technical Resource'){
                    PSA_Technical_Resource_Id = prof.Id;
                }
            }
            for(User eachUser : userList){
                if(profileIds != null && profileIds.size() > 0){

                    if(profileIds.contains(eachUser.ProfileId)){ //Only Invoke for all PSA Profiles
                        psaResourceUsers.add(eachUser);
                    }
                }
                userIdSet.add(eachUser.Id);
                userTimezoneSet.add(eachUser.TimeZoneSidKey);
                
                if(eachUser.Agent_Location_Country__c != null || eachUser.Agent_Location_Country__c != ''){
                    userRegionSet.add(eachUser.Agent_Location_Country__c);
                }
                else{
                    userRegionSet.add(eachUser.Country);
                }
            }
            //List<recordType> recordType = new List<RecordType>();
             String recordType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('PSA Resource').getRecordTypeId();
            /*recordType = [
                SELECT Id
                FROM RecordType
                WHERE DeveloperName = 'PSA_Resource'
                LIMIT 1
            ];*/                

            Map<Id,User> DFA_User_Map = new Map<Id, User>([Select Id, ContactId from User where ContactId !=null]);
            //Create following records in Test Class - setup() method when invoking this method during Test class coverage.
            List<Account> accounts = new List<Account>();
            accounts = [
                SELECT Id, Name
                FROM Account
                WHERE Name =: System.label.FBE_PSA_Resource_Account_Name
                LIMIT 1
            ];
            
            List<pse__Practice__c> practice = new List<pse__Practice__c>();
            practice = [
                SELECT Id
                FROM pse__Practice__c
                WHERE Name = 'Infrastructure Delivery Services'
                LIMIT 1
            ];
            
            for(pse__Region__c regionObj: [SELECT Id, Name
                                           FROM pse__Region__c
                                           WHERE Name = :userRegionSet])
            {
                userRegionMap.put(regionObj.Name, regionObj);
            }
            
            for(Timezone__mdt timezoneObj : [SELECT MasterLabel,DeltaTimezone__c,Label
                                             FROM Timezone__mdt
                                             WHERE Label = :userTimezoneSet])
            {
                timezoneMap.put(timezoneObj.Label, timezoneObj);  
            }
            
            List<pse__Work_Calendar__c> workCalendars = [
                SELECT Id, Name
                FROM pse__Work_Calendar__c
            ];
            
            for(Contact contactObj : [SELECT Id, Name, pse__Salesforce_User__c
                                      FROM Contact
                                      WHERE pse__Salesforce_User__c = :userIdSet
                                      AND RecordTypeId = :recordType]) 
            {
                List<Contact> tempList = userContactsMap.get(contactObj.pse__Salesforce_User__c);
                System.debug('List of User Contacts >> Templist:  '+tempList);
                if(tempList == null){
                    userContactsMap.put(contactObj.pse__Salesforce_User__c, new List<Contact>{contactObj});                
                }
                else{
                    tempList.add(contactObj);
                }
            }
            
            List<ExceptionLogger__c> errLogList = new List<ExceptionLogger__c>();
            List<Contact> contactsList = new List<Contact>();
            
            for(User eaUser : psaResourceUsers){
                List<Contact> userContactList = userContactsMap.get(eaUser.Id);
                List<pse__Work_Calendar__c> userWorkCalList = new List<pse__Work_Calendar__c>();
                pse__Region__c region = null;
                
                if(eaUser.Agent_Location_Country__c != null || eaUser.Agent_Location_Country__c != ''){
                    region = userRegionMap.get(eaUser.Agent_Location_Country__c);
                }
                else{
                    region = userRegionMap.get(eaUser.Country);
                }
                Timezone__mdt timezones = timezoneMap.get(eaUser.TimeZoneSidKey);
                
                for(pse__Work_Calendar__c workCal : workCalendars){
                    String calendarName = workCal.Name;
                    System.debug('User > Agent Location Country: '+ eaUser.Agent_Location_Country__c);
                    System.debug('User > Default Weekly Hours: '+ eaUser.Default_Weekly_Hours__c);
                    
                    if(String.isNotBlank(eaUser.Agent_Location_Country__c) && String.isNotBlank(eaUser.Default_Weekly_Hours__c) && String.isNotBlank(calendarName))
                    {
                        System.debug('Comparing Work Calender with User Attributes');
                        if(calendarName.containsIgnoreCase(eaUser.Agent_Location_Country__c) && calendarName.contains(eaUser.Default_Weekly_Hours__c)){
                            
                            userWorkCalList.add(workCal);   
                        }
                        
                    }
                }
                
                Contact contact = null;
                System.debug('UserContactList: '+userContactList);
                if(userContactList == null){
                    contact = new Contact();
                }
                
                else if(userContactList.size() == 1){
                    contact = userContactList[0];
                    System.debug('Existing Contact Match Found, value of contact object is: '+contact);
                }
                
                else{
                    System.debug('Error updating PSA Contact: multiple contacts found for this user: '+eaUser.FirstName+ ' '+ eaUser.LastName);
                    ExceptionLogger__c log = new ExceptionLogger__c(
                        Apex_Class__c = 'CreatePSAContacts',
                        Method_Name__c = 'assignPSAContacttoUsers',
                        Error_Code__c = 'Failure - Multiple PSA contacts already exist for user ID: ' + eaUser.Id,
                        Description__c = 'Multiple PSA contacts already exist for the user'
                    );
                    errLogList.add(log);
                }
                
                contact.FirstName = eaUser.FirstName;
                contact.LastName = eaUser.LastName;
                contact.Email = eaUser.Email;
                contact.Phone = eaUser.Phone;
                contact.pse__Practice__c = practice.size() > 0 ? practice[0].Id : null;
                contact.pse__Practice__r = practice.size() > 0 ? practice[0] : null;
                contact.Account = accounts.size() > 0 ? accounts[0] : null;
                contact.AccountId = accounts.size() > 0 ? accounts[0].Id : null;
                contact.Badge_ID__c = eaUser.External_ID__c;
                contact.Time_Zone__c = (timezones != null) ? timezones.DeltaTimezone__c : null; //This was commented in base Script
                contact.TimeZone__c = getTimeZoneString(eaUser.TimeZoneSidKey); //This was commented in base Script
                contact.pse__Salesforce_User__r = eaUser;
                contact.pse__Salesforce_User__c = eaUser.Id;
                contact.RecordTypeId = recordType;
                contact.pse__Is_Resource__c = true;
                contact.pse__Is_Resource_Active__c = true;
                contact.pse__Work_Calendar__c = !userWorkCalList.isEmpty() ? userWorkCalList[0].Id : null;
                contact.pse__Resource_Role__c = getResourceRoleFromHRRole(eaUser.HR_Job_Title__c);
                contact.CurrencyIsoCode = eaUser.CurrencyIsoCode;
                if (region != null) {
                    contact.pse__Region__r = region;
                    contact.pse__Region__c = region.Id;
                }
                if (eaUser.Email != null && eaUser.Email.containsIgnoreCase('dellteam.com')) {
                    contact.pse__External_Resource__c = true;
                }
                if(DFA_User_Map != null){
                    //If Manager is DFN User
                    if(eaUser.ManagerId != null && DFA_User_Map.containsKey(eaUser.ManagerId)){
                        //ContactId on Manager
                        contact.ReportsToId = DFA_User_Map.get(eaUser.ManagerId).contactId;
                    }
                    else if(eaUser.DelegatedApproverId != null && DFA_User_Map.containsKey(eaUser.DelegatedApproverId)){
                        //ContactId on DelegatedApproverId
                        contact.ReportsToId = DFA_User_Map.get(eaUser.DelegatedApproverId).contactId;
                    }
                }
                if(eaUser.ProfileId != PSA_Technical_Resource_Id){
                    contact.pse__Exclude_From_Missing_Timecards__c = true;
                }
                if (eaUser.HR_Job_Title__c != null && eaUser.HR_Job_Title__c.containsIgnoreCase('Support & Operations (Non Billable)')) {
                    contact.pse__Exclude_from_Resource_Planner__c = true;
                    contact.pse__Exclude_From_Time_Calculations__c = true;
                    contact.pse__Exclude_From_Time_Variance__c = true;
                }
                contactsList.add(contact);
                System.debug('Contact test is:' + contact);
            }
            
            if(!errLogList.isEmpty()){
                System.debug('Inserting Logs Records');
                Database.insert(errLogList, false);
            }
            if(contactsList.size()>0){ //CheckMarx Check
                try {
                    System.debug('Inserting Contacts...');
                    insert contactsList;
                } catch (Exception e) {
                    ExceptionLogger__c log = new ExceptionLogger__c(
                        Apex_Class__c = 'CreatePSAContacts',
                        Method_Name__c = 'assignPSAContacttoUsers',
                        Error_Code__c = 'Failure - ' + e.getMessage(),
                        Description__c = e.getMessage());
                    Database.insert(log, false);
                }
            }
        }
    }
    
    @TestVisible
    private static String getTimeZoneString(String timeZoneSidKey) {
        // Contact.TimeZone__c, the UI field that displays the contact's TimeZone, is a String field
        // with a picklist whose values were entered arbitrarily. Those values do not match
        // Salesforce's values for TimeZone Display Name, and thus a mapping was necessary here.
        // We cannot anticipate the issues if we fixed the accepted values for this picklist.
        String gmtString = TimeZone.getTimeZone(timeZoneSidKey).getDisplayName().mid(1, 9);
        String returnValue;
        switch on gmtString {
            when 'GMT+01:00' {
                returnValue = 'Central Europe Time';
            }
            when 'GMT+02:00' {
                returnValue = 'E. Europe Time';
            }
            when 'GMT+03:00' {
                returnValue = 'Arabic Time';
            }
            when 'GMT+04:00' {
                returnValue = 'Arabian Time';
            }
            when 'GMT+04:30' {
                returnValue = 'Transitional Islamic State of Afghanistan Time';
            }
            when 'GMT+05:00' {
                returnValue = 'West Asia Time';
            }
            when 'GMT+05:30' {
                returnValue = 'India Time';
            }
            when 'GMT+05:45' {
                returnValue = 'Nepal Time';
            }
            when 'GMT+06:00' {
                returnValue = 'Bangladesh Time';
            }
            when 'GMT+06:30' {
                returnValue = 'Myanmar Time';
            }
            when 'GMT+07:00' {
                returnValue = 'Indochina Time';
            }
            when 'GMT+08:00' {
                returnValue = 'China Time';
            }
            when 'GMT+09:00' {
                returnValue = 'Tokyo Time';
            }
            when 'GMT+09:30' {
                returnValue = 'A.U.S. Central Time';
            }
            when 'GMT+10:00' {
                returnValue = 'A.U.S. Eastern Time';
            }
            when 'GMT+10:30' {
                returnValue = 'A.U.S. Eastern Time';
            }
            when 'GMT+11:00' {
                returnValue = 'Central Pacific Time';
            }
            when 'GMT+12:00' {
                returnValue = 'New Zealand Time';
            }
            when 'GMT+12:45' {
                returnValue = 'Chatham Time';
            }
            when 'GMT+13:00' {
                returnValue = 'Phoenix Islands Time';
            }
            when 'GMT+14:00' {
                returnValue = 'Line Islands Time';
            }
            when 'GMT-01:00' {
                returnValue = 'Azores Time';
            }
            when 'GMT-02:00' {
                returnValue = 'South Georgia Time';
            }
            when 'GMT-02:30' {
                returnValue = 'Newfoundland and Labrador Time';
            }
            when 'GMT-03:00' {
                returnValue = 'E. South America Time';
            }
            when 'GMT-04:00' {
                returnValue = 'Atlantic Time';
            }
            when 'GMT-05:00' {
                returnValue = 'Eastern Time';
            }
            when 'GMT-06:00' {
                returnValue = 'Central Time';
            }
            when 'GMT-07:00' {
                returnValue = 'Mountain Time';
            }
            when 'GMT-08:00' {
                returnValue = 'Pacific Time';
            }
            when 'GMT-09:00' {
                returnValue = 'Alaskan Time';
            }
            when 'GMT-09:30' {
                returnValue = 'Marquesas Time';
            }
            when 'GMT-10:00' {
                returnValue = 'Hawaiian Time';
            }
            when 'GMT-11:00' {
                returnValue = 'Niue Time';
            }
            when else {
                returnValue = 'GMT Time';
            }
        }
        return returnValue;
    }
    
    @TestVisible
    private static String getResourceRoleFromHRRole(String hrRole) {
        String defaultValue = 'Support & Operations (Non Billable)';
        
        if (hrRole == null) {
            return defaultValue;
        }
        
        hrRole = hrRole.toLowerCase();
        
        String role = getResourceRole(hrRole);
        if (role == null) {
            return defaultValue;
        }
        
        String level = getResourceLevel(hrRole);
        if (level == null) {
            return defaultValue;
        }
        
        return role + level;
    }
    
    private static String getResourceRole(String hrRole) {
        if (hrRole.containsIgnoreCase('project') && hrRole.containsIgnoreCase('management')) {
            return 'Project Manager ';
        } else if (hrRole.containsIgnoreCase('service delivery')) {
            return 'Service Delivery ';
        } else if (hrRole.containsIgnoreCase('architect')) {
            return 'Solution Architecture ';
        } else {
            return null;
        }
    }
    
    private static String getResourceLevel(String hrRole) {
        if (hrRole.containsIgnoreCase('director')) {
            return null;
        }
        
        String level;
        if (hrRole.containsIgnoreCase('consultant')) {
            level = 'Consultant';
        } else if (hrRole.containsIgnoreCase('advisor')) {
            level = 'Advisor';
        } else if (hrRole.containsIgnoreCase('analyst')) {
            level = 'Analyst';
        } else if (hrRole.containsIgnoreCase('principal')) {
            level = 'Principle Engineer';
        } else if (hrRole.containsIgnoreCase('technical staff')) {
            level = 'Technical Staff Engineer';
        } else if (hrRole.containsIgnoreCase('engineer 1')) {
            level = 'Engineer 1';
        } else if (hrRole.containsIgnoreCase('engineer 2')) {
            level = 'Engineer 2';
        } else if (hrRole.containsIgnoreCase('engineer')) {
            level = 'Engineer';
        } else {
            return null;
        }
        
        if (hrRole.containsIgnoreCase('senior')) {
            level = 'Sr. ' + level;
        }
        
        return level;
    }
    
    //Added as part of Story 10449435
    public static void assignPermissionControlToUsers(List<User> userList) {
        if(Trigger.isInsert){
            List<User> psaResourceUsers = new List<User>();
            List<Profile> userProfile = new List<Profile>();
            Set<ID> profileIds = new Set<ID>();
            
            userProfile = [SELECT Id, Name 
                           FROM Profile where Name like 'PSA%'];
            for(Profile prof : userProfile){
                profileIds.add(prof.Id);
                system.debug('profileIds'+profileIds);
            }
            if(!userList.isEmpty()){
                for(User eachUser : userList){
                    if(profileIds != null && profileIds.size() > 0){
                        if(profileIds.contains(eachUser.profileId)) { //Only Invoke for all PSA Profiles
                            psaResourceUsers.add(eachUser);
                            system.debug('psaResourceUsers'+psaResourceUsers);
                        }
                    }
                }
            }
            
            List<pse__Practice__c> practice = new List<pse__Practice__c>();
            practice = [
                SELECT Id,Name
                FROM pse__Practice__c
                WHERE Name = 'Global Practice'
                LIMIT 1
            ];
            List<pse__Region__c> region = new List<pse__Region__c>();
            region = [
                SELECT Id,Name
                FROM pse__Region__c
                WHERE Name = 'Global'
                LIMIT 1
            ];
            
            List<pse__Permission_Control__c> permissioncontrolList = new List<pse__Permission_Control__c>();
            if(!psaResourceUsers.isEmpty()){
                for(User eaUser : psaResourceUsers){
                    pse__Permission_Control__c permissioncontrolpractice = new pse__Permission_Control__c();
                    pse__Permission_Control__c permissioncontrolregion = new pse__Permission_Control__c();
                    permissioncontrolpractice.pse__Practice__c = practice.size() > 0 ? practice[0].Id : null;
                    permissioncontrolpractice.pse__User__c = eaUser.Id;
                    permissioncontrolpractice.pse__Cascading_Permission__c = true;
                    if(eaUser.FBE_IDS_User_Profile_Name__c =='PSA Project Manager' || eaUser.FBE_IDS_User_Profile_Name__c =='PSA Direct Manager'){
                        permissioncontrolpractice.pse__Resource_Request_Entry__c = true;
                        permissioncontrolpractice.pse__Staffing__c = true;
                        permissioncontrolpractice.pse__Skills_And_Certifications_View__c= true;
                        permissioncontrolpractice.pse__Billing__c= true;
                        permissioncontrolpractice.pse__Edit_Task_Manager__c= true;
                        permissioncontrolpractice.pse__View_Task_Manager__c= true;
                        permissioncontrolpractice.pse__Timecard_Entry__c= true;  
                        permissioncontrolpractice.pse__Expense_Entry__c= true;
                        permissioncontrolpractice.pse__Invoicing__c= true;
                        permissioncontrolpractice.pse__Compare_Project_Version__c= true;
                        permissioncontrolpractice.pse__Create_Project_Version__c= true;
                        permissioncontrolpractice.pse__Delete_Project_Version__c= true;
                    }else if(eaUser.FBE_IDS_User_Profile_Name__c == 'PSA Resource Manager'){
                        permissioncontrolpractice.pse__Resource_Request_Entry__c = true;
                        permissioncontrolpractice.pse__Staffing__c = true;
                        permissioncontrolpractice.pse__Skills_And_Certifications_Entry__c = true;
                        permissioncontrolpractice.pse__Skills_And_Certifications_View__c= true;
                        permissioncontrolpractice.pse__View_Task_Manager__c= true;
                    }else if(eaUser.FBE_IDS_User_Profile_Name__c == 'PSA Technical Resource'){
                        permissioncontrolpractice.pse__Skills_And_Certifications_View__c= true;
                        permissioncontrolpractice.pse__View_Task_Manager__c= true;
                    }else if(eaUser.FBE_IDS_User_Profile_Name__c == 'PSA Intake'||eaUser.FBE_IDS_User_Profile_Name__c == 'PSA Project Administrator' || eaUser.FBE_IDS_User_Profile_Name__c == 'PSA Business Lead' || eaUser.FBE_IDS_User_Profile_Name__c == 'PSA Intake'||eaUser.FBE_IDS_User_Profile_Name__c == 'System Administrator'){
                        if(eaUser.FBE_IDS_User_Profile_Name__c == 'PSA Business Lead'){
                            permissioncontrolpractice.pse__Timecard_Ops_Edit__c= true;
                            permissioncontrolpractice.pse__Expense_Ops_Edit__c= true;
                        } 
                        permissioncontrolpractice.pse__Resource_Request_Entry__c = true;
                        permissioncontrolpractice.pse__Staffing__c = true;
                        permissioncontrolpractice.pse__Skills_And_Certifications_Entry__c = true;
                        permissioncontrolpractice.pse__Skills_And_Certifications_View__c= true;
                        permissioncontrolpractice.pse__Edit_Task_Manager__c= true;
                        permissioncontrolpractice.pse__View_Task_Manager__c= true;
                        permissioncontrolpractice.pse__Billing__c= true;
                        permissioncontrolpractice.pse__Forecast_Edit__c= true;
                        permissioncontrolpractice.pse__Forecast_View__c= true;
                        permissioncontrolpractice.pse__Timecard_Entry__c= true;  
                        permissioncontrolpractice.pse__Expense_Entry__c= true;
                        permissioncontrolpractice.pse__Invoicing__c= true;
                        permissioncontrolpractice.pse__Team_View__c= true;
                        permissioncontrolpractice.pse__Team_Edit__c= true;
                        permissioncontrolpractice.pse__Team_Create__c= true;
                        permissioncontrolpractice.pse__Compare_Project_Version__c= true;
                        permissioncontrolpractice.pse__Create_Project_Version__c= true;
                        permissioncontrolpractice.pse__Delete_Project_Version__c= true;
                    }else if(eaUser.FBE_IDS_User_Profile_Name__c == 'PSA System Profile'){
                        permissioncontrolpractice.pse__View_Task_Manager__c= true; 
                    }
                    
                    permissioncontrolList.add(permissioncontrolpractice);
                    
                    permissioncontrolregion = permissioncontrolpractice.clone();
                    permissioncontrolregion.pse__Region__c = region.size() > 0 ? region[0].Id : null;
                    permissioncontrolregion.pse__Practice__c =Null;
                    permissioncontrolList.add(permissioncontrolregion);
                    
                    System.debug('permissioncontrol test is:' + permissioncontrolList);
                }
            }
            
            try {
                System.debug('Inserting permissioncontrol...');
                if(!permissioncontrolList.isEmpty()){
                    insert permissioncontrolList;
                }
                
            } catch (Exception e) {
                ExceptionLogger__c log = new ExceptionLogger__c(
                    Apex_Class__c = 'CreatePSAContacts',
                    Method_Name__c = 'assignPermissionControltoUsers',
                    Error_Code__c = 'Failure - ' + e.getMessage(),
                    Description__c = e.getMessage());
                Database.insert(log, false);
            }
        }
    }
}