// /**
// * @author Thomas Davis <thdavis@financialforce.com>
// * @date 2020-03-17
// * @description Test class for ProjectDateHandler.cls.
// * TFS Story 8014293.
// */
 @IsTest
 private class ProjectDateHandlerTest
 {
    @TestSetup
    static void setup()
    {
        Test.startTest();

        pse__Region__c testRegion = new pse__Region__c(
                Name = 'Test Region'
        );
        insert testRegion;
        
        pse__Time_Period__c objTimePeriod = TestDataGenerator.createTimePeriod();
			insert objTimePeriod;
        
          pse__Proj__c projToPractice = MDF_ProjectTemplateFactory.start()
            .projectPhase('Setup')
            .projectType('Standard')
            .stage('Draft')
            .isActive(true)
            .create();
            
            pse__Practice__c objPractice = TestDataGenerator.createPractice(objTimePeriod.Id, projToPractice.Id);
            objPractice.Id = null;
            objPractice.Standard_Project_Template__c = projToPractice.Id;
            insert objPractice;

      /*  pse__Practice__c testPractice = new pse__Practice__c(
                Name = 'Test Practice'
        );
        insert testPractice;*/

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
                pse__Practice__c = objPractice.Id
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
                pse__Practice__c = objPractice.Id,
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
    static void testProjectStart()
    {
        // ARRANGE
        pse__Proj__c project =
        [
                SELECT pse__Start_Date__c
                FROM pse__Proj__c
                LIMIT 1
        ];

        // ACT
        project.pse__Start_Date__c = System.today() + 2;

        try
        {
            Test.startTest();
            update project;
            Test.stopTest();
        }
        catch (Exception e)
        {
          //   ASSERT
            System.assert(e.getMessage().contains('Project Start Date cannot be later than earliest Task Start Date.'));
        }
    }

    @IsTest
    static void testProjectEnd()
    {
        // ARRANGE
        pse__Proj__c project =
        [
                SELECT pse__End_Date__c
                FROM pse__Proj__c
                LIMIT 1
        ];

        // ACT
        project.pse__End_Date__c = System.today() + 6;

        try
        {
            Test.startTest();
            update project;
            Test.stopTest();
        }
        catch (Exception e)
        {
          //   ASSERT
            System.assert(e.getMessage().contains('Project End Date cannot be earlier than latest Task End Date.'));
        }
    }
 }