/**
* @author Thomas Davis <thdavis@financialforce.com>
* @date 2020-02-25
* @description Test class for SADateRollupHandler.cls.
* TFS Story 7693685.
*/
@IsTest(IsParallel = true)
private class SADateRollupHandlerTest
{
    @TestSetup
    static void setup()
    {
        Test.startTest();
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){
            
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
                pse__Start_Date__c = System.today(),
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
            
            Account account = new Account();
            account.Name = 'AccountName';
            account.Site_Access_Required__c = 'Yes';
            insert account;
            
            Id woRecordTypeId = Schema.SObjectType.WorkOrder
                .getRecordTypeInfosByDeveloperName().get('Installation_Badge')
                .getRecordTypeId();
            WorkOrder testWorkOrder = new WorkOrder(
                ContactId = testContact.Id,
                IsConvergeWorkOrder__c = false,
                Duration = 8,
                Delivery_Method__c = 'Remote',
                Project_Task__c = testProjectTask.Id,
                Project__c = testProject.Id,
                RecordTypeId = woRecordTypeId,
                Account = account,
                AccountId = account.Id
            );
            insert testWorkOrder;
            
            Id saRecordTypeId = Schema.SObjectType.ServiceAppointment
                .getRecordTypeInfosByDeveloperName()
                .get('Installation_Badge').getRecordTypeId();
            ServiceAppointment testServiceAppointment = new ServiceAppointment(
                RecordTypeId = saRecordTypeId,
                Work_Order__c = testWorkOrder.Id,
                EarliestStartTime = System.now(),
                DueDate = System.now() + 1,
                Status = 'Assigned',
                ParentRecordId = testWorkOrder.Id,
                Project__c = testProject.Id,
                Duration = 8,
                Latitude = -34.64646377383453,
                Longitude = -58.39512164685306,
                SchedStartTime = System.now() + 2,
                SchedEndTime = System.now() + 7,
                ActualStartTime = System.now(),
                ActualEndTime = System.now() + 7
            );
            insert testServiceAppointment;
        }
        Test.stopTest();
        
    }
    
    @IsTest
    static void testSASchedStartChange()
    {
        // ARRANGE
        ServiceAppointment testServiceAppointment =
            [
                SELECT SchedStartTime
                FROM ServiceAppointment
                LIMIT 1
            ];
        
        // ACT
        Test.startTest();
        testServiceAppointment.SchedStartTime = System.now();
        update testServiceAppointment;
        Test.stopTest();
        
        // ASSERT
        pse__Project_Task__c testProjectTask =
            [
                SELECT pse__Start_Date_Time__c
                FROM pse__Project_Task__c
                LIMIT 1
            ];
        
        // System.assertEquals(testProjectTask.pse__Start_Date_Time__c, testServiceAppointment.SchedStartTime);
    }
    
    @IsTest
    static void testSASchedEndChange()
    {
        // ARRANGE
        ServiceAppointment testServiceAppointment =
            [
                SELECT SchedEndTime
                FROM ServiceAppointment
                LIMIT 1
            ];
        
        // ACT
        Test.startTest();
        testServiceAppointment.SchedStartTime = System.now();
        testServiceAppointment.SchedEndTime = System.now() + 9;
        update testServiceAppointment;
        Test.stopTest();
        
        // ASSERT
        pse__Project_Task__c testProjectTask =
            [
                SELECT pse__End_Date_Time__c
                FROM pse__Project_Task__c
                LIMIT 1
            ];
        
        //System.assertEquals(testProjectTask.pse__End_Date_Time__c, testServiceAppointment.SchedEndTime);
    }
    
    @IsTest
    static void testSAActualStartChange()
    {
        // ARRANGE
        ServiceAppointment testServiceAppointment =
            [
                SELECT ActualStartTime
                FROM ServiceAppointment
                LIMIT 1
            ];
        
        // ACT
        Test.startTest();
        testServiceAppointment.ActualStartTime = System.now() - 2;
        update testServiceAppointment;
        Test.stopTest();
        
        // ASSERT
        pse__Project_Task__c testProjectTask =
            [
                SELECT pse__Actual_Start_Date_Time__c
                FROM pse__Project_Task__c
                LIMIT 1
            ];
        
        //System.assertEquals(testProjectTask.pse__Actual_Start_Date_Time__c, testServiceAppointment.ActualStartTime);
    }
    
    @IsTest
    static void testSAActualEndChange()
    {
        // ARRANGE
        ServiceAppointment testServiceAppointment =
            [
                SELECT ActualEndTime
                FROM ServiceAppointment
                LIMIT 1
            ];
        
        // ACT
        Test.startTest();
        testServiceAppointment.ActualEndTime = System.now() + 9;
        update testServiceAppointment;
        Test.stopTest();
        
        // ASSERT
        pse__Project_Task__c testProjectTask =
            [
                SELECT pse__Actual_End_Date_Time__c
                FROM pse__Project_Task__c
                LIMIT 1
            ];
        
        //System.assertEquals(testProjectTask.pse__Actual_End_Date_Time__c, testServiceAppointment.ActualEndTime);
    }
    
    //Todo: Reactivate this test once the validation rules on Project and Project Task for
    //      dates before the Project Creation are enabled
    //    @IsTest
    //    static void testException()
    //    {
    //        // ARRANGE
    //        ServiceAppointment testServiceAppointment =
    //        [
    //                SELECT SchedStartTime
    //                FROM ServiceAppointment
    //                LIMIT 1
    //        ];
    //
    //        // ACT
    //        Test.startTest();
    //        testServiceAppointment.SchedStartTime = System.now() - 1;
    //        update testServiceAppointment;
    //        Test.stopTest();
    //
    //        // ASSERT
    //        System.assertEquals(1, [ SELECT Id FROM ExceptionLogger__c ].size());
    //    }
}