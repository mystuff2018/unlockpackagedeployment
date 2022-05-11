/**
* @author Thomas Davis <thdavis@financialforce.com>
* @date 2020-03-04
* @description Test class for ProjectTaskDateRollupHandler.cls.
* TFS Stories 7978722 and 7978728.
*/
@IsTest
private class ProjectTaskDateRollupHandlerTest
{
    @TestSetup
    static void setup()
    {
        Test.startTest();

        pse__Region__c testRegion = new pse__Region__c(
                Name = 'Test Region'
        );
        insert testRegion;
        
        pse__Proj__c projectTemplate = TestDataUtility.createProject(true);
            
            pse__Practice__c testPractice = new pse__Practice__c(
                Name = 'Test Practice',
                Standard_Project_Template__c = projectTemplate.Id
            );
        
        insert testPractice;

        pse__Permission_Control__c testPC = new pse__Permission_Control__c(
                pse__User__c = UserInfo.getUserId(),
                pse__Region__c = testRegion.Id,
                pse__Staffing__c = true,
                pse__Cascading_Permission__c = true
        );
        insert testPC;

        Contact testContact = new Contact(
                FirstName = 'Test',
                LastName = 'Test Contact',
                Primary_Phone__c = '555-5555',
                Email = 'test@email.com',
                Phone = '555-5555',
                TimeZone__c = 'Eastern Time',
                Badge_ID__c = '1234567',
                pse__Is_Resource__c = true,
                pse__Salesforce_User__c = UserInfo.getUserId(),
                pse__Is_Resource_Active__c = true,
                pse__Region__c = testRegion.Id,
                pse__Practice__c = testPractice.Id
        );

        pse__Proj__c testProject = new pse__Proj__c(
                Name = 'Test Project',
                pse__Start_Date__c = System.today() + 1,
                pse__End_Date__c = System.today() + 16,
                pse__Project_Phase__c = 'Setup',
                pse__Project_Type__c = 'Standard',
                pse__Stage__c = 'Draft',
                pse__Project_Manager__c = testContact.Id,
                pse__Region__c = testRegion.Id,
                pse__Practice__c = testPractice.Id,
                pse__Is_Active__c = true
        );
        insert testProject;
        testProject.pse__End_Date__c = System.today() + 7;
        update testProject;

        pse__Project_Task__c testProjectTask = new pse__Project_Task__c(
                Name = 'Test Project Task',
                pse__Start_Date_Time__c = System.now() + 1,
                pse__End_Date_Time__c = System.now() + 7,
                pse__Actual_Start_Date_Time__c = System.now(),
                pse__Actual_End_Date_Time__c = System.now() + 7,
                Project_Task_Start_Date__c = System.today(),
                Project_Task_End_Date__c = System.today() + 7,
                pse__Estimated_Hours__c = 8,
                pse__Project__c = testProject.Id
        );
        insert testProjectTask;

        Test.stopTest();
    }

    @IsTest
    static void test()
    {
        // ARRANGE
        pse__Project_Task__c projectTask =
        [
                SELECT pse__Start_Date_Time__c, pse__End_Date_Time__c
                FROM pse__Project_Task__c
                LIMIT 1
        ];

        // ACT
        Test.startTest();
        projectTask.pse__Start_Date_Time__c = System.now();
        projectTask.pse__End_Date_Time__c = System.now() + 8;
        update projectTask;
        Test.stopTest();

        // ASSERT
        pse__Proj__c project =
        [
                SELECT pse__Start_Date__c, pse__End_Date__c
                FROM pse__Proj__c
                LIMIT 1
        ];

        //System.assertEquals(project.pse__Start_Date__c, projectTask.pse__Start_Date_Time__c.date());
        //System.assertEquals(project.pse__End_Date__c, projectTask.pse__End_Date_Time__c.date());
    }
}