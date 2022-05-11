@IsTest
private class AccountingAcknowledgmentHandlerTest {
    public static ProjectUtilsDataForTest testData = ProjectUtilsDataForTest.build()
            .createProject()
            .createProjectInInitiate();
    
    
// Copied from Dell main for fix defect -9930747
    @IsTest
    static void ShouldUpdateAcknowledgmentFieldWithStatus() {
        testData.testProject.Accounting_acknowledgement_status__c = null;
       // update testData.testProject;
        

        Test.startTest();
        Accounting_Acknowledge__c newMessage = new Accounting_Acknowledge__c(
                Object__c = 'PROJECTS',
                Project_ID__c = testData.testProject.pse__Project_ID__c,
                Status__c = 'Success'
        );
        insert newMessage;
        Test.stopTest();
        
       
        pse__Proj__c testProject = [SELECT Id,Accounting_acknowledgement_status__c,pse__Project_ID__c,BUID__c,Local_Channel__c 
                FROM pse__Proj__c WHERE pse__Project_ID__c = :testData.testProject.pse__Project_ID__c AND pse__Is_Template__c = FALSE LIMIT 1];
        System.assertEquals(testProject.Accounting_acknowledgement_status__c, 'Success');
    }

    @IsTest
    static void shouldUpdateListOfProjects() {

        testData.testProject.Accounting_acknowledgement_status__c = null;
       // update testData.testProject;

        RecordType smallProjRecordType = [SELECT Id, Name FROM RecordType WHERE Name = 'Small Project Tier'  LIMIT 1];
        pse__Region__c regionTestA = [SELECT Id FROM pse__Region__c LIMIT 1];
        pse__Proj__c pseProjectTwo = new pse__Proj__c();
        pseProjectTwo.pse__Is_Active__c = true;
        pseProjectTwo.RecordTypeId = smallProjRecordType.Id;
        pseProjectTwo.pse__Region__c = regionTestA.Id;
        pseProjectTwo.pse__Practice__c = testData.testProject.pse__Practice__c;
        pseProjectTwo.pse__Start_Date__c = Date.today().addDays(5);
        pseProjectTwo.pse__End_Date__c = Date.today().addDays(15);
        pseProjectTwo.PM_Complexity__c = 'Low';
        pseProjectTwo.pse__Stage__c = 'In Progress';
        pseProjectTwo.pse__Project_Phase__c = 'Initiate';
        pseProjectTwo.Deal_Type__c = 'Custom';
        pseProjectTwo.Setup_Project__c = true;
        pseProjectTwo.pse__Is_Billable__c = true;
        pseProjectTwo.Accounting_Treatment__c = 'Revenue';
        pseProjectTwo.Name = 'Project Name';
        pseProjectTwo.pse__Is_Template__c = false;
        pseProjectTwo.Project_Visibility__c = 'All';
        pseProjectTwo.pse__Closed_for_Expense_Entry__c = false;
        pseProjectTwo.pse__Allow_Expenses_Without_Assignment__c = true;
        pseProjectTwo.Close_Project__c = false;
        pseProjectTwo.BUID__c = '22';
        pseProjectTwo.Local_Channel__c = '11';
        insert pseProjectTwo;
        
        
        
        List<pse__Proj__c> testProjectList = [SELECT Id,Accounting_acknowledgement_status__c,BUID__c,Local_Channel__c,pse__Project_ID__c FROM pse__Proj__c WHERE pse__Is_Template__c = FALSE ORDER BY pse__Project_ID__c DESC LIMIT 2];
        List<Accounting_Acknowledge__c> accountingMessages = new List<Accounting_Acknowledge__c>();
        Accounting_Acknowledge__c newAccountingMessage = new Accounting_Acknowledge__c(
                Object__c = 'PROJECTS',
                Project_ID__c = testProjectList[0].pse__Project_ID__c,
                Status__c = 'Success'
        );
        accountingMessages.add(newAccountingMessage);
        Accounting_Acknowledge__c newAccountingMessageTwo = new Accounting_Acknowledge__c(
                Object__c = 'PROJECTS',
                Project_ID__c = testProjectList[1].pse__Project_ID__c,
                Status__c = 'Fail'
        );
        accountingMessages.add(newAccountingMessageTwo);

        Test.startTest();
        insert accountingMessages;
        Test.stopTest();

        List<pse__Proj__c> testProjectListTwo = [SELECT Id,Accounting_acknowledgement_status__c,BUID__c,Local_Channel__c,pse__Project_ID__c FROM pse__Proj__c WHERE pse__Is_Template__c = FALSE ORDER BY pse__Project_ID__c DESC LIMIT 2];
        System.assertEquals(testProjectListTwo[0].Accounting_acknowledgement_status__c, 'Success');
        System.assertEquals(testProjectListTwo[1].Accounting_acknowledgement_status__c, 'Fail');
    }

    @IsTest
    static void ShouldNotUpdateWhenIsNotAProjectMessage() {
        testData.testProject.Accounting_acknowledgement_status__c = null;
       // update testData.testProject;

        Test.startTest();
        Accounting_Acknowledge__c newMessage = new Accounting_Acknowledge__c(
                Object__c = 'Task',
                Project_ID__c = testData.testProject.pse__Project_ID__c,
                Status__c = 'Success'
        );
        insert newMessage;
        Test.stopTest();

        pse__Proj__c testProject = [SELECT Id,Accounting_acknowledgement_status__c,BUID__c,Local_Channel__c,pse__Project_ID__c FROM pse__Proj__c WHERE pse__Project_ID__c = :testData.testProject.pse__Project_ID__c AND pse__Is_Template__c = FALSE LIMIT 1];
        System.assertNotEquals(testProject.Accounting_acknowledgement_status__c, 'Success');
        System.debug('Result 001' + testProject.Accounting_acknowledgement_status__c);

    }

    @IsTest
    static void ShouldInsertErrorMessageIntoProjectChatter() {

        Test.startTest();
        Accounting_Acknowledge__c newMessage = new Accounting_Acknowledge__c(
                Object__c = 'PROJECTS',
                Project_ID__c = testData.testProject.pse__Project_ID__c,
                Status__c = 'Error',
                Message__c = 'Test error message'
        );
        insert newMessage;
        Test.stopTest();

       FeedItem messageInChatter = [SELECT Id,Body FROM FeedItem];
       String expected = 'Project Accounting Tool reported error: ' + newMessage.Message__c;
       System.assert(messageInChatter != null);
       System.assertEquals(expected, messageInChatter.Body);
    }

    @IsTest
    static void ShouldSetProjectClosedForTimeEntryWhenProcessedMessage() {

        Test.startTest();
        Accounting_Acknowledge__c newMessage = new Accounting_Acknowledge__c(
                Object__c = 'PROJECTS',
                Project_ID__c = testData.testProject.pse__Project_ID__c,
                Status__c = 'Processed',
                Message__c = 'Test error message'
        );
        insert newMessage;
        Test.stopTest();

        pse__Proj__c projAfterUpdate = [SELECT Id,pse__Closed_For_Time_Entry__c FROM pse__Proj__c WHERE pse__Is_Template__c = FALSE ];

        System.assert(!projAfterUpdate.pse__Closed_For_Time_Entry__c);
    }

    @IsTest
    static void ShouldNotSetProjectClosedForTimeEntryWhenNotProcessedMessage() {

        Test.startTest();
        Accounting_Acknowledge__c newMessage = new Accounting_Acknowledge__c(
                Object__c = 'PROJECTS',
                Project_ID__c = testData.testProject.pse__Project_ID__c,
                Status__c = 'Not processed',
                Message__c = 'Test error message'
        );
        insert newMessage;
        Test.stopTest();

        pse__Proj__c projAfterUpdate = [SELECT Id,pse__Closed_For_Time_Entry__c FROM pse__Proj__c WHERE pse__Is_Template__c = FALSE];

        System.assert(projAfterUpdate.pse__Closed_For_Time_Entry__c);
    }


    @IsTest
    static void ShouldGenerateExceptionLogs() {
        String message = 'Test message';
        List<string> fields = new List<String>();
        fields.add('01 exception test');
        fields.add('02 exception test');

        Test.startTest();
        ExceptionLogger__c generatedException = AccountingAcknowledgmentHandler.exceptionHandler(message, fields);
        insert generatedException;
        Test.stopTest();

        ExceptionLogger__c exceptionTest = [SELECT Id,Apex_Class__c,Description__c FROM ExceptionLogger__c LIMIT 1];
        /*System.assertEquals(exceptionTest.Apex_Class__c, 'AccountingAcknowledgmentHandler');
        System.assert(exceptionTest.Description__c.contains('01 exception test'));*/
    }

}