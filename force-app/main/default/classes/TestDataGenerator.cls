/**
* @author           Orlando Monsalve href=<omonsalve.p@financialforce.com>
* Project:          FF Dell
* Description:      Class to generate data test
* Changes (Version)
* -------------------------------------
*            No.    Date           Author                           Description      
*            ----   ----------      ---------------------------     -------------    
* @version   1.0    03-04-2019      Orlando Monsalve  (OMS)           Class Created
***********************************************************************************************************************/
@isTest
public with sharing class TestDataGenerator {
    
    public static Account createAccount()
    {
        Account objAccount = new Account();
        objAccount.Name = 'TEST ACCOUNT FF';
        objAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Master_Account_Profile').getRecordTypeId();
        objAccount.CurrencyIsoCode = 'USD';
        objAccount.OwnerId = UserInfo.getUserId();
        objAccount.pse__Add_BEIs_To_Existing_Batches__c = false;
        objAccount.fferpcore__MaterializedBillingAddressValidated__c = false;
        objAccount.fferpcore__MaterializedShippingAddressValidated__c = false;
        objAccount.Customer_Type__c = 'Inherit';
        objAccount.Site_Visibility__c = 'Open';
        return objAccount;
    }
	
	public static Account createAccountPSA()
    {
        Account objAccount = new Account();
        objAccount.Name = 'Dell EMC';
        objAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Master_Account_Profile').getRecordTypeId();
        objAccount.CurrencyIsoCode = 'USD';
        objAccount.OwnerId = UserInfo.getUserId();
        objAccount.pse__Add_BEIs_To_Existing_Batches__c = false;
        objAccount.fferpcore__MaterializedBillingAddressValidated__c = false;
        objAccount.fferpcore__MaterializedShippingAddressValidated__c = false;
        objAccount.Customer_Type__c = 'Inherit';
        objAccount.Site_Visibility__c = 'Open';
        return objAccount;
    }

    public static pse__Time_Period__c createTimePeriod()
    {
        
        pse__Time_Period__c objTimePeriod     =   new pse__Time_Period__c();
        objTimePeriod.OwnerId = UserInfo.getUserId();
        objTimePeriod.Name = 'All Time Period TEST';
        objTimePeriod.CurrencyIsoCode = 'USD';
        objTimePeriod.pse__Start_Date__c = System.today();
        objTimePeriod.pse__End_Date__c = objTimePeriod.pse__Start_Date__c.addYears(2);
        objTimePeriod.pse__Type__c = 'Perpetual';
        return objTimePeriod;
    }
    
    public static pse__Region__c createRegion(Id timePeriodId)
    {
        pse__Region__c objRegion     =   new pse__Region__c();
        objRegion.OwnerId = UserInfo.getUserId();
        objRegion.Name = 'Global TEST';
        objRegion.CurrencyIsoCode = 'USD';
        objRegion.pse__Action_Update_Current_Time_Period__c = false;
        objRegion.pse__Actuals_Last_Update_Date__c = System.now();
        objRegion.pse__Actuals_Last_Updated_By__c = UserInfo.getUserId();
        objRegion.pse__Backlog_Last_Update_Date__c = System.now();
        objRegion.pse__Backlog_Last_Updated_By__c = UserInfo.getUserId();
        objRegion.pse__Billable_External_Hours__c = 0.00;
        objRegion.pse__Billable_Internal_Hours__c = 0.00;
        objRegion.pse__Billed__c = 0.00;
        objRegion.pse__Billings__c = 5755.00;
        objRegion.pse__Bookings__c = 895319357117994.09;
        objRegion.pse__Credited_Non_Billable_Internal_Hours__c = 0.00;
        objRegion.pse__Current_Time_Period_End_Date__c = System.today();
        objRegion.pse__Current_Time_Period__c = timePeriodId;
        objRegion.pse__Excluded_Hours__c = 0.00;
        objRegion.pse__Expense_Budget__c = 0.00;
        objRegion.pse__Expense_Costs__c = 0.00;
        objRegion.pse__External_Costs__c = 0.00;
        objRegion.pse__Hierarchy_Depth__c = 0;
        objRegion.pse__Hist_Sch_Utilization_Billable_Hours__c = 0.00;
        objRegion.pse__Hist_Sch_Utilization_Credited_Hours__c = 0.00;
        objRegion.pse__Hist_Sch_Utilization_Excluded_Hours__c = 0.00;
        objRegion.pse__Hist_Sch_Utilization_Held_Hours__c = 0.00;
        objRegion.pse__Hist_Sch_Utilization_Non_Billable_Hrs__c = 0.00;
        objRegion.pse__Historical_Utilization_Billable_Hours__c = 0.00;
        objRegion.pse__Historical_Utilization_Calendar_Hours__c = 0.00;
        objRegion.pse__Historical_Utilization_Credited_Hours__c = 0.00;
        objRegion.pse__Historical_Utilization_Excluded_Hours__c = 0.00;
        objRegion.pse__Historical_Utilization_Non_Billable_Hrs__c = 0.00;
        objRegion.pse__Historical_Utilization_Target_Hours__c = 0.00;
        objRegion.pse__Historical_Utilization__c = 0.00;
        objRegion.pse__Inactive_Project_Backlog__c = 0.00;
        objRegion.pse__Include_In_Forecasting__c = true;
        objRegion.pse__Internal_Budget__c = 180076.00;
        objRegion.pse__Internal_Costs__c = 0.00;
        objRegion.pse__Invoiced__c = 0.00;
        objRegion.pse__Non_Billable_External_Hours__c = 0.00;
        objRegion.pse__Non_Billable_Internal_Hours__c = 0.00;
        objRegion.pse__Other_Costs__c = 0.00;
        objRegion.pse__Pass_Through_Billings__c = 0.00;
        objRegion.pse__Plan_Last_Update_Date__c = System.now();
        objRegion.pse__Plan_Last_Updated_By__c = UserInfo.getUserId();
        objRegion.pse__Planned_Billings__c = 0.00;
        objRegion.pse__Planned_Bookings__c = 0.00;
        objRegion.pse__Planned_External_Costs__c = 0.00;
        objRegion.pse__Planned_Internal_Costs__c = 0.00;
        objRegion.pse__Planned_Revenue__c = 0.00;
        objRegion.pse__Planned_Utilization__c = 0.00;
        objRegion.pse__Pre_Billed__c = 0.00;
        objRegion.pse__Region_Name_Chain__c = 'Global';
        objRegion.pse__Revenue__c = 0.00;
        // objRegion.pse__Scheduled_Milestone__c = 0.00;
        objRegion.pse__Scheduled_Time__c = 0.00;
        objRegion.pse__Scheduled_Utilization_Billable_Hours__c = 0.00;
        objRegion.pse__Scheduled_Utilization_Calendar_Hours__c = 0;
        objRegion.pse__Scheduled_Utilization_Credited_Hours__c = 0.00;
        objRegion.pse__Scheduled_Utilization_Excluded_Hours__c = 0.00;
        objRegion.pse__Scheduled_Utilization_Held_Hours__c = 0.00;
        objRegion.pse__Scheduled_Utilization_Non_Billable_Hrs__c = 0.00;
        objRegion.pse__Scheduled_Utilization_Target_Hours__c = 0.00;
        objRegion.pse__Scheduled_Utilization__c = 0.00;
        objRegion.pse__Total_Utilization__c = 0.00;
        objRegion.pse__Unscheduled_Backlog__c = 0.00;
        objRegion.pse__Utilization_Last_Update_Date__c = System.now();
        objRegion.pse__Utilization_Last_Updated_By__c = UserInfo.getUserId();
        objRegion.pse__Utilization_Target_Hours__c = 0.00;
        objRegion.pse__Utilization__c = 0.00;
        objRegion.Active__c = false;
        return objRegion;
    }
	    public static pse__Practice__c createPractice(Id timePeriodId, Id projectId)
    {
        if(projectId == null) {
            pse__Proj__c projectTemplate = new pse__Proj__c(
                Name='Phased Project Template - Custom - Global',
                pse__Is_Template__c = true,
                pse__Is_Active__c = true,
                //CreatedDate = System.Today().addDays(-90),
                pse__Start_Date__c = Date.today()
            );
            insert projectTemplate;
            projectId = projectTemplate.Id;
        }
        
        pse__Practice__c objPractice = new pse__Practice__c();
        objPractice.OwnerId = UserInfo.getUserId();
        objPractice.Name = ' TEST Infrastructure Test Delivery';
        objPractice.CurrencyIsoCode = 'USD';
        objPractice.Standard_Project_Template__c = projectId;
        objPractice.pse__Action_Update_Current_Time_Period__c = false;
        objPractice.pse__Actuals_Last_Update_Date__c = System.now();
        objPractice.pse__Actuals_Last_Updated_By__c = UserInfo.getUserId();
        objPractice.pse__Backlog_Last_Update_Date__c = System.now();
        objPractice.pse__Backlog_Last_Updated_By__c = UserInfo.getUserId();
        objPractice.pse__Billable_External_Hours__c = 0.00;
        objPractice.pse__Billable_Internal_Hours__c = 0.00;
        objPractice.pse__Billed__c = 0.00;
        objPractice.pse__Billings__c = 5755.00;
        objPractice.pse__Bookings__c = 895319357117994.09;
        objPractice.pse__Credited_Non_Billable_Internal_Hours__c = 0.00;
        objPractice.pse__Current_Time_Period_End_Date__c = System.today();
        objPractice.pse__Current_Time_Period__c = timePeriodId;
        objPractice.pse__Excluded_Hours__c = 0.00;
        objPractice.pse__Expense_Budget__c = 0.00;
        objPractice.pse__Expense_Costs__c = 0.00;
        objPractice.pse__External_Costs__c = 0.00;
        // objPractice.pse__Global_Practice__c = 'a2T5B000000H7OdUAK';
        objPractice.pse__Hierarchy_Depth__c = 2;
        objPractice.pse__Hist_Sch_Utilization_Billable_Hours__c = 0.00;
        objPractice.pse__Hist_Sch_Utilization_Credited_Hours__c = 0.00;
        objPractice.pse__Hist_Sch_Utilization_Excluded_Hours__c = 0.00;
        objPractice.pse__Hist_Sch_Utilization_Held_Hours__c = 0.00;
        objPractice.pse__Hist_Sch_Utilization_Non_Billable_Hrs__c = 0.00;
        objPractice.pse__Historical_Utilization_Billable_Hours__c = 0.00;
        objPractice.pse__Historical_Utilization_Calendar_Hours__c = 0.00;
        objPractice.pse__Historical_Utilization_Credited_Hours__c = 0.00;
        objPractice.pse__Historical_Utilization_Excluded_Hours__c = 0.00;
        objPractice.pse__Historical_Utilization_Non_Billable_Hrs__c = 0.00;
        objPractice.pse__Historical_Utilization_Target_Hours__c = 0.00;
        objPractice.pse__Historical_Utilization__c = 0.00;
        objPractice.pse__Inactive_Project_Backlog__c = 0.00;
        objPractice.pse__Include_In_Forecasting__c = false;
        objPractice.pse__Internal_Budget__c = 180076.00;
        objPractice.pse__Internal_Costs__c = 0.00;
        objPractice.pse__Invoiced__c = 0.00;
        objPractice.pse__Non_Billable_External_Hours__c = 0.00;
        objPractice.pse__Non_Billable_Internal_Hours__c = 0.00;
        objPractice.pse__Other_Costs__c = 0.00;
        // objPractice.pse__Parent_Practice__c = 'a2T5B000000H7OiUAK';
        objPractice.pse__Pass_Through_Billings__c = 0.00;
        objPractice.pse__Plan_Last_Update_Date__c = System.now();
        objPractice.pse__Plan_Last_Updated_By__c = UserInfo.getUserId();
        objPractice.pse__Planned_Billings__c = 0.00;
        objPractice.pse__Planned_Bookings__c = 0.00;
        objPractice.pse__Planned_External_Costs__c = 0.00;
        objPractice.pse__Planned_Internal_Costs__c = 0.00;
        objPractice.pse__Planned_Revenue__c = 0.00;
        objPractice.pse__Planned_Utilization__c = 0.00;
        objPractice.pse__Pre_Billed__c = 0.00;
        objPractice.pse__Revenue__c = 0.00;
        // objPractice.pse__Scheduled_Milestone__c = 0.00;
        objPractice.pse__Scheduled_Time__c = 0.00;
        objPractice.pse__Scheduled_Utilization_Billable_Hours__c = 0.00;
        objPractice.pse__Scheduled_Utilization_Calendar_Hours__c = 0;
        objPractice.pse__Scheduled_Utilization_Credited_Hours__c = 0.00;
        objPractice.pse__Scheduled_Utilization_Excluded_Hours__c = 0.00;
        objPractice.pse__Scheduled_Utilization_Held_Hours__c = 0.00;
        objPractice.pse__Scheduled_Utilization_Non_Billable_Hrs__c = 0.00;
        objPractice.pse__Scheduled_Utilization_Target_Hours__c = 0.00;
        objPractice.pse__Scheduled_Utilization__c = 0.00;
        objPractice.pse__Total_Utilization__c = 0.00;
        objPractice.pse__Unscheduled_Backlog__c = 0.00;
        objPractice.pse__Utilization_Last_Update_Date__c = System.now();
        objPractice.pse__Utilization_Last_Updated_By__c = UserInfo.getUserId();
        objPractice.pse__Utilization_Target_Hours__c = 0.00;
        objPractice.pse__Utilization__c = 0.00;
        insert objPractice;
        
        return objPractice;
    }
    public static pse__Practice__c createPractice(Id timePeriodId)
    {
        pse__Proj__c projectTemplate = TestDataUtility.createProject(true);
        
        pse__Practice__c objPractice     =   new pse__Practice__c();
        objPractice.OwnerId = UserInfo.getUserId();
        objPractice.Name = 'Infrastructure Delivery Services';
        objPractice.CurrencyIsoCode = 'USD';
        objPractice.pse__Action_Update_Current_Time_Period__c = false;
        objPractice.pse__Actuals_Last_Update_Date__c = System.now();
        objPractice.pse__Actuals_Last_Updated_By__c = UserInfo.getUserId();
        objPractice.pse__Backlog_Last_Update_Date__c = System.now();
        objPractice.pse__Backlog_Last_Updated_By__c = UserInfo.getUserId();
        objPractice.pse__Billable_External_Hours__c = 0.00;
        objPractice.pse__Billable_Internal_Hours__c = 0.00;
        objPractice.pse__Billed__c = 0.00;
        objPractice.pse__Billings__c = 5755.00;
        objPractice.pse__Bookings__c = 895319357117994.09;
        objPractice.pse__Credited_Non_Billable_Internal_Hours__c = 0.00;
        objPractice.pse__Current_Time_Period_End_Date__c = System.today();
        objPractice.pse__Current_Time_Period__c = timePeriodId;
        objPractice.pse__Excluded_Hours__c = 0.00;
        objPractice.pse__Expense_Budget__c = 0.00;
        objPractice.pse__Expense_Costs__c = 0.00;
        objPractice.pse__External_Costs__c = 0.00;
        // objPractice.pse__Global_Practice__c = 'a2T5B000000H7OdUAK';
        objPractice.pse__Hierarchy_Depth__c = 2;
        objPractice.pse__Hist_Sch_Utilization_Billable_Hours__c = 0.00;
        objPractice.pse__Hist_Sch_Utilization_Credited_Hours__c = 0.00;
        objPractice.pse__Hist_Sch_Utilization_Excluded_Hours__c = 0.00;
        objPractice.pse__Hist_Sch_Utilization_Held_Hours__c = 0.00;
        objPractice.pse__Hist_Sch_Utilization_Non_Billable_Hrs__c = 0.00;
        objPractice.pse__Historical_Utilization_Billable_Hours__c = 0.00;
        objPractice.pse__Historical_Utilization_Calendar_Hours__c = 0.00;
        objPractice.pse__Historical_Utilization_Credited_Hours__c = 0.00;
        objPractice.pse__Historical_Utilization_Excluded_Hours__c = 0.00;
        objPractice.pse__Historical_Utilization_Non_Billable_Hrs__c = 0.00;
        objPractice.pse__Historical_Utilization_Target_Hours__c = 0.00;
        objPractice.pse__Historical_Utilization__c = 0.00;
        objPractice.pse__Inactive_Project_Backlog__c = 0.00;
        objPractice.pse__Include_In_Forecasting__c = false;
        objPractice.pse__Internal_Budget__c = 180076.00;
        objPractice.pse__Internal_Costs__c = 0.00;
        objPractice.pse__Invoiced__c = 0.00;
        objPractice.pse__Non_Billable_External_Hours__c = 0.00;
        objPractice.pse__Non_Billable_Internal_Hours__c = 0.00;
        objPractice.pse__Other_Costs__c = 0.00;
        // objPractice.pse__Parent_Practice__c = 'a2T5B000000H7OiUAK';
        objPractice.pse__Pass_Through_Billings__c = 0.00;
        objPractice.pse__Plan_Last_Update_Date__c = System.now();
        objPractice.pse__Plan_Last_Updated_By__c = UserInfo.getUserId();
        objPractice.pse__Planned_Billings__c = 0.00;
        objPractice.pse__Planned_Bookings__c = 0.00;
        objPractice.pse__Planned_External_Costs__c = 0.00;
        objPractice.pse__Planned_Internal_Costs__c = 0.00;
        objPractice.pse__Planned_Revenue__c = 0.00;
        objPractice.pse__Planned_Utilization__c = 0.00;
        objPractice.pse__Pre_Billed__c = 0.00;
        objPractice.pse__Revenue__c = 0.00;
        // objPractice.pse__Scheduled_Milestone__c = 0.00;
        objPractice.Standard_Project_Template__c = projectTemplate.Id;
        objPractice.pse__Scheduled_Time__c = 0.00;
        objPractice.pse__Scheduled_Utilization_Billable_Hours__c = 0.00;
        objPractice.pse__Scheduled_Utilization_Calendar_Hours__c = 0;
        objPractice.pse__Scheduled_Utilization_Credited_Hours__c = 0.00;
        objPractice.pse__Scheduled_Utilization_Excluded_Hours__c = 0.00;
        objPractice.pse__Scheduled_Utilization_Held_Hours__c = 0.00;
        objPractice.pse__Scheduled_Utilization_Non_Billable_Hrs__c = 0.00;
        objPractice.pse__Scheduled_Utilization_Target_Hours__c = 0.00;
        objPractice.pse__Scheduled_Utilization__c = 0.00;
        objPractice.pse__Total_Utilization__c = 0.00;
        objPractice.pse__Unscheduled_Backlog__c = 0.00;
        objPractice.pse__Utilization_Last_Update_Date__c = System.now();
        objPractice.pse__Utilization_Last_Updated_By__c = UserInfo.getUserId();
        objPractice.pse__Utilization_Target_Hours__c = 0.00;
        objPractice.pse__Utilization__c = 0.00;
        return objPractice;
    }

    public static pse__Work_Calendar__c createWorkCalendar()
    {
        pse__Work_Calendar__c objWorkCalendar     =   new pse__Work_Calendar__c();
        objWorkCalendar.OwnerId = UserInfo.getUserId();
        objWorkCalendar.Name = 'US Full Time';
        objWorkCalendar.CurrencyIsoCode = 'USD';
        objWorkCalendar.pse__Friday_End_Hour__c = '17:00 (5:00 PM)';
        objWorkCalendar.pse__Friday_Hours__c = 8.00;
        objWorkCalendar.pse__Friday_Start_Hour__c = '08:00 (8:00 AM)';
        objWorkCalendar.pse__Monday_End_Hour__c = '17:00 (5:00 PM)';
        objWorkCalendar.pse__Monday_Hours__c = 8.00;
        objWorkCalendar.pse__Monday_Start_Hour__c = '08:00 (8:00 AM)';
        objWorkCalendar.pse__Saturday_End_Hour__c = '17:00 (5:00 PM)';
        objWorkCalendar.pse__Saturday_Hours__c = 0.00;
        objWorkCalendar.pse__Saturday_Start_Hour__c = '08:00 (8:00 AM)';
        objWorkCalendar.pse__Standard_Hours_Per_Day__c = 8.00;
        objWorkCalendar.pse__Sunday_End_Hour__c = '17:00 (5:00 PM)';
        objWorkCalendar.pse__Sunday_Hours__c = 0.00;
        objWorkCalendar.pse__Sunday_Start_Hour__c = '08:00 (8:00 AM)';
        objWorkCalendar.pse__Thursday_End_Hour__c = '17:00 (5:00 PM)';
        objWorkCalendar.pse__Thursday_Hours__c = 8.00;
        objWorkCalendar.pse__Thursday_Start_Hour__c = '08:00 (8:00 AM)';
        objWorkCalendar.pse__Tuesday_End_Hour__c = '17:00 (5:00 PM)';
        objWorkCalendar.pse__Tuesday_Hours__c = 8.00;
        objWorkCalendar.pse__Tuesday_Start_Hour__c = '08:00 (8:00 AM)';
        objWorkCalendar.pse__Wednesday_End_Hour__c = '17:00 (5:00 PM)';
        objWorkCalendar.pse__Wednesday_Hours__c = 8.00;
        objWorkCalendar.pse__Wednesday_Start_Hour__c = '08:00 (8:00 AM)';
        objWorkCalendar.pse__Week_Start_Day__c = 'Saturday';
        objWorkCalendar.pse__WeekendsAreWorkdays__c = false;
        return objWorkCalendar;
    }
    public static User createUser(String strLastName, String strFirstName, String strNumber)
    {
        User objUser     =   new User();
        objUser.Username = strFirstName.toLowerCase()+'_'+strLastName.toLowerCase()+'@dellteam.com.dellservices.dev1';
        objUser.LastName = strLastName;
        objUser.FirstName = strFirstName;
        objUser.Email = strFirstName.toLowerCase()+'_'+strLastName.toLowerCase()+'@dellteam.com';
        objUser.EmailPreferencesAutoBcc = true;
        objUser.EmailPreferencesAutoBccStayInTouch = false;
        objUser.EmailPreferencesStayInTouchReminder = true;
        objUser.Alias = strFirstName.substring(0, 1) + strLastName.substring(0, 4);
        objUser.CommunityNickname = strFirstName.toLowerCase()+'_'+strLastName.toLowerCase();
        objUser.IsActive = true;
        objUser.TimeZoneSidKey = 'America/Los_Angeles';
        objUser.LocaleSidKey = 'en_US';
        objUser.ReceivesInfoEmails = true;
        objUser.ReceivesAdminInfoEmails = true;
        objUser.EmailEncodingKey = 'UTF-8';
        objUser.DefaultCurrencyIsoCode = 'USD';
        objUser.CurrencyIsoCode = 'USD';
        objUser.ProfileId = UserInfo.getProfileId();
        objUser.LanguageLocaleKey = 'en_US';
        objUser.UserPermissionsMarketingUser = false;
        objUser.UserPermissionsOfflineUser = false;
        objUser.UserPermissionsAvantgoUser = false;
        objUser.UserPermissionsCallCenterAutoLogin = false;
        objUser.UserPermissionsMobileUser = false;
        objUser.UserPermissionsSFContentUser = false;
        objUser.UserPermissionsKnowledgeUser = false;
        objUser.UserPermissionsInteractionUser = false;
        objUser.UserPermissionsSupportUser = false;
       // objUser.UserPermissionsLiveAgentUser = false;
        objUser.ForecastEnabled = false;
        objUser.UserPreferencesActivityRemindersPopup = true;
        objUser.UserPreferencesEventRemindersCheckboxDefault = true;
        objUser.UserPreferencesTaskRemindersCheckboxDefault = true;
        objUser.UserPreferencesReminderSoundOff = false;
        objUser.UserPreferencesDisableAllFeedsEmail = false;
        objUser.UserPreferencesDisableFollowersEmail = false;
        objUser.UserPreferencesDisableProfilePostEmail = false;
        objUser.UserPreferencesDisableChangeCommentEmail = false;
        objUser.UserPreferencesDisableLaterCommentEmail = false;
        objUser.UserPreferencesDisProfPostCommentEmail = false;
        objUser.UserPreferencesContentNoEmail = false;
        objUser.UserPreferencesContentEmailAsAndWhen = false;
        objUser.UserPreferencesApexPagesDeveloperMode = false;
        objUser.UserPreferencesHideCSNGetChatterMobileTask = false;
        objUser.UserPreferencesDisableMentionsPostEmail = false;
        objUser.UserPreferencesDisMentionsCommentEmail = false;
        objUser.UserPreferencesHideCSNDesktopTask = false;
        objUser.UserPreferencesHideChatterOnboardingSplash = false;
        objUser.UserPreferencesHideSecondChatterOnboardingSplash = false;
        objUser.UserPreferencesDisCommentAfterLikeEmail = false;
        objUser.UserPreferencesDisableLikeEmail = true;
        objUser.UserPreferencesSortFeedByComment = true;
        objUser.UserPreferencesDisableMessageEmail = false;
        objUser.UserPreferencesDisableBookmarkEmail = false;
        objUser.UserPreferencesDisableSharePostEmail = false;
        objUser.UserPreferencesEnableAutoSubForFeeds = false;
        objUser.UserPreferencesDisableFileShareNotificationsForApi = false;
        objUser.UserPreferencesShowTitleToExternalUsers = true;
        objUser.UserPreferencesShowManagerToExternalUsers = false;
        objUser.UserPreferencesShowEmailToExternalUsers = false;
        objUser.UserPreferencesShowWorkPhoneToExternalUsers = false;
        objUser.UserPreferencesShowMobilePhoneToExternalUsers = false;
        objUser.UserPreferencesShowFaxToExternalUsers = false;
        objUser.UserPreferencesShowStreetAddressToExternalUsers = false;
        objUser.UserPreferencesShowCityToExternalUsers = false;
        objUser.UserPreferencesShowStateToExternalUsers = false;
        objUser.UserPreferencesShowPostalCodeToExternalUsers = false;
        objUser.UserPreferencesShowCountryToExternalUsers = false;
        objUser.UserPreferencesShowProfilePicToGuestUsers = false;
        objUser.UserPreferencesShowTitleToGuestUsers = false;
        objUser.UserPreferencesShowCityToGuestUsers = false;
        objUser.UserPreferencesShowStateToGuestUsers = false;
        objUser.UserPreferencesShowPostalCodeToGuestUsers = false;
        objUser.UserPreferencesShowCountryToGuestUsers = false;
        objUser.UserPreferencesPipelineViewHideHelpPopover = false;
        //objUser.UserPreferencesHideS1BrowserUI = false;
        objUser.UserPreferencesDisableEndorsementEmail = false;
        objUser.UserPreferencesPathAssistantCollapsed = false;
        objUser.UserPreferencesCacheDiagnostics = false;
        objUser.UserPreferencesShowEmailToGuestUsers = false;
        objUser.UserPreferencesShowManagerToGuestUsers = false;
        objUser.UserPreferencesShowWorkPhoneToGuestUsers = false;
        objUser.UserPreferencesShowMobilePhoneToGuestUsers = false;
        objUser.UserPreferencesShowFaxToGuestUsers = false;
        objUser.UserPreferencesShowStreetAddressToGuestUsers = false;
        objUser.UserPreferencesLightningExperiencePreferred = true;
        objUser.UserPreferencesPreviewLightning = false;
        objUser.UserPreferencesHideEndUserOnboardingAssistantModal = false;
        objUser.UserPreferencesHideLightningMigrationModal = false;
        objUser.UserPreferencesHideSfxWelcomeMat = true;
        objUser.UserPreferencesHideBiggerPhotoCallout = false;
        objUser.UserPreferencesGlobalNavBarWTShown = false;
        objUser.UserPreferencesGlobalNavGridMenuWTShown = false;
        objUser.UserPreferencesCreateLEXAppsWTShown = false;
        objUser.UserPreferencesFavoritesWTShown = false;
        objUser.UserPreferencesRecordHomeSectionCollapseWTShown = false;
        objUser.UserPreferencesRecordHomeReservedWTShown = false;
        objUser.UserPreferencesFavoritesShowTopFavorites = false;
        objUser.UserPreferencesExcludeMailAppAttachments = false;
        objUser.UserPreferencesSuppressTaskSFXReminders = false;
        objUser.UserPreferencesSuppressEventSFXReminders = false;
        objUser.UserPreferencesPreviewCustomTheme = false;
        objUser.UserPreferencesHasCelebrationBadge = false;
        objUser.UserPreferencesUserDebugModePref = false;
        objUser.UserPreferencesNewLightningReportRunPageEnabled = false;
        objUser.FederationIdentifier = '1196894'+strNumber;
        objUser.DigestFrequency = 'D';
        objUser.DefaultGroupNotificationFrequency = 'N';
        objUser.OSP__c = 'No';
        objUser.Dell_Remote_Assist__c = false;
        objUser.Dell_NTUserID__c = strFirstName.toUpperCase()+'_'+strLastName.toUpperCase();
        objUser.External_ID__c = '1196894'+strNumber;
        objUser.File_Source__c = 'AMS - System Admin';
        objUser.Organization__c = 'Dell';
        objUser.Service_User_Type__c = 'Service Account';
		objUser.EmployeeNumber='12349999';
        return objUser;
    }

    public static Contact createContact(String strLastname, String strName, Id accountId, Id regionId, Id practiceId, Id workCalendarId, Id userId)
    {
        Contact objContact     =   new Contact();
        objContact.AccountId = accountId;
        objContact.LastName = strLastname;
        objContact.FirstName = strName;
        objContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('PSA_Resource').getRecordTypeId();
        objContact.Email = strName.toLowerCase()+'_'+strLastname.toLowerCase()+ '@dellteam.com';
        objContact.CurrencyIsoCode = 'USD';
        objContact.OwnerId = UserInfo.getUserId();
        // objContact.HasOptedOutOfEmail = false;
        // objContact.HasOptedOutOfFax = false;
        // objContact.DoNotCall = false;
        objContact.Verified__c = true;
        objContact.Account_Id__c = accountId;
        // objContact.pse__Action_Calculate_Utilization__c = false;
        // objContact.pse__Action_Update_Current_Time_Period__c = false;
        objContact.pse__Actuals_Last_Update_Date__c = System.now();
        objContact.pse__Actuals_Last_Updated_By__c = UserInfo.getUserId();
        // objContact.pse__Allow_Timecards_Without_Assignment__c = false;
        // objContact.pse__Billable_External_Hours__c = 0.00;
        // objContact.pse__Billable_Internal_Hours__c = 0.00;
        // objContact.pse__Billed__c = 0.00;
        // objContact.pse__Billings__c = 0.00;
        // objContact.pse__Bookings__c = 0.00;
        // objContact.pse__Credited_Non_Billable_Internal_Hours__c = 0.00;
        // objContact.pse__Daily_Default_Cost_Rate__c = false;
        // objContact.pse__Default_Cost_Rate__c = 0.00;
        // objContact.pse__Exclude_From_Missing_Timecards__c = false;
        // objContact.pse__Exclude_From_Time_Calculations__c = false;
        // objContact.pse__Exclude_From_Time_Variance__c = false;
        // objContact.pse__Exclude_from_Resource_Planner__c = false;
        // objContact.pse__Excluded_Hours__c = 0.00;
        // objContact.pse__Expense_Budget__c = 0.00;
        // objContact.pse__Expense_Costs__c = 0.00;
        // objContact.pse__External_Costs__c = 0.00;
        // objContact.pse__External_Resource__c = false;
        // objContact.pse__Hist_Sch_Utilization_Billable_Hours__c = 0.00;
        // objContact.pse__Hist_Sch_Utilization_Credited_Hours__c = 0.00;
        // objContact.pse__Hist_Sch_Utilization_Excluded_Hours__c = 0.00;
        // objContact.pse__Hist_Sch_Utilization_Held_Hours__c = 0.00;
        // objContact.pse__Hist_Sch_Utilization_Non_Billable_Hrs__c = 0.00;
        // objContact.pse__Historical_Utilization_Billable_Hours__c = 0.00;
        // objContact.pse__Historical_Utilization_Calendar_Hours__c = 0.00;
        // objContact.pse__Historical_Utilization_Credited_Hours__c = 0.00;
        // objContact.pse__Historical_Utilization_Excluded_Hours__c = 0.00;
        // objContact.pse__Historical_Utilization_Non_Billable_Hrs__c = 0.00;
        // objContact.pse__Historical_Utilization_Target_Hours__c = 0.00;
        // objContact.pse__Historical_Utilization__c = 0.00;
        // objContact.pse__Internal_Budget__c = 0.00;
        // objContact.pse__Internal_Costs__c = 0.00;
        // objContact.pse__Invoiced__c = 0.00;
        objContact.pse__Is_Resource_Active__c = true;
        objContact.pse__Is_Resource__c = true;
        // objContact.pse__Non_Billable_External_Hours__c = 0.00;
        // objContact.pse__Non_Billable_Internal_Hours__c = 0.00;
        // objContact.pse__Other_Costs__c = 0.00;
        // objContact.pse__Pass_Through_Billings__c = 0.00;
        objContact.pse__Practice__c = practiceId;
        // objContact.pse__Pre_Billed__c = 0.00;
        objContact.pse__Region__c = regionId;
        objContact.pse__Resource_Role__c = 'Project Manager';
        // objContact.pse__Revenue__c = 0.00;
        objContact.pse__Salesforce_User__c = userId;
        // objContact.pse__Scheduled_Utilization_Billable_Hours__c = 0.00;
        // objContact.pse__Scheduled_Utilization_Calendar_Hours__c = 0.00;
        // objContact.pse__Scheduled_Utilization_Credited_Hours__c = 0.00;
        // objContact.pse__Scheduled_Utilization_Excluded_Hours__c = 0.00;
        // objContact.pse__Scheduled_Utilization_Held_Hours__c = 0.00;
        // objContact.pse__Scheduled_Utilization_Non_Billable_Hrs__c = 0.00;
        // objContact.pse__Scheduled_Utilization_Target_Hours__c = 0.00;
        // objContact.pse__Scheduled_Utilization__c = 0.00;
        // objContact.pse__Total_Utilization__c = 0.00;
        objContact.pse__Utilization_Last_Update_Date__c = System.now();
        objContact.pse__Utilization_Last_Updated_By__c = UserInfo.getUserId();
        // objContact.pse__Utilization_Target_Hours__c = 0.00;
        objContact.pse__Work_Calendar__c = workCalendarId;
        // objContact.Federal_Access__c = false;
        objContact.Verify__c = true;
        // objContact.Company_Admin__c = true;
        // objContact.Partner_Company_Admin__c = true;
        return objContact;
    }
    
    public static WorkType createWorkType()
    {
        WorkType objWorkType     =   new WorkType();
        objWorkType.OwnerId = UserInfo.getUserId();
        objWorkType.Name = 'FSE Task TEST';
        objWorkType.CurrencyIsoCode = 'USD';
        objWorkType.Description = 'FSE Task TEST';
        objWorkType.EstimatedDuration = 0.00;
        objWorkType.DurationType = 'Hours';
        objWorkType.ShouldAutoCreateSvcAppt = true;
        return objWorkType;
    }

    public static pse__Proj__c createProject(Id accountId, Id contactId, Id contactAuxId, Id timePeriodId, Id regionId, Id practiceId)
    {
        pse__Proj__c objProj     =   new pse__Proj__c();
        objProj.OwnerId = UserInfo.getUserId();
        objProj.Name = 'TEST PROJECT';
        objProj.CurrencyIsoCode = 'USD';
        objProj.RecordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get('Tier_1').getRecordTypeId();
        objProj.pse__Account__c = accountId;
        objProj.pse__Action_Count_Billing_Eligible_Records__c = false;
        objProj.pse__Action_Update_Current_Time_Period__c = false;
        objProj.pse__Actuals_Last_Update_Date__c = System.now();
        objProj.pse__Actuals_Last_Updated_By__c = UserInfo.getUserId();
        objProj.pse__Actuals_Need_Recalc__c = false;
        objProj.pse__Add_BEIs_To_Existing_Batches__c = false;
        objProj.pse__Allow_Expenses_Without_Assignment__c = false;
        objProj.pse__Allow_Self_Staffing__c = false;
        objProj.pse__Allow_Timecards_Without_Assignment__c = false;
        objProj.pse__Backlog_Last_Update_Date__c = System.now();
        objProj.pse__Backlog_Last_Updated_By__c = UserInfo.getUserId();
        objProj.pse__Billable_Expense_Fee_Flat__c = 0.00;
        objProj.pse__Billable_Expense_Fee_Percentage__c = 0.00;
        objProj.pse__Billable_External_Hours__c = 0.00;
        objProj.pse__Billable_Internal_Hours__c = 0.00;
        objProj.pse__Billed__c = 0.00;
        objProj.pse__Billing_Eligible_Budgets__c = 0;
        objProj.pse__Billing_Eligible_Expenses__c = 0;
        // objProj.pse__Billing_Eligible_Milestones__c = 0;
        objProj.pse__Billing_Eligible_Misc_Adjustments__c = 0;
        objProj.pse__Billing_Eligible_Timecard_Splits__c = 0;
        objProj.pse__Billing_Queues_Need_Recalc__c = false;
        objProj.pse__Billing_Type__c = 'Time and Materials';
        objProj.pse__Billings__c = 0.00;
        objProj.pse__Bookings__c = 0.02;
        objProj.pse__Closed_for_Expense_Entry__c = true;
        objProj.pse__Closed_for_Time_Entry__c = true;
        objProj.pse__Copy_Child_Records_from_Template_Async__c = false;
        objProj.pse__Credited_Non_Billable_Internal_Hours__c = 0.00;
        objProj.pse__Current_Time_Period_End_Date__c = System.today();
        objProj.pse__Current_Time_Period__c = timePeriodId;
        objProj.pse__Daily_Timecard_Notes_Required__c = false;
        objProj.pse__End_Date__c = System.today().addDays(3);
        objProj.pse__ExcludeProjectFromDisplayOnBilling__c = false;
        objProj.pse__Exclude_From_Billing__c = false;
        objProj.pse__Exclude_from_Backlog__c = false;
        objProj.pse__Exclude_from_Project_Planner__c = false;
        objProj.pse__Excluded_Hours__c = 0.00;
        objProj.pse__Expense_Budget__c = 0.00;
        objProj.pse__Expense_Costs__c = 0.00;
        objProj.pse__External_Costs__c = 0.00;
        objProj.pse__External_Time_Cost__c = 0.00;
        objProj.pse__Hierarchy_Depth__c = 0;
        objProj.pse__Inactive_Project_Backlog__c = 0.00;
        objProj.pse__Include_In_Forecasting__c = false;
        objProj.pse__Internal_Budget__c = 0.00;
        objProj.pse__Internal_Costs__c = 0.00;
        objProj.pse__Internal_Time_Cost__c = 0.00;
        objProj.pse__Invoiced__c = 0.00;
        objProj.pse__Is_Active__c = true;
        objProj.pse__Is_Billable__c = true;
        objProj.pse__Is_Template__c = false;
        // objProj.pse__Milestone_Cost__c = 0.00;
        objProj.pse__Non_Billable_External_Hours__c = 0.00;
        objProj.pse__Non_Billable_Internal_Hours__c = 0.00;
        objProj.pse__Other_Costs__c = 0.00;
        objProj.pse__Pass_Through_Billings__c = 0.00;
        objProj.pse__Practice__c = practiceId;
        objProj.pse__Pre_Bill_Type__c = 'None';
        objProj.pse__Pre_Billed__c = 0.00;
        objProj.pse__Project_Manager__c = contactId;
        objProj.pse__Project_Name_Chain__c = 'TEST PROJECT';
        objProj.pse__Project_Phase__c = 'Setup';
        objProj.pse__Project_Type__c = 'Standard';
        objProj.pse__Region__c = regionId;
        objProj.pse__Requires_Dependency_Sync__c = false;
        objProj.pse__Revenue__c = 0.00;
        // objProj.pse__Scheduled_Milestone__c = 0.00;
        objProj.pse__Scheduled_Time__c = 0.00;
        objProj.pse__Share_with_Project_Manager__c = false;
        objProj.pse__Share_with_Project_Resources__c = false;
        objProj.pse__Stage__c = 'Draft';
        objProj.pse__Start_Date__c = System.today().addDays(1);
        objProj.pse__Tasks_Total_Points_Complete__c = 0.00;
        objProj.pse__Tasks_Total_Points__c = 0.00;
        objProj.pse__Time_Credited__c = false;
        objProj.pse__Time_Excluded__c = false;
        objProj.pse__Total_Number_of_Tasks__c = 7;
        objProj.pse__Unscheduled_Backlog__c = 0.00;
        objProj.Close_Project__c = false;
        objProj.Customer_Closure_Meeting__c = false;
        objProj.Customer_Kickoff__c = false;
        objProj.Delivery_and_Implementation__c = false;
        objProj.Draft_Project_Charter__c = false;
        objProj.Draft_Project_Plan__c = false;
        objProj.Edited_By_Project_Manager__c = false;
        objProj.Financials_Status__c = 'Green';
        objProj.Gather_Requirements__c = false;
        objProj.Initiate_Customer_Contact__c = false;
        objProj.Internal_Kickoff_Project_Review__c = false;
        objProj.Internal_Kickoff__c = false;
        objProj.Internal_Project_Team_Review__c = false;
        objProj.Is_Priority__c = false;
        objProj.PM_Complexity__c = 'Low';
        objProj.PO_Number__c = '538095';
        objProj.Planning_and_Design__c = false;
        objProj.Post_Implementation_Validation__c = false;
        objProj.Pre_Implementation_Validation__c = false;
        objProj.Project_Complexity__c = 'Low';
        objProj.Project_Name_Unique__c = 'TEST PROJECT';
        objProj.Project_Support_Analyst__c = contactAuxId;
        objProj.Project_Visibility__c = 'All';
        objProj.Quality_Assurance_Date__c = System.now();
        objProj.Quality_Assurance__c = false;
        objProj.Reason_Not_To_Survey__c = 'Survey Project';
        objProj.Schedule_Status__c = 'Green';
        objProj.Scope_Status__c = 'Green';
        objProj.Setup_Project_Date__c = System.now();
        objProj.Setup_Project__c = true;
        // objProj.Template_Id__c = 'a2U5B000000WPXvUAO';
        objProj.Understand_Services_Sold__c = false;
        objProj.Validate_Project_Risk_Tier__c = false;
        objProj.Customer_Contact_Successful__c = false;
        objProj.Send_To_Click__c = false;
        objProj.PSA_Project_Stage_Start_Date__c = System.today();
        objProj.PSA_Project_Phase_Start_Date__c = System.today();
        objProj.Auto_Dispatch__c = false;
        objProj.All_Project_Tasks_Complete__c = true;
        return objProj;
    }
    public static pse__Project_Task__c createParentProjectTask(Id projectId)
    {
        pse__Project_Task__c objProjectTask     =   new pse__Project_Task__c();
        objProjectTask.OwnerId = UserInfo.getUserId();
        objProjectTask.Name = 'Initiate';
        objProjectTask.CurrencyIsoCode = 'USD';
        objProjectTask.pse__Actual_End_Date_Time__c = System.now().addMonths(1);
        objProjectTask.pse__Actual_Hours__c = 0.00;
        objProjectTask.pse__Actual_Start_Date_Time__c = System.now();
        objProjectTask.pse__Blocked__c = false;
        objProjectTask.pse__Closed_for_Time_Entry__c = false;
        objProjectTask.pse__Completed__c = false;
        objProjectTask.pse__Do_Not_Auto_Update_Parents__c = false;
        objProjectTask.pse__Do_Not_Auto_Update_This_Task__c = false;
        objProjectTask.pse__Duration_Unit__c = 'days';
        objProjectTask.pse__End_Date_Time__c = System.now() + 10;
        objProjectTask.pse__Estimated_Hours__c = 2.00;
        objProjectTask.pse__Estimated_Time_To_Completion__c = 2.00;
        objProjectTask.pse__Flag_Information__c = 'Project Task date range is not covered by Assignments or Resource Requests.Project Task has no associated project task assignment';
        objProjectTask.pse__Flag_Task_Dates_No_Coverage__c = true;
        objProjectTask.pse__Flag_Task_Dates_Partial_Coverage__c = false;
        // objProjectTask.pse__Flag_Task_End_Milestone_Bounds__c = false;
        objProjectTask.pse__Flag_Task_End_Project_Bounds__c = false;
        objProjectTask.pse__Flag_Task_Hours_No_Coverage__c = true;
        objProjectTask.pse__Flag_Task_Hours_Partial_Coverage__c = false;
        // objProjectTask.pse__Flag_Task_Start_Milestone_Bounds__c = false;
        objProjectTask.pse__Flag_Task_Start_Project_Bounds__c = false;
        objProjectTask.pse__Hierarchy_Depth__c = 0;
        objProjectTask.pse__Percent_Complete_Points__c = 0.00;
        objProjectTask.pse__Percent_Complete_Tasks__c = 100.00;
        objProjectTask.pse__Points_Baseline__c = 0.00;
        objProjectTask.pse__Points_Complete__c = 0.00;
        objProjectTask.pse__Points__c = 0.00;
        objProjectTask.pse__Project__c = projectId;
        objProjectTask.pse__Start_Date_Time__c = System.now();
        objProjectTask.pse__Started__c = true;
        objProjectTask.pse__Status__c = 'Complete';
        objProjectTask.pse__Summary__c = true;
        objProjectTask.pse__Task_Key_Chain__c = '90b';
        objProjectTask.pse__Task_Key__c = '90b';
        objProjectTask.pse__Task_Name_Chain_Long__c = 'Initiate';
        objProjectTask.pse__Task_Name_Chain__c = 'Initiate';
        return objProjectTask;
    }

    public static Site__c createSite()
    {
        Site__c objSite     =   new Site__c();
        objSite.OwnerId = UserInfo.getUserId();
        objSite.Name = 'Texas_SAN ANTONIO Site';
        objSite.CurrencyIsoCode = 'USD';
        objSite.Status__c = 'Active';
        return objSite;
    }
    
    public static pse__Proj__c createBasicProject()
    {
        pse__Proj__c objProj     =   new pse__Proj__c();
        objProj.OwnerId = UserInfo.getUserId();
        objProj.Name = 'TEST BASIC PROJECT';
        objProj.pse__Is_Template__c = true;
        objProj.pse__Start_Date__c = System.today() + 1;
        objProj.pse__End_Date__c = System.today() + 16;
        objProj.pse__Project_Phase__c = 'Setup';
        objProj.pse__Project_Type__c = 'Standard';
        objProj.pse__Stage__c = 'Draft';
        objProj.pse__Is_Active__c = true;
        return objProj;
    }

    public static Project_Location__c createProjectSite(Id projectId, Id siteId)
    {
        Schema.Location objLocation = new Schema.Location();
        objLocation.OwnerId = UserInfo.getUserId();
        objLocation.Name = '233 N Michigan Ave_Chicago';
        objLocation.CurrencyIsoCode = 'USD';
        objLocation.LocationType = 'Site';
        objLocation.IsMobile = false;
        objLocation.IsInventoryLocation = false;
        insert objLocation;

        Schema.Address objAddress = new Schema.Address();
        objAddress.CurrencyIsoCode = 'USD';
        objAddress.ParentId = objLocation.Id;
        objAddress.LocationType = 'Warehouse';
        objAddress.AddressType = 'Mailing';
        objAddress.Street = '233 North Michigan Avenue';
        objAddress.City = 'Chicago';
        objAddress.State = 'Illinois';
        objAddress.PostalCode = '60601';
        objAddress.Country = 'United States';
        objAddress.StateCode = 'IL';
        objAddress.CountryCode = 'US';
        objAddress.Latitude = 41.887140000000000;
        objAddress.Longitude = -87.623288000000000;
        objAddress.GeocodeAccuracy = 'Address';
        insert objAddress;

        Project_Location__c objProjectLocation = new Project_Location__c(
            Address_Type__c = 'Install At Contact',
            // Site__c = site.Id,
            Location__c = objLocation.Id,
            Project__c = projectId,
            // Order__c = order.Id,
            Default_Address__c = true
        );
        // Project_Location__c objProject_Site     =   new Project_Location__c();
        // objProject_Site.OwnerId = UserInfo.getUserId();
        // objProject_Site.Name = 'Texas_SAN ANTONIO Site';
        // objProject_Site.CurrencyIsoCode = 'USD';
        // objProject_Site.Address_Type__c = 'Sold to';
        // objProject_Site.Project__c = projectId;
        // objProject_Site.Site__c = siteId;
        // objProject_Site.Site_TimeZone__c = 'UTC';

        return objProjectLocation;
    }
    public static pse__Project_Task__c createProjectTask(Id parentProjectTaskId, Id projectId, Id projectSiteId)
    {
        pse__Project_Task__c objProjectTask     =   new pse__Project_Task__c();
        objProjectTask.OwnerId = UserInfo.getUserId();
        objProjectTask.Name = 'Scoping';
        objProjectTask.CurrencyIsoCode = 'USD';
        objProjectTask.pse__Actual_End_Date_Time__c = System.now().addMonths(1);
        objProjectTask.pse__Actual_Hours__c = 0.00;
        objProjectTask.pse__Actual_Start_Date_Time__c = System.now();
        objProjectTask.pse__Blocked__c = false;
        objProjectTask.pse__Closed_for_Time_Entry__c = false;
        objProjectTask.pse__Completed__c = false;
        objProjectTask.pse__Do_Not_Auto_Update_Parents__c = false;
        objProjectTask.pse__Do_Not_Auto_Update_This_Task__c = false;
        objProjectTask.pse__Duration_Unit__c = 'days';
        objProjectTask.pse__End_Date_Time__c = System.now().addMonths(1);
        objProjectTask.pse__Estimated_Hours__c = 2.00;
        objProjectTask.pse__Flag_Information__c = 'Project Task date range is not covered by Assignments or Resource Requests.Project Task has no associated project task assignment';
        objProjectTask.pse__Flag_Task_Dates_No_Coverage__c = true;
        objProjectTask.pse__Flag_Task_Dates_Partial_Coverage__c = false;
        // objProjectTask.pse__Flag_Task_End_Milestone_Bounds__c = false;
        objProjectTask.pse__Flag_Task_End_Project_Bounds__c = false;
        objProjectTask.pse__Flag_Task_Hours_No_Coverage__c = true;
        objProjectTask.pse__Flag_Task_Hours_Partial_Coverage__c = false;
        // objProjectTask.pse__Flag_Task_Start_Milestone_Bounds__c = false;
        objProjectTask.pse__Flag_Task_Start_Project_Bounds__c = false;
        objProjectTask.pse__Hierarchy_Depth__c = 1;
        objProjectTask.pse__Parent_Task__c = parentProjectTaskId;
        objProjectTask.pse__Percent_Complete_Points__c = 0.00;
        objProjectTask.pse__Percent_Complete_Tasks__c = 0.00;
        objProjectTask.pse__Points_Complete__c = 0.00;
        objProjectTask.pse__Points__c = 0.00;
        objProjectTask.pse__Project__c = projectId;
        objProjectTask.pse__Start_Date_Time__c = System.now();
        objProjectTask.pse__Started__c = false;
        objProjectTask.pse__Status__c = 'Complete';
        objProjectTask.pse__Summary__c = false;
        objProjectTask.pse__Task_Key_Chain__c = '90e,90b';
        objProjectTask.pse__Task_Key__c = '90e';
        objProjectTask.pse__Task_Name_Chain_Long__c = 'Scoping->Initiate';
        objProjectTask.pse__Task_Name_Chain__c = 'Scoping->Initiate';
        objProjectTask.pse__Top_level_Parent_Task__c = parentProjectTaskId;
        // objProjectTask.Project_Site__c = projectSiteId;
        return objProjectTask;
    }
    
    public static WorkOrder createWorkOrder(String strStatus, Id accountId, Id projectId, Id projectTaskId, Id workTypeId) 
    {
        WorkOrder objWorkOrder     =   new WorkOrder();
        objWorkOrder.OwnerId = UserInfo.getUserId();
        objWorkOrder.CurrencyIsoCode = 'USD';
        objWorkOrder.RecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('Installation_Badge').getRecordTypeId();
        objWorkOrder.AccountId = accountId;
        objWorkOrder.Subject = 'Prepare Installation';//'Prepare Installation'
        objWorkOrder.Status = strStatus;
        objWorkOrder.Priority = 'Low';
        // objWorkOrder.IsStopped = false;
        objWorkOrder.Duration = 4.00;
        objWorkOrder.DurationType = 'Hours';
        objWorkOrder.WorkTypeId = workTypeId;
        objWorkOrder.AD_Override_Flg__c = false;
        objWorkOrder.AddressBUID__c = '11';
        objWorkOrder.B2B_Flag__c = false;
        objWorkOrder.B2C_Flag__c = false;
        objWorkOrder.CheckForServiceTypeEqualsLaborOnly__c = false;
        objWorkOrder.Complete_Care_Option__c = false;
        objWorkOrder.FSD_Approval_Needed__c = false;
        objWorkOrder.FSD_DASP_Flag__c = false;
        objWorkOrder.ISPReportingFlag__c = false;
        objWorkOrder.IsDeferralAllowed__c = false;
        objWorkOrder.IsScheduled__c = false;
        objWorkOrder.KYC__c = false;
        objWorkOrder.KYHD__c = false;
        objWorkOrder.Out_of_Warranty__c = false;
        objWorkOrder.Push_address_update_to_asset__c = false;
        objWorkOrder.Verified_with_Customer__c = false;
        objWorkOrder.schedulingInternalLogic__c = 'Neither';
        objWorkOrder.Alternate_Return_Address_Checkbox__c = false;
        objWorkOrder.Ground_Shipment_Flag__c = false;
        objWorkOrder.Override_Ground_Shipment__c = false;
        objWorkOrder.CFIImage__c = false;
        objWorkOrder.CFINumCheck__c = false;
        objWorkOrder.CFI_Exists__c = false;
        objWorkOrder.Count_for_Rework__c = 0;
        objWorkOrder.Count_of_Held_for_Review__c = 0;
        objWorkOrder.Delivery_Method__c = 'OnSite';
        objWorkOrder.DeltaUpdateFlag__c = false;
        objWorkOrder.Postal_Code_Changed__c = false;
        objWorkOrder.Project_Task__c = projectTaskId;
        objWorkOrder.Resource_Type__c = 'Badge';
        objWorkOrder.Schedule_Type__c = 'Appointment';
        objWorkOrder.WO_Type__c = 'Install';
        objWorkOrder.Auto_Dispatch__c = false;
        objWorkOrder.Is_Asset_within_Invoice_Period__c = false;
        objWorkOrder.Korea_Monitor__c = false;
        objWorkOrder.Project__c = projectId;
        objWorkOrder.Bulk_Approval__c = false;
        objWorkOrder.Sanbao_FLG__c = false;
        objWorkOrder.Reprocessed_Count__c = 0;
        objWorkOrder.Reprocessed_WorkOrder__c = true;
        objWorkOrder.Manual_Reprocess__c = false;

        return objWorkOrder;
    }

    /**
	 * @description Metodo para generar el código Apex de los metodos que generan datos para las clases de prueba
	 * @param String strApiObjeto
	 * @param String strId
	 * @return String
	 **/
	public static String generarCodigo(String strApiObjeto,String strIdRecord)
	{

		/*
			CVV_TestDataGenerator_cls.generarCodigo('Opportunity','0062F000003edGjQAI');
		*/
		String strcampos            =   '';
		String strNombreVariable    =   strApiObjeto.replace('ARC_', '');
		strNombreVariable           =   'obj'+strNombreVariable.replace('__c','');
		String strCodigo            =   strApiObjeto +' '+ strNombreVariable+'     =   new '+strApiObjeto+'();\n';

		Map<String, Schema.SObjectField> mapDesField    =   Schema.getGlobalDescribe().get(strApiObjeto).getDescribe().Fields.getMap();
		Schema.DescribeFieldResult  objDesField;

		for(Schema.SObjectField ft : mapDesField.values())// describe  cada campo de cada objeto.
		{
			objDesField         =   ft.getDescribe();
			if (objDesField.isCreateable())
				strcampos       +=  objDesField.getName()+',';
		}
		strcampos   =   strcampos.removeEnd(',');

		List<SObject> lstSObjects       =   Database.query('SELECT '+strcampos+' FROM '+strApiObjeto+ ' WHERE Id =\''+strIdRecord+'\'');
		SObject objSO;
		Set<String> setTipoDatoStr      =   new Set<String>();
		setTipoDatoStr.add('PICKLIST');
		setTipoDatoStr.add('TEXTAREA');
		setTipoDatoStr.add('REFERENCE');
		setTipoDatoStr.add('STRING');
		setTipoDatoStr.add('EMAIL');
		setTipoDatoStr.add('PHONE');
		setTipoDatoStr.add('MULTIPICKLIST');
		setTipoDatoStr.add('URL');


		if(!lstSObjects.isEmpty())
		{
			objSO       =   lstSObjects.get(0);
			for(Schema.SObjectField ft : mapDesField.values())// describe  cada campo de cada objeto.
			{
				objDesField         =   ft.getDescribe();
				if (objDesField.isCreateable() && objSO.get(objDesField.getName()) != null)
				{
					if(objDesField.getName()=='RecordTypeId')
					{
						strCodigo   +=  strNombreVariable+'.'+ objDesField.getName()+' = Schema.SObjectType.'+strApiObjeto+'.getRecordTypeInfosByName().get(\'Record_Type_Nombre\').getRecordTypeId();\n';
					}else
					{
						if( (''+objDesField.getType()) != 'DATE' && (''+objDesField.getType()) != 'DATETIME')
						{
							if (setTipoDatoStr.contains(''+objDesField.getType()))
								strCodigo   +=strNombreVariable+'.'+objDesField.getName()+' = \''+objSO.get(objDesField.getName())+'\';\n';
							else
								strCodigo   +=strNombreVariable+'.'+objDesField.getName()+' = '+objSO.get(objDesField.getName())+';\n';
						}
						else if( (''+objDesField.getType()) == 'DATE')
						{
							strCodigo   += strNombreVariable+'.'+objDesField.getName()+' = System.today();\n';
						}
						else 
						{
							strCodigo   += strNombreVariable+'.'+objDesField.getName()+' = System.now();\n';
						}
					}
				}
			}
		}
		System.debug('CODIGO----->>  '+strCodigo);
		return strCodigo;
	}
}