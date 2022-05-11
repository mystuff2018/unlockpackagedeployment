@isTest
public class ProjectPhaseChangeTest {

    @isTest
    public static void updateTaskStartEndDate_success(){
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){ 
            pse__Work_Calendar__c workCalendar = new pse__Work_Calendar__c(
                    Name = 'Test Work Calendar'
            );

            insert (workCalendar);

            Account account = new Account(Name = 'Test account');

            insert(account);

            pse__Region__c region =new pse__Region__c (
                    Name = 'Test R1',
                    ISO_Country_Code__c = 'R1'
            );
            insert region;

            Profile profile = [SELECT Id FROM Profile WHERE Name = 'PSA Project Manager'];

            User user = new User(
                    UserName = 'pm_test_user@dell.com',
                    LastName = 'One',
                    Email = 'pm_test_user@dell.com',
                    Alias = 't1',
                    CommunityNickname = 't1',
                    Federal_Access__c = false,
                    FederationIdentifier = '22334466',
                    TimeZoneSidKey = 'America/Los_Angeles',
                    LocaleSidKey = 'en_US',
                    EmailEncodingKey = 'UTF-8',
                    ProfileId = profile.Id,
                    LanguageLocaleKey = 'en_US',
                    OSP__c = 'No',
                    Dell_NTUserID__c = 'TEST_USER',
                    Service_User_Type__c = 'Service Account',
                    External_ID__c = '22334466',
                    Organization__c = 'Test Org',
                    File_Source__c = 'AMS - System Admin',
                    EmployeeNumber = '1236'
            );

            insert user;

            Contact contact = new Contact(
                    FirstName = 'Test',
                    LastName = 'Test',
                    Email = 'pm_test_user@dell.com',
                    AccountId = account.Id,
                    pse__Salesforce_User__c = user.Id,
                    pse__Region__c = region.Id,
                    pse__Work_Calendar__c = workCalendar.Id,
                    pse__Is_Resource_Active__c = true,
                    pse__Is_Resource__c = true,
                	phone='1234567890'
            );

            insert contact;

            // create Skills
            List<pse__Skill__c> skills = new List<pse__Skill__c>();
            skills.add(new pse__Skill__c(Name = 'Project Management (Low)',pse__External_Id__c='9321'));
            skills.add(new pse__Skill__c(Name = 'Project Management (Medium)',pse__External_Id__c='9322'));
            skills.add(new pse__Skill__c(Name = 'Project Management (High)',pse__External_Id__c='9323'));

            insert skills;

            List<Project_Complexity_Threshold__c> projComplexities = new List<Project_Complexity_Threshold__c>();

            projComplexities.add(new Project_Complexity_Threshold__c (
                Name = 'R1',
                Low_Threshold__c = 1000,
                High_Threshold__c = 2000
            ));

            insert projComplexities;

            List<Project_Complexity_Mapping__c> projComplexityMappings = new List<Project_Complexity_Mapping__c>();

            projComplexityMappings.add(new Project_Complexity_Mapping__c (
                Overall_Project_Complexity__c = 'Low',
                PM_Complexity__c = 'Low',
                Revenue_Threshold__c = 'Low'
            ));

            projComplexityMappings.add(new Project_Complexity_Mapping__c (
                Overall_Project_Complexity__c = 'Medium',
                PM_Complexity__c = 'Medium',
                Revenue_Threshold__c = 'Medium'
            ));

            projComplexityMappings.add(new Project_Complexity_Mapping__c (
                Overall_Project_Complexity__c = 'High',
                PM_Complexity__c = 'High',
                Revenue_Threshold__c = 'High'
            ));

            insert projComplexityMappings;

            //create Project
            string taskName = 'Planning';
            string subTaskName = 'Configuration';
            decimal subTaskEstimatedhours = 4;
            pse__Proj__c project = SKUEffortMappingTestDataFactory.createProjectWithTaskAndSubTask(taskName, subTaskName, subTaskEstimatedhours);
            
            //create Effort Map Entry
            decimal orderItemQtd = 2;
            OrderItem orderItem = SKUEffortMappingTestDataFactory.createOrderAndOrderItems(orderItemQtd);
        
            decimal estimatedHours = 4;
            SKU_Effort_Map_Entry__c effortMapEntry = SKUEffortMappingTestDataFactory.createEffortMapEntry(taskName, subTaskName, estimatedHours, true);     
        
            Test.startTest();
                project.pse__Project_Manager__c = contact.Id;
                project.pse__Region__c = region.Id;
                project.PM_Complexity__c = 'Low';
                project.pse__Start_Date__c = Date.today();
                project.pse__End_Date__c = Date.today().addDays(60); 
                project.pse__Project_Phase__c = 'Initiate';


                update project;

            Test.stopTest();
            for(pse__Project_Task__c taskCreated : [SELECT Id, Name, pse__Start_Date_Time__c, pse__End_Date_Time__c FROM pse__Project_Task__c WHERE pse__Project__c = :project.Id]){
                system.assertEquals(taskCreated.pse__Start_Date_Time__c,  TimezoneHelper.conversionDateToDateTime(project.pse__Start_Date__c, 12));
                system.assertEquals(taskCreated.pse__End_Date_Time__c,  TimezoneHelper.conversionDateToDateTime(project.pse__End_Date__c, 12));
            }    
        }
    }   
}