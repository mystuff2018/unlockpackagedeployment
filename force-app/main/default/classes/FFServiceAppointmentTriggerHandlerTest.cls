/*
* Thomas Davis
* 2019-01-15
* FinancialForce.com, Inc.
* thdavis@financialforce.com
*
* Provides test code coverage for the following assets:
*
* METHODS:
* FFServiceAppointmentHandler.cancelClickTask()
* FFServiceAppointmentHandler.setNumberField()
* FFServiceAppointmentHandler.populateAssignment()
* FFServiceAppointmentHandler.synchronizeWorkOrderStatus()
* FFServiceAppointmentHandler.physicalHelperRequested()
*
* CLASSES:
* CancelTaskRequest.cls
* CancelTaskResponse.cls
*/

@IsTest
public class FFServiceAppointmentTriggerHandlerTest {
    @TestSetup
    static void setup()
    {
        
    }
    
    @IsTest
    public static void testCustomerNameonSA()
    {
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
            
            Contact testContact = new Contact(
                FirstName = 'Test',
                LastName = 'Test Contact',
                Primary_Phone__c = '5555555555',
                Email = 'test@email.com',
                Phone = '5555555555',
                TimeZone__c = 'Central Time',
                pse__Is_Resource__c = true,
                pse__Salesforce_User__c = UserInfo.getUserId(),
                pse__Is_Resource_Active__c = true,
                pse__Region__c = testRegion.Id,
                pse__Practice__c = testPractice.Id
            );
            INSERT testContact;
            
            pse__Proj__c testProject = new pse__Proj__c(
                Name = 'Test Project',
                pse__Start_Date__c = System.today(),
                pse__End_Date__c = System.today() + 7,
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
                pse__Start_Date_Time__c = System.now(),
                pse__End_Date_Time__c = System.now() + 7,
                pse__Estimated_Hours__c = 8,
                pse__Started__c = true,
                pse__Project__c = testProject.Id
            );
            insert testProjectTask;
            
            Id installationBadgeRecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('Installation_Badge').getRecordTypeId();
            
            Account account = new Account();
            account.Name = 'AccountName';
            account.Site_Access_Required__c = 'Yes';
            insert account;
            
            WorkOrder testWorkOrder = new WorkOrder();
            testWorkOrder.Account = account;
            testWorkOrder.AccountId = account.Id;
            testWorkOrder.Status = 'FF - Work In Progress';
            testWorkOrder.RecordTypeId = installationBadgeRecordTypeId;
            testWorkOrder.Project_Task__c = testProjectTask.Id;
            insert testWorkOrder;
            
            pse__Permission_Control__c testPC = new pse__Permission_Control__c(
                pse__User__c = UserInfo.getUserId(),
                pse__Region__c = testRegion.Id,
                pse__Staffing__c = true,
                pse__Cascading_Permission__c = true
            );
            insert testPC;
            Test.startTest();
            Id installationBadgeRecordType = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByName().get('Installation - Badge').getRecordTypeId();
            
            List<ServiceAppointment> serviceappointment_Obj = new List<ServiceAppointment>{
                new ServiceAppointment(EarliestStartTime = System.now(),DueDate = System.now() + 7, ParentRecordId = account.Id, Status = 'New', RecordTypeId = installationBadgeRecordType),
                    new ServiceAppointment(EarliestStartTime = System.now(),DueDate = System.now() + 7, ParentRecordId = testWorkOrder.Id, Status = 'New', RecordTypeId = installationBadgeRecordType),
                    new ServiceAppointment(EarliestStartTime = System.now(),DueDate = System.now() + 7, ParentRecordId = account.Id, Status = 'New', RecordTypeId = installationBadgeRecordType)
                    };
                        insert serviceappointment_Obj;
            String myJSON = JSON.serialize(serviceappointment_Obj);
            Test.stopTest();
            ServiceAppointment updatedSA = [ SELECT FBE_IDS_Customer_Name__c FROM ServiceAppointment LIMIT 1];
           // System.assertEquals( updatedSA.FBE_IDS_Customer_Name__c, 'AccountName');
        }
    }
    
    
    @IsTest
    static void testCancelAppointment()
    {
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
            
            Test.startTest();
            
            Contact testContact = new Contact(
                FirstName = 'Test',
                LastName = 'Test Contact',
                Primary_Phone__c = '5555555555',
                Email = 'test@email.com',
                Phone = '5555555555',
                TimeZone__c = 'Central Time',
                pse__Is_Resource__c = true,
                pse__Salesforce_User__c = UserInfo.getUserId(),
                pse__Is_Resource_Active__c = true,
                pse__Region__c = testRegion.Id,
                pse__Practice__c = testPractice.Id
            );
            INSERT testContact;
            
            pse__Proj__c testProject = new pse__Proj__c(
                Name = 'Test Project',
                pse__Start_Date__c = System.today(),
                pse__End_Date__c = System.today() + 7,
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
                pse__Start_Date_Time__c = System.now(),
                pse__End_Date_Time__c = System.now() + 7,
                pse__Estimated_Hours__c = 8,
                pse__Started__c = true,
                pse__Project__c = testProject.Id
            );
            insert testProjectTask;
            
            Id installationBadgeRecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('Installation_Badge').getRecordTypeId();
            
            Account account = new Account();
            account.Name = 'AccountName';
            account.Site_Access_Required__c = 'Yes';
            insert account;
            
            WorkOrder testWorkOrder = new WorkOrder();
            testWorkOrder.Account = account;
            testWorkOrder.AccountId = account.Id;
            testWorkOrder.Status = 'FF - Work In Progress';
            testWorkOrder.RecordTypeId = installationBadgeRecordTypeId;
            testWorkOrder.Project_Task__c = testProjectTask.Id;
            insert testWorkOrder;
            
            pse__Permission_Control__c testPC = new pse__Permission_Control__c(
                pse__User__c = UserInfo.getUserId(),
                pse__Region__c = testRegion.Id,
                pse__Staffing__c = true,
                pse__Cascading_Permission__c = true
            );
            insert testPC;
            
            pse__Schedule__c objScheduleTest = new pse__Schedule__c();
            objScheduleTest.pse__Start_Date__c = System.now().Date();
            objScheduleTest.pse__End_Date__c = System.now().Date() + 15;
            
            insert objScheduleTest;
            
            // Create the Assignment
            pse__Assignment__c objAssignmentTest = new pse__Assignment__c(
                pse__Resource__c = testContact.Id,
                pse__Resource__r = testContact,
                pse__Project__c = testProject.Id,
                pse__Project__r = testProject,
                pse__Bill_Rate__c = 0,
                pse__Schedule__c = objScheduleTest.Id,
                pse__Schedule__r = objScheduleTest,
                pse__Closed_for_Expense_Entry__c = false
            );
            insert objAssignmentTest;
            
            pse__Project_Task_Assignment__c testPTA = new pse__Project_Task_Assignment__c(
                pse__Assignment__c = objAssignmentTest.Id,
                pse__Project_Task__c = testProjectTask.Id,
                pse__Resource__c = testContact.Id
            );
            
            insert testPTA;
            
            Id installationBadgeRecordType = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByName().get('Installation - Badge').getRecordTypeId();
            List<ServiceAppointment> newSA = new List<ServiceAppointment>();
            ServiceAppointment testSA = new ServiceAppointment(
                Work_Order__c = testWorkOrder.Id,
                EarliestStartTime = System.now(),
                DueDate = System.now() + 7,
                Status = 'New',
                ParentRecordId = testWorkOrder.Id,
                Assignee__c = testContact.Id,
                Assignment__c = objAssignmentTest.Id,
                RecordTypeId = installationBadgeRecordType
            );
            insert testSA;
            ServiceAppointment testSA21 = new ServiceAppointment(
                Work_Order__c = testWorkOrder.Id,
                EarliestStartTime = System.now()+8,
                DueDate = System.now() +14,
                FSL__Related_Service__c = testSA.Id,
                Status = testSA.Status,
                ParentRecordId = testWorkOrder.Id,
                RecordTypeId = installationBadgeRecordType
            );
            insert testSA21;
            
            FSL.GlobalAPIS.addStatusTransition('New', 'Canceled');
            testSA.Status = 'Canceled';
            update testSA;
            Test.stopTest();
            testSA21 = [SELECT Id, Status FROM ServiceAppointment WHERE Id =:testSA21.Id LIMIT 1];           
        }
    }
    /*@IsTest
static void testCancelClickTask()
{
List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
system.runAs(loginUser[0]){
pse__Region__c testRegion = new pse__Region__c(
Name = 'Test Region'
);
insert testRegion;

pse__Practice__c testPractice = new pse__Practice__c(
Name = 'Test Practice'
);
insert testPractice;

Contact testContact = new Contact(
FirstName = 'Test',
LastName = 'Test Contact',
Primary_Phone__c = '555-5555',
Email = 'test@email.com',
Phone = '555-5555',
TimeZone__c = 'Central Time',
pse__Is_Resource__c = true,
pse__Salesforce_User__c = UserInfo.getUserId(),
pse__Is_Resource_Active__c = true,
pse__Region__c = testRegion.Id,
pse__Practice__c = testPractice.Id
);
INSERT testContact;

pse__Proj__c testProject = new pse__Proj__c(
Name = 'Test Project',
pse__Start_Date__c = System.today(),
pse__End_Date__c = System.today() + 7,
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
pse__Start_Date_Time__c = System.now(),
pse__End_Date_Time__c = System.now() + 7,
pse__Estimated_Hours__c = 8,
pse__Started__c = true,
pse__Project__c = testProject.Id
);
insert testProjectTask;

Id installationBadgeRecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('Installation_Badge').getRecordTypeId();

Account account = new Account();
account.Name = 'AccountName';
account.Site_Access_Required__c = 'Yes';
insert account;

WorkOrder testWorkOrder = new WorkOrder();
testWorkOrder.Account = account;
testWorkOrder.AccountId = account.Id;
testWorkOrder.Status = 'FF - Work In Progress';
testWorkOrder.RecordTypeId = installationBadgeRecordTypeId;
testWorkOrder.Project_Task__c = testProjectTask.Id;
insert testWorkOrder;

pse__Permission_Control__c testPC = new pse__Permission_Control__c(
pse__User__c = UserInfo.getUserId(),
pse__Region__c = testRegion.Id,
pse__Staffing__c = true,
pse__Cascading_Permission__c = true
);
insert testPC;

Id installationBadgeRecordType = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByName().get('Installation - Badge').getRecordTypeId();

ServiceAppointment testSA = new ServiceAppointment(
Work_Order__c = testWorkOrder.Id,
EarliestStartTime = System.now(),
DueDate = System.now() + 7,
Status = 'New',
ParentRecordId = testWorkOrder.Id,
RecordTypeId = installationBadgeRecordType
);
insert testSA;

Test.startTest();
Test.setMock(HttpCalloutMock.class, new Mock());
FSL.GlobalAPIS.addStatusTransition('New', 'Canceled');
testSA.Status = 'Canceled';
update testSA;
Test.stopTest();

//ServiceAppointment updatedSA = [ SELECT Click_Task_Cancelled__c FROM ServiceAppointment LIMIT 1];

//System.assert(updatedSA.Click_Task_Cancelled__c == true);
}

}*/
    
    @IsTest
    static void testSetNumberField()
    {
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
            
            Contact testContact = new Contact(
                FirstName = 'Test',
                LastName = 'Test Contact',
                Primary_Phone__c = '5555555555',
                Email = 'test@email.com',
                Phone = '5555555555',
                TimeZone__c = 'Central Time',
                pse__Is_Resource__c = true,
                pse__Salesforce_User__c = UserInfo.getUserId(),
                pse__Is_Resource_Active__c = true,
                pse__Region__c = testRegion.Id,
                pse__Practice__c = testPractice.Id
            );
            INSERT testContact;
            
            pse__Proj__c testProject = new pse__Proj__c(
                Name = 'Test Project',
                pse__Start_Date__c = System.today(),
                pse__End_Date__c = System.today() + 7,
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
                pse__Start_Date_Time__c = System.now(),
                pse__End_Date_Time__c = System.now() + 7,
                pse__Estimated_Hours__c = 8,
                pse__Started__c = true,
                pse__Project__c = testProject.Id
            );
            insert testProjectTask;
            
            Id installationBadgeRecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('Installation_Badge').getRecordTypeId();
            
            Account account = new Account();
            account.Name = 'AccountName';
            account.Site_Access_Required__c = 'Yes';
            insert account;
            
            WorkOrder testWorkOrder = new WorkOrder();
            testWorkOrder.Status = 'FF - Work In Progress';
            testWorkOrder.RecordTypeId = installationBadgeRecordTypeId;
            testWorkOrder.Project_Task__c = testProjectTask.Id;
            testWorkOrder.Account = account;
            testWorkOrder.AccountId = account.Id;
            insert testWorkOrder;
            
            pse__Permission_Control__c testPC = new pse__Permission_Control__c(
                pse__User__c = UserInfo.getUserId(),
                pse__Region__c = testRegion.Id,
                pse__Staffing__c = true,
                pse__Cascading_Permission__c = true
            );
            insert testPC;
            
            Id installationBadgeRecordType = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByName().get('Installation - Badge').getRecordTypeId();
            ServiceAppointment testSA1 = new ServiceAppointment(
                Work_Order__c = testWorkOrder.Id,
                EarliestStartTime = System.now(),
                DueDate = System.now() + 7,
                Status = 'New',
                ParentRecordId = testWorkOrder.Id,
                RecordTypeId = installationBadgeRecordType
            );
            
            ServiceAppointment testSA2 = new ServiceAppointment(
                Work_Order__c = testWorkOrder.Id,
                EarliestStartTime = System.now(),
                DueDate = System.now() + 7,
                Status = 'Scheduled',
                ParentRecordId = testWorkOrder.Id,
                RecordTypeId = installationBadgeRecordType
            );
            
            Test.startTest();
            insert testSA1;
            insert testSA2;
            Test.stopTest();
            
            ServiceAppointment updatedTestSA1 = [ SELECT Number__c FROM ServiceAppointment WHERE Status = 'New' LIMIT 1 ];
            ServiceAppointment updatedTestSA2 = [ SELECT Number__c FROM ServiceAppointment WHERE Status = 'Scheduled' LIMIT 1 ];
            
            System.assert(updatedTestSA1.Number__c == 0);
            //System.assert(updatedTestSA2.Number__c == 1);
        }
    }
    
   /* @IsTest
    static void testPopulateAssignment()
    {
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){
            pse__Region__c testRegion = new pse__Region__c(
                Name = 'Test Region'
            );
            insert testRegion;
            
            pse__Practice__c testPractice = new pse__Practice__c( 
                Name = 'Test Practice'
            );
            insert testPractice;
            
            Contact testContact = new Contact(
                FirstName = 'Test',    
                LastName = 'Test Contact',
                Primary_Phone__c = '555-5555',
                Email = 'test@email.com',
                Phone = '555-5555',
                TimeZone__c = 'Central Time',
                pse__Is_Resource__c = true,
                pse__Salesforce_User__c = UserInfo.getUserId(),
                pse__Is_Resource_Active__c = true,
                pse__Region__c = testRegion.Id,
                pse__Practice__c = testPractice.Id
            );
            INSERT testContact;
            
            pse__Proj__c testProject = new pse__Proj__c(
                Name = 'Test Project',
                pse__Start_Date__c = System.today(),
                pse__End_Date__c = System.today() + 7,
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
                pse__Start_Date_Time__c = System.now(),
                pse__End_Date_Time__c = System.now() + 7,
                pse__Estimated_Hours__c = 8,
                pse__Project__c = testProject.Id
            );
            insert testProjectTask;
            
            Account account = new Account();
            account.Name = 'AccountName';
            account.Site_Access_Required__c = 'Yes';
            insert account;
            
            Id installationBadgeRecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('Installation_Badge').getRecordTypeId();
            WorkOrder testWorkOrder = new WorkOrder();
            testWorkOrder.Status = 'FF - Work In Progress';
            testWorkOrder.RecordTypeId = installationBadgeRecordTypeId;
            testWorkOrder.Project_Task__c = testProjectTask.Id;
            testWorkOrder.Account = account;
            testWorkOrder.AccountId = account.Id;
            insert testWorkOrder;
            
            pse__Permission_Control__c testPC = new pse__Permission_Control__c(
                pse__User__c = UserInfo.getUserId(),
                pse__Region__c = testRegion.Id,
                pse__Staffing__c = true,
                pse__Cascading_Permission__c = true
            );
            insert testPC;
            
            Id installationBadgeRecordType = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByName().get('Installation - Badge').getRecordTypeId();
            
            ServiceAppointment testSA = new ServiceAppointment(
                Work_Order__c = testWorkOrder.Id,
                EarliestStartTime = System.now(),
                DueDate = System.now() + 7,
                Status = 'New',
                ParentRecordId = testWorkOrder.Id,
                Project__c = testProject.Id,
                RecordTypeId = installationBadgeRecordType,
                SchedStartTime = System.now(),
                SchedEndTime = System.now() + 7
            );
            insert testSA;
            
            pse__Schedule__c objScheduleTest = new pse__Schedule__c();
            objScheduleTest.pse__Start_Date__c = System.now().Date();
            objScheduleTest.pse__End_Date__c = System.now().Date() + 7;
            
            insert objScheduleTest;
            
            pse__Assignment__c objAssignmentTest = new pse__Assignment__c(
                pse__Resource__c = testContact.Id,
                pse__Resource__r = testContact,
                pse__Project__c = testProject.Id,
                pse__Project__r = testProject,
                pse__Bill_Rate__c = 0,
                pse__Schedule__c = objScheduleTest.Id,
                pse__Schedule__r = objScheduleTest,
                pse__Closed_for_Expense_Entry__c = false
            );
            insert objAssignmentTest;
            
            pse__Project_Task_Assignment__c testPTA = new pse__Project_Task_Assignment__c(
                pse__Assignment__c = objAssignmentTest.Id,
                pse__Project_Task__c = testProjectTask.Id,
                pse__Resource__c = testContact.Id
            );
            
            insert testPTA;
            
            Test.startTest();
            testSA.Assignee__c = testContact.Id;
            testSA.Assignment__c = objAssignmentTest.Id;
            update testSA;
            
            Test.stopTest();
            
        }
        
    }*/
    
    @IsTest
    static void testSynchronizeWorkOrderStatus()
    {
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
            
            Contact testContact = new Contact(
                FirstName = 'Test',    
                LastName = 'Test Contact',
                Primary_Phone__c = '5555555555',
                Email = 'test@email.com',
                Phone = '5555555555',
                TimeZone__c = 'Central Time',
                pse__Is_Resource__c = true,
                pse__Salesforce_User__c = UserInfo.getUserId(),
                pse__Is_Resource_Active__c = true,
                pse__Region__c = testRegion.Id,
                pse__Practice__c = testPractice.Id
            );
            INSERT testContact;
            
            pse__Proj__c testProject = new pse__Proj__c(
                Name = 'Test Project',
                pse__Start_Date__c = System.today(),
                pse__End_Date__c = System.today() + 7,
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
                pse__Start_Date_Time__c = System.now(),
                pse__End_Date_Time__c = System.now() + 7,
                pse__Estimated_Hours__c = 8,
                pse__Started__c = true,
                pse__Project__c = testProject.Id
            );
            insert testProjectTask;
            
            Account account = new Account();
            account.Name = 'AccountName';
            account.Site_Access_Required__c = 'Yes';
            insert account;
            
            Id installationBadgeRecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('Installation_Badge').getRecordTypeId();
            WorkOrder testWorkOrder = new WorkOrder();
            testWorkOrder.Status = 'FF - New';
            testWorkOrder.RecordTypeId = installationBadgeRecordTypeId;
            testWorkOrder.IsConvergeWorkOrder__c=false;
            testWorkOrder.Project_Task__c = testProjectTask.Id;
            testWorkOrder.Account = account;
            testWorkOrder.AccountId = account.Id;
            insert testWorkOrder;
            
            WorkOrder testWorkOrder1 = new WorkOrder();
            testWorkOrder1.Status = 'FF - New';
            testWorkOrder1.RecordTypeId = installationBadgeRecordTypeId;
            testWorkOrder1.IsConvergeWorkOrder__c=false;
            testWorkOrder1.Project_Task__c = testProjectTask.Id;
            testWorkOrder1.Account = account;
            testWorkOrder1.AccountId = account.Id;
            insert testWorkOrder1;
            
            Id installationBadgeRecordType = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByName().get('Installation - Badge').getRecordTypeId();
            
            ServiceAppointment testSA = new ServiceAppointment(
                Work_Order__c = testWorkOrder.Id,
                EarliestStartTime = System.now(),
                DueDate = System.now() + 7,
                Status = 'New',
                ParentRecordId = testWorkOrder.Id,
                RecordTypeId = installationBadgeRecordType
            );
            insert testSA;
            
            ServiceAppointment testSA21 = new ServiceAppointment(
                Work_Order__c = testWorkOrder.Id,
                EarliestStartTime = System.now(),
                DueDate = System.now() + 7,
                Status = 'New',
                ParentRecordId = testWorkOrder.Id,
                ActualStartTime = System.now() + 1,
                ActualEndTime = System.now() + 2,
                RecordTypeId = installationBadgeRecordType
            );
            insert testSA21;
            
            List<ServiceAppointment> newSAlist = new List<ServiceAppointment>();
            newSAlist.add(testSA21);
            newSAlist.add(testSA);
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new Mock());
            FSL.GlobalAPIS.addStatusTransition('New', 'Scheduled');
            testSA.Status = 'Scheduled';
            testSA21.Status = 'Scheduled';
            update newSAlist;
            
            FSL.GlobalAPIS.addStatusTransition('Scheduled', 'Dispatched');
            testSA.Status = 'Dispatched';
            testSA21.Status = 'Dispatched';
            update newSAlist; 
            
            FSL.GlobalAPIS.addStatusTransition('Dispatched', 'Click_Onsite');
            testSA21.Status = 'Click_Onsite';
            update testSA21;
            
            FSL.GlobalAPIS.addStatusTransition('Click_Onsite', 'In Progress');
            testSA21.Status = 'In Progress';    
            update testSA21;
            
            FSL.GlobalAPIS.addStatusTransition('Dispatched', 'Canceled');
            testSA.Status = 'Canceled';
            update testSA;
            
            /* FSL.GlobalAPIS.addStatusTransition('In Progress', 'Completed');
testSA21.Status = 'Completed';
testSA21.Additional_Effort__c = 'Activity for Doc/Admin Time';      
update testSA21;*/
            
            Test.stopTest();
            /*testWorkOrder = [SELECT Id, Status FROM WorkOrder WHERE Id =:testWorkOrder.Id LIMIT 1];
System.assertEquals('FF - Closed',testWorkOrder.Status);

testSA21 = [SELECT Id, Work_Order__r.Status FROM ServiceAppointment WHERE Id =:testSA21.Id LIMIT 1];
System.assertEquals('FF - Closed',testSA21.Work_Order__r.Status);*/
        }
        
    }
    
    @IsTest
    static void testPhysicalHelperRequested()
    {
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
            
            Contact testContact = new Contact(
                FirstName = 'Test',    
                LastName = 'Test Contact',
                Primary_Phone__c = '5555555555',
                Email = 'test@email.com',
                Phone = '5555555555',
                TimeZone__c = 'Central Time',
                pse__Is_Resource__c = true,
                pse__Salesforce_User__c = UserInfo.getUserId(),
                pse__Is_Resource_Active__c = true,
                pse__Region__c = testRegion.Id,
                pse__Practice__c = testPractice.Id
            );
            INSERT testContact;
            
            pse__Proj__c testProject = new pse__Proj__c(
                Name = 'Test Project',
                pse__Start_Date__c = System.today(),
                pse__End_Date__c = System.today() + 7,
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
                pse__Start_Date_Time__c = System.now(),
                pse__End_Date_Time__c = System.now() + 7,
                pse__Estimated_Hours__c = 8,
                pse__Started__c = true,
                pse__Project__c = testProject.Id
            );
            insert testProjectTask;
            
            Id installationBadgeRecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('Installation_Badge').getRecordTypeId();
            
            Account account = new Account();
            account.Name = 'AccountName';
            account.Site_Access_Required__c = 'Yes';
            insert account;
            
            WorkOrder testWorkOrder = new WorkOrder();
            testWorkOrder.Status = 'FF - Work In Progress';
            testWorkOrder.RecordTypeId = installationBadgeRecordTypeId;
            testWorkOrder.Project_Task__c = testProjectTask.Id;
            testWorkOrder.Account = account;
            testWorkOrder.AccountId = account.Id;
            insert testWorkOrder;
            
            pse__Permission_Control__c testPC = new pse__Permission_Control__c(
                pse__User__c = UserInfo.getUserId(),
                pse__Region__c = testRegion.Id,
                pse__Staffing__c = true,
                pse__Cascading_Permission__c = true
            );
            insert testPC;
            
            Id installationBadgeRecordType = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByName().get('Installation - Badge').getRecordTypeId();
            
            ServiceAppointment testSA = new ServiceAppointment(
                Work_Order__c = testWorkOrder.Id,
                EarliestStartTime = System.now(),
                DueDate = System.now() + 7,
                Status = 'New',
                ParentRecordId = testWorkOrder.Id,
                RecordTypeId = installationBadgeRecordType
            );
            insert testSA;
            
            Test.startTest();
            testSA.Physical_Helper_Requested_by_Engineer__c = true;
            update testSA;
            Test.stopTest();
            
            List<ServiceAppointment> saList = [SELECT Id FROM ServiceAppointment];
            //System.assert(saList.size() == 2);
        }
        
    }
    
    private class Mock implements HttpCalloutMock
    {
        public HttpResponse respond(HttpRequest req)
        {
            HTTPResponse res = new HTTPResponse();
            res.setBody(
                '{' +
                '    \"ReturnCode\": \"ScheduleFailed\",' +
                '    \"Task\": {' +
                '        \"objectType\": \"Task\",' +
                '        \"Key\": 415506432,' +
                '        \"Revision\": 3,' +
                '        \"CallID\": \"PWA-100028\",' +
                '        \"Number\": 1,' +
                '        \"ExternalRefID\": \"PWA-100028\"' +
                '    },' +
                '    \"Assignment\": null,' +
                '    \"LinkedTasks\": null,' +
                '    \"SchedulingError\": null' +
                '}'
            );
            res.setStatusCode(200);
            return res;
        }
    }
    
    
    /**
* @description 
* @author Luis Campos (LC) | 12/28/2020 
* @return void 
**/
    @IsTest
    static void testPopulatedScenario1()
    {
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
            
            User userTest = TestDataGenerator.createUser('Shawm','Merphy','17');
            insert userTest;
            
            List<Contact> contactsToCreate = new List<Contact>();
            
            Contact testContact1 = new Contact(
                FirstName = 'Test',
                LastName = 'Test Contact 1',
                Primary_Phone__c = '5555555555',
                Email = 'test@email.com',
                Phone = '5555555555',
                TimeZone__c = 'Central Time',
                pse__Is_Resource__c = true,
                pse__Salesforce_User__c = UserInfo.getUserId(),
                pse__Is_Resource_Active__c = true,
                pse__Region__c = testRegion.Id,
                pse__Practice__c = testPractice.Id
            );
            contactsToCreate.add(testContact1);
            
            Contact testContact2 = new Contact(
                FirstName = 'Test',
                LastName = 'Test Contact 2',
                Primary_Phone__c = '5555555555',
                Email = 'test@email.com',
                Phone = '5555555555',
                TimeZone__c = 'Central Time',
                pse__Is_Resource__c = true,
                pse__Salesforce_User__c = userTest.Id,
                pse__Is_Resource_Active__c = true,
                pse__Region__c = testRegion.Id,
                pse__Practice__c = testPractice.Id
            );
            contactsToCreate.add(testContact2);
            
            insert contactsToCreate;
            
            pse__Proj__c testProject = new pse__Proj__c(
                Name = 'Test Project',
                pse__Start_Date__c = System.today(),
                pse__End_Date__c = System.today() + 7,
                pse__Project_Phase__c = 'Setup',
                pse__Project_Type__c = 'Standard',
                pse__Stage__c = 'Draft',
                pse__Project_Manager__c = testContact1.Id,
                pse__Region__c = testRegion.Id,
                pse__Practice__c = testPractice.Id,
                pse__Is_Active__c = true
            );
            insert testProject;
            
            Test.startTest();
            testProject.pse__End_Date__c = System.today() + 7;
            
            update testProject;
            
            pse__Project_Task__c testProjectTask = new pse__Project_Task__c(
                Name = 'Test Project Task',
                pse__Start_Date_Time__c = System.now(),
                pse__End_Date_Time__c = System.now() + 7,
                pse__Estimated_Hours__c = 8,
                pse__Project__c = testProject.Id
            );
            insert testProjectTask;
            
            Account account = new Account();
            account.Name = 'AccountName';
            account.Site_Access_Required__c = 'Yes';
            insert account;
            
            Id installationBadgeRecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('Installation_Badge').getRecordTypeId();
            WorkOrder testWorkOrder = new WorkOrder();
            testWorkOrder.Status = 'FF - Work In Progress';
            testWorkOrder.RecordTypeId = installationBadgeRecordTypeId;
            testWorkOrder.Project_Task__c = testProjectTask.Id;
            testWorkOrder.Account = account;
            testWorkOrder.AccountId = account.Id;
            insert testWorkOrder;
            
            pse__Permission_Control__c testPC = new pse__Permission_Control__c(
                pse__User__c = UserInfo.getUserId(),
                pse__Region__c = testRegion.Id,
                pse__Staffing__c = true,
                pse__Cascading_Permission__c = true
            );
            insert testPC;
            
            Id installationBadgeRecordType = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByName().get('Installation - Badge').getRecordTypeId();
            
            ServiceAppointment testSA = new ServiceAppointment(
                Work_Order__c = testWorkOrder.Id,
                EarliestStartTime = System.now(),
                DueDate = System.now() + 7,
                Status = 'Scheduled',
                ParentRecordId = testWorkOrder.Id,
                Project__c = testProject.Id,
                RecordTypeId = installationBadgeRecordType,
                Assignee__c = testContact1.Id,
                SchedStartTime = System.now(),
                SchedEndTime = System.now() + 7
            );
            insert testSA;
            
            
            // Assertions begin.
            
            // Does Resource in Assignee field already have Assignment on Project? -- NO
            List<pse__Assignment__c> contact2Assignment = [SELECT Id FROM pse__Assignment__c WHERE pse__Resource__c = :testContact2.Id];
            
            System.assertEquals(true, contact2Assignment.isEmpty(), 'The contact 2 must not have assignments related to the service appointment.');
            testSA.Assignee__c = testContact2.Id;
            update testSA;
            
            // Create Assignment record for Assignee
            contact2Assignment = [SELECT Id FROM pse__Assignment__c WHERE pse__Resource__c = :testContact2.Id];
            
            //System.assertEquals(false, contact2Assignment.isEmpty(), 'The contact 2 must have assignments related to the service appointment.');
            
            //  Create new PTA for Project Task related to SA
            List<pse__Project_Task_Assignment__c> contact2PTA = [SELECT Id FROM pse__Project_Task_Assignment__c WHERE pse__Project_Task__c =: testProjectTask.Id and pse__Resource__c =: testContact2.Id];
            
            //System.assertEquals(false, contact2PTA.isEmpty(), 'The contact 2 must have PTA related to the Project Task.');
            Test.stopTest();
        }
    }
    
    /**
* @description 
* @author Luis Campos (LC) | 12/28/2020 
* @return void 
**/
    @IsTest
    static void testPopulatedScenario2()
    {
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
            
            User userTest = TestDataGenerator.createUser('Rajesh','Koothrpalli','13');
            insert userTest;
            
            List<Contact> contactsToCreate = new List<Contact>();
            
            Contact testContact1 = new Contact(
                FirstName = 'Test',
                LastName = 'Test Contact',
                Primary_Phone__c = '5555555555',
                Email = 'test@email.com',
                Phone = '5555555555',
                TimeZone__c = 'Central Time',
                pse__Is_Resource__c = true,
                pse__Salesforce_User__c = UserInfo.getUserId(),
                pse__Is_Resource_Active__c = true,
                pse__Region__c = testRegion.Id,
                pse__Practice__c = testPractice.Id
            );
            contactsToCreate.add(testContact1);
            
            Contact testContact2 = new Contact(
                FirstName = 'Test',
                LastName = 'Test Contact',
                Primary_Phone__c = '5555555555',
                Email = 'test@email.com',
                Phone = '5555555555',
                TimeZone__c = 'Central Time',
                pse__Is_Resource__c = true,
                pse__Salesforce_User__c = userTest.Id,
                pse__Is_Resource_Active__c = true,
                pse__Region__c = testRegion.Id,
                pse__Practice__c = testPractice.Id
            );
            contactsToCreate.add(testContact2);
            
            insert contactsToCreate;
            
            pse__Proj__c testProject = new pse__Proj__c(
                Name = 'Test Project',
                pse__Start_Date__c = System.today(),
                pse__End_Date__c = System.today() + 7,
                pse__Project_Phase__c = 'Setup',
                pse__Project_Type__c = 'Standard',
                pse__Stage__c = 'Draft',
                pse__Project_Manager__c = testContact1.Id,
                pse__Region__c = testRegion.Id,
                pse__Practice__c = testPractice.Id,
                pse__Is_Active__c = true
            );
            insert testProject;
            
            Test.startTest();
            
            pse__Project_Task__c testProjectTask = new pse__Project_Task__c(
                Name = 'Test Project Task',
                pse__Start_Date_Time__c = System.now(),
                pse__End_Date_Time__c = System.now() + 7,
                pse__Estimated_Hours__c = 8,
                pse__Project__c = testProject.Id
            );
            insert testProjectTask;
            
            Id installationBadgeRecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('Installation_Badge').getRecordTypeId();
            
            Account account = new Account();
            account.Name = 'AccountName';
            account.Site_Access_Required__c = 'Yes';
            insert account;
            
            WorkOrder testWorkOrder = new WorkOrder();
            testWorkOrder.Status = 'FF - Work In Progress';
            testWorkOrder.RecordTypeId = installationBadgeRecordTypeId;
            testWorkOrder.Project_Task__c = testProjectTask.Id;
            testWorkOrder.Account = account;
            testWorkOrder.AccountId = account.Id;
            insert testWorkOrder;
            
            pse__Permission_Control__c testPC = new pse__Permission_Control__c(
                pse__User__c = UserInfo.getUserId(),
                pse__Region__c = testRegion.Id,
                pse__Staffing__c = true,
                pse__Cascading_Permission__c = true
            );
            insert testPC;
            
            pse__Schedule__c objScheduleTest = new pse__Schedule__c();
            objScheduleTest.pse__Start_Date__c = System.now().Date();
            objScheduleTest.pse__End_Date__c = System.now().Date() + 7;
            
            insert objScheduleTest;
            
            // Create the Assignment
            pse__Assignment__c objAssignmentTest = new pse__Assignment__c(
                pse__Resource__c = testContact1.Id,
                pse__Resource__r = testContact1,
                pse__Project__c = testProject.Id,
                pse__Project__r = testProject,
                pse__Bill_Rate__c = 0,
                pse__Schedule__c = objScheduleTest.Id,
                pse__Schedule__r = objScheduleTest,
                pse__Closed_for_Expense_Entry__c = false
            );
            insert objAssignmentTest;
            
            pse__Project_Task_Assignment__c testPTA = new pse__Project_Task_Assignment__c(
                pse__Assignment__c = objAssignmentTest.Id,
                pse__Project_Task__c = testProjectTask.Id,
                pse__Resource__c = testContact1.Id
            );
            
            // insert testPTA;
            
            Id installationBadgeRecordType = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByName().get('Installation - Badge').getRecordTypeId();
            
            ServiceAppointment testSA = new ServiceAppointment(
                Work_Order__c = testWorkOrder.Id,
                EarliestStartTime = System.now(),
                DueDate = System.now() + 7,
                Status = 'Scheduled',
                ParentRecordId = testWorkOrder.Id,
                Project__c = testProject.Id,
                RecordTypeId = installationBadgeRecordType,
                Assignee__c = testContact1.Id,
                //Assignment__c = objAssignmentTest.Id,
                SchedStartTime = System.now(),
                SchedEndTime = System.now() + 7
            );
            insert testSA;
            
            // Create the Schedule
            
            
            Test.stopTest();
            // Assertions begin.
            
            // Does Resource in Assignee field already have Assignment on Project? -- YES
            List<pse__Assignment__c> contact1Assignment = [SELECT Id FROM pse__Assignment__c WHERE pse__Resource__c = :testContact1.Id];
            System.assertEquals(false, contact1Assignment.isEmpty(), 'The contact 1 must have assignments related to the service appointment.');
            
            testSA.Assignee__c = testContact1.Id;
            update testSA;
            
            List<ServiceAppointment> updatedSA = [SELECT Id FROM ServiceAppointment WHERE Work_Order__c =: testWorkOrder.Id and Assignee__c =: testContact1.Id];
            System.assertEquals(false, updatedSA.isEmpty(), 'The Service Appointment for the Work Order must be assigned to Contact 1.');        
            
            List<pse__Project_Task_Assignment__c> contact1PTA = [SELECT Id FROM pse__Project_Task_Assignment__c WHERE pse__Project_Task__c =: testProjectTask.Id and pse__Resource__c =: testContact1.Id];
            
            //System.assertEquals(false, contact1PTA.isEmpty(), 'Create new PTA for Project Task related to SA');
        }
    }
    
    /**
* @description 
* @author Luis Campos (LC) | 12/28/2020 
* @return void 
**/
    @IsTest
    static void testPopulatedScenario3()
    {
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
            
            User userTest = TestDataGenerator.createUser('Amyfarrah','Fowler','10');
            insert userTest;
            
            List<Contact> contactsToCreate = new List<Contact>();
            
            Contact testContact1 = new Contact(
                FirstName = 'Test',
                LastName = 'Test Contact',
                Primary_Phone__c = '5555555555',
                Email = 'test@email.com',
                Phone = '5555555555',
                TimeZone__c = 'Central Time',
                pse__Is_Resource__c = true,
                pse__Salesforce_User__c = UserInfo.getUserId(),
                pse__Is_Resource_Active__c = true,
                pse__Region__c = testRegion.Id,
                pse__Practice__c = testPractice.Id
            );
            contactsToCreate.add(testContact1);
            
            Contact testContact2 = new Contact(
                FirstName = 'Test',
                LastName = 'Test Contact',
                Primary_Phone__c = '5555555555',
                Email = 'test@email.com',
                Phone = '5555555555',
                TimeZone__c = 'Central Time',
                pse__Is_Resource__c = true,
                pse__Salesforce_User__c = userTest.Id,
                pse__Is_Resource_Active__c = true,
                pse__Region__c = testRegion.Id,
                pse__Practice__c = testPractice.Id
            );
            contactsToCreate.add(testContact2);
            
            insert contactsToCreate;
            
            pse__Proj__c testProject = new pse__Proj__c(
                Name = 'Test Project',
                pse__Start_Date__c = System.today(),
                pse__End_Date__c = System.today() + 7,
                pse__Project_Phase__c = 'Setup',
                pse__Project_Type__c = 'Standard',
                pse__Stage__c = 'Draft',
                pse__Project_Manager__c = testContact1.Id,
                pse__Region__c = testRegion.Id,
                pse__Practice__c = testPractice.Id,
                pse__Is_Active__c = true
            );
            insert testProject;
            
            Test.startTest();
            testProject.pse__End_Date__c = System.today() + 7;
            
            update testProject;
            
            pse__Project_Task__c testProjectTask1 = new pse__Project_Task__c(
                Name = 'Test Project Task',
                pse__Start_Date_Time__c = System.now(),
                pse__End_Date_Time__c = System.now() + 7,
                pse__Estimated_Hours__c = 8,
                pse__Project__c = testProject.Id
            );
            insert testProjectTask1;
            
            
            pse__Project_Task__c testProjectTask2 = new pse__Project_Task__c(
                Name = 'Test Project Task 2',
                pse__Start_Date_Time__c = System.now(),
                pse__End_Date_Time__c = System.now() + 7,
                pse__Estimated_Hours__c = 8,
                pse__Project__c = testProject.Id
            );
            insert testProjectTask2;
            
            Account account = new Account();
            account.Name = 'AccountName';
            account.Site_Access_Required__c = 'Yes';
            insert account;
            
            Id installationBadgeRecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('Installation_Badge').getRecordTypeId();
            List<WorkOrder> listWO = new List<WorkOrder>();
            WorkOrder testWorkOrder = new WorkOrder();
            testWorkOrder.Status = 'FF - Work In Progress';
            testWorkOrder.RecordTypeId = installationBadgeRecordTypeId;
            testWorkOrder.Project_Task__c = testProjectTask1.Id;
            testWorkOrder.Account = account;
            testWorkOrder.AccountId = account.Id;
            listWO.add(testWorkOrder);
            
            WorkOrder testWorkOrder2 = new WorkOrder();
            testWorkOrder2.Status = 'FF - Work In Progress';
            testWorkOrder2.RecordTypeId = installationBadgeRecordTypeId;
            testWorkOrder2.Project_Task__c = testProjectTask2.Id;
            testWorkOrder2.Account = account;
            testWorkOrder2.AccountId = account.Id;
            listWO.add(testWorkOrder2);
            INSERT listWO;
            
            pse__Permission_Control__c testPC = new pse__Permission_Control__c(
                pse__User__c = UserInfo.getUserId(),
                pse__Region__c = testRegion.Id,
                pse__Staffing__c = true,
                pse__Cascading_Permission__c = true
            );
            insert testPC;
            
            Id installationBadgeRecordType = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByName().get('Installation - Badge').getRecordTypeId();
            
            ServiceAppointment testSA = new ServiceAppointment(
                Work_Order__c = listWO.get(0).Id,
                EarliestStartTime = System.now(),
                DueDate = System.now() + 7,
                Status = 'Scheduled',
                ParentRecordId = listWO.get(0).Id,
                Project__c = testProject.Id,
                RecordTypeId = installationBadgeRecordType,
                Assignee__c = testContact1.Id,
                SchedStartTime = System.now(),
                SchedEndTime = System.now() + 7
            );
            insert testSA;
            
            //  Create the Schedule
            pse__Schedule__c objScheduleTest = new pse__Schedule__c();
            objScheduleTest.pse__Start_Date__c = System.now().Date();
            objScheduleTest.pse__End_Date__c = System.now().Date() + 7;
            
            insert objScheduleTest;
            
            // Create the Assignment
            pse__Assignment__c objAssignmentTest = new pse__Assignment__c(
                pse__Resource__c = testContact1.Id,
                pse__Resource__r = testContact1,
                pse__Project__c = testProject.Id,
                pse__Project__r = testProject,
                pse__Bill_Rate__c = 0,
                pse__Schedule__c = objScheduleTest.Id,
                pse__Schedule__r = objScheduleTest,
                pse__Closed_for_Expense_Entry__c = false
            );
            insert objAssignmentTest;
            
            pse__Project_Task_Assignment__c testPTA = new pse__Project_Task_Assignment__c(
                pse__Assignment__c = objAssignmentTest.Id,
                pse__Project_Task__c = testProjectTask2.Id,
                pse__Resource__c = testContact1.Id
            );
            
            insert testPTA;
            
            Test.stopTest();
            // Assertions begin.
            
            // Does Resource in Assignee field already have Assignment on Project? -- YES
            List<pse__Assignment__c> contact1Assignment = [SELECT Id FROM pse__Assignment__c WHERE pse__Resource__c = :testContact1.Id];
            System.assertEquals(false, contact1Assignment.isEmpty(), 'The contact 1 must have assignments related to the service appointment.');
            
            testSA.Assignee__c = testContact1.Id;
            update testSA;
            
            List<ServiceAppointment> updatedSA = [SELECT Id FROM ServiceAppointment WHERE Work_Order__c =: listWO.get(0).Id and Assignee__c =: testContact1.Id];
            System.assertEquals(false, updatedSA.isEmpty(), 'The Service Appointment for the Work Order must be assigned to Contact 1.');        
            
            List<pse__Project_Task_Assignment__c> contact1PTA = [SELECT Id FROM pse__Project_Task_Assignment__c WHERE pse__Project_Task__c =: testProjectTask1.Id and pse__Resource__c =: testContact1.Id];
            
            //System.assertEquals(false, contact1PTA.isEmpty(), 'Create new PTA for Project Task related to SA');
        }
    }
    
    /**
* @description 
* @author Luis Campos (LC) | 12/28/2020 
* @return void 
**/
    @IsTest
    static void testNulledScenario1()
    {
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
            
            User userTest = TestDataGenerator.createUser('Neil','Melendez','11');
            insert userTest;
            
            List<Contact> contactsToCreate = new List<Contact>();
            
            Contact testContact1 = new Contact(
                FirstName = 'Test',
                LastName = 'Test Contact',
                Primary_Phone__c = '5555555555',
                Email = 'test@email.com',
                Phone = '5555555555',
                TimeZone__c = 'Central Time',
                pse__Is_Resource__c = true,
                pse__Salesforce_User__c = UserInfo.getUserId(),
                pse__Is_Resource_Active__c = true,
                pse__Region__c = testRegion.Id,
                pse__Practice__c = testPractice.Id
            );
            contactsToCreate.add(testContact1);
            
            insert contactsToCreate;
            
            pse__Proj__c testProject = new pse__Proj__c(
                Name = 'Test Project',
                pse__Start_Date__c = System.today(),
                pse__End_Date__c = System.today() + 7,
                pse__Project_Phase__c = 'Setup',
                pse__Project_Type__c = 'Standard',
                pse__Stage__c = 'Draft',
                pse__Project_Manager__c = testContact1.Id,
                pse__Region__c = testRegion.Id,
                pse__Practice__c = testPractice.Id,
                pse__Is_Active__c = true
            );
            insert testProject;
            
            Test.startTest();
            testProject.pse__End_Date__c = System.today() + 7;
            
            update testProject;
            
            pse__Project_Task__c testProjectTask = new pse__Project_Task__c(
                Name = 'Test Project Task',
                pse__Start_Date_Time__c = System.now(),
                pse__End_Date_Time__c = System.now() + 7,
                pse__Estimated_Hours__c = 8,
                pse__Project__c = testProject.Id
            );
            insert testProjectTask;
            
            Account account = new Account();
            account.Name = 'AccountName';
            account.Site_Access_Required__c = 'Yes';
            insert account;
            
            Id installationBadgeRecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('Installation_Badge').getRecordTypeId();
            List<WorkOrder> listWO = new List<WorkOrder>();
            WorkOrder testWorkOrder = new WorkOrder();
            testWorkOrder.Status = 'FF - Work In Progress';
            testWorkOrder.RecordTypeId = installationBadgeRecordTypeId;
            testWorkOrder.Project_Task__c = testProjectTask.Id;
            testWorkOrder.Account = account;
            testWorkOrder.AccountId = account.Id;
            listWO.add(testWorkOrder);
            INSERT listWO;
            
            pse__Permission_Control__c testPC = new pse__Permission_Control__c(
                pse__User__c = UserInfo.getUserId(),
                pse__Region__c = testRegion.Id,
                pse__Staffing__c = true,
                pse__Cascading_Permission__c = true
            );
            insert testPC;
            
            //Create the Schedule
            pse__Schedule__c objScheduleTest = new pse__Schedule__c();
            objScheduleTest.pse__Start_Date__c = System.now().Date();
            objScheduleTest.pse__End_Date__c = System.now().Date() + 7;
            
            insert objScheduleTest;
            
            //         Create the Assignment
            pse__Assignment__c objAssignmentTest = new pse__Assignment__c(
                pse__Resource__c = testContact1.Id,
                pse__Resource__r = testContact1,
                pse__Project__c = testProject.Id,
                pse__Project__r = testProject,
                pse__Bill_Rate__c = 0,
                pse__Schedule__c = objScheduleTest.Id,
                pse__Schedule__r = objScheduleTest,
                pse__Closed_for_Expense_Entry__c = false
            );
            insert objAssignmentTest;
            
            pse__Project_Task_Assignment__c testPTA = new pse__Project_Task_Assignment__c(
                pse__Assignment__c = objAssignmentTest.Id,
                pse__Project_Task__c = testProjectTask.Id,
                pse__Resource__c = testContact1.Id
            );
            
            insert testPTA;
            
            Id installationBadgeRecordType = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByName().get('Installation - Badge').getRecordTypeId();
            
            List<ServiceAppointment> servicesAppointmentsToCreate = new List<ServiceAppointment>();
            ServiceAppointment testSA1 = new ServiceAppointment(
                Work_Order__c = listWO.get(0).Id,
                EarliestStartTime = System.now(),
                DueDate = System.now() + 7,
                Status = 'New',
                ParentRecordId = listWO.get(0).Id,
                Project__c = testProject.Id,
                RecordTypeId = installationBadgeRecordType,
                Assignee__c = testContact1.Id,
                SchedStartTime = System.now(),
                SchedEndTime = System.now() + 7,
                Assignment__c = objAssignmentTest.Id
                
            );
            servicesAppointmentsToCreate.add(testSA1);
            insert servicesAppointmentsToCreate;
            
            
            // Assertions begin.
            
            // Does related Assignment have other SAs related to it? -- YES
            FSL.GlobalAPIS.addStatusTransition('New', 'Scheduled');
            testSA1.Status = 'Scheduled';
            update testSA1;
            
            testSA1 = [SELECT Id, Assignment__c FROM ServiceAppointment WHERE Id =:testSA1.Id LIMIT 1];
            System.assertEquals(objAssignmentTest.Id, testSA1.Assignment__c);
            
            //testSA2 = [SELECT Id, Assignment__c FROM ServiceAppointment WHERE Id =:testSA2.Id LIMIT 1];
            //System.assertEquals(null, testSA2.Assignment__c);
            
            //  Does Assignment have any related SAs with same Project Task? -- NO
            
            //List<pse__Project_Task_Assignment__c> deletedPTA = [SELECT Id FROM pse__Project_Task_Assignment__c WHERE pse__Project_Task__c =:testProjectTask.Id];
            //System.assertEquals(true, deletedPTA.isEmpty(), 'Delete PTA for Project Task of SA');
            Test.stopTest();
        }
    }
    
    /**
* @description 
* @author Luis Campos (LC) | 12/28/2020 
* @return void 
**/
    @IsTest
    static void testNulledScenario2()
    {
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
            
            User userTest = TestDataGenerator.createUser('Sheldon','Cooper','16');
            insert userTest;
            
            List<Contact> contactsToCreate = new List<Contact>();
            
            Contact testContact1 = new Contact(
                FirstName = 'Test',
                LastName = 'Test Contact',
                Primary_Phone__c = '5555555555',
                Email = 'test@email.com',
                Phone = '5555555555',
                TimeZone__c = 'Central Time',
                pse__Is_Resource__c = true,
                pse__Salesforce_User__c = UserInfo.getUserId(),
                pse__Is_Resource_Active__c = true,
                pse__Region__c = testRegion.Id,
                pse__Practice__c = testPractice.Id
            );
            contactsToCreate.add(testContact1);
            
            Contact testContact2 = new Contact(
                FirstName = 'Test',
                LastName = 'Test Contact',
                Primary_Phone__c = '5555555555',
                Email = 'test@email.com',
                Phone = '5555555555',
                TimeZone__c = 'Central Time',
                pse__Is_Resource__c = true,
                pse__Salesforce_User__c = userTest.Id,
                pse__Is_Resource_Active__c = true,
                pse__Region__c = testRegion.Id,
                pse__Practice__c = testPractice.Id
            );
            contactsToCreate.add(testContact2);
            
            insert contactsToCreate;
            
            pse__Proj__c testProject = new pse__Proj__c(
                Name = 'Test Project',
                pse__Start_Date__c = System.today(),
                pse__End_Date__c = System.today() + 7,
                pse__Project_Phase__c = 'Setup',
                pse__Project_Type__c = 'Standard',
                pse__Stage__c = 'Draft',
                pse__Project_Manager__c = testContact1.Id,
                pse__Region__c = testRegion.Id,
                pse__Practice__c = testPractice.Id,
                pse__Is_Active__c = true
            );
            insert testProject;
            
            Test.startTest();
            /*testProject.pse__End_Date__c = System.today() + 7;

update testProject;*/
            
            pse__Project_Task__c testProjectTask = new pse__Project_Task__c(
                Name = 'Test Project Task',
                pse__Start_Date_Time__c = System.now(),
                pse__End_Date_Time__c = System.now() + 7,
                pse__Estimated_Hours__c = 8,
                pse__Project__c = testProject.Id
            );
            insert testProjectTask;
            
            pse__Project_Task__c testProjectTask1 = new pse__Project_Task__c(
                Name = 'Test Project Task1',
                pse__Start_Date_Time__c = System.now(),
                pse__End_Date_Time__c = System.now() + 7,
                pse__Estimated_Hours__c = 8,
                pse__Project__c = testProject.Id
            );
            insert testProjectTask1;
            
            Account account = new Account();
            account.Name = 'AccountName';
            account.Site_Access_Required__c = 'Yes';
            insert account;
            
            Id installationBadgeRecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('Installation_Badge').getRecordTypeId();
            List<WorkOrder> listWO = new List<WorkOrder>();
            WorkOrder testWorkOrder = new WorkOrder();
            testWorkOrder.Status = 'FF - Work In Progress';
            testWorkOrder.RecordTypeId = installationBadgeRecordTypeId;
            testWorkOrder.Project_Task__c = testProjectTask1.Id;
            testWorkOrder.Account = account;
            testWorkOrder.AccountId = account.Id;
            listWO.add(testWorkOrder);
            
            INSERT listWO;
            
            pse__Permission_Control__c testPC = new pse__Permission_Control__c(
                pse__User__c = UserInfo.getUserId(),
                pse__Region__c = testRegion.Id,
                pse__Staffing__c = true,
                pse__Cascading_Permission__c = true
            );
            insert testPC;
            
            //  Create the Schedule
            pse__Schedule__c objScheduleTest = new pse__Schedule__c();
            objScheduleTest.pse__Start_Date__c = System.now().Date();
            objScheduleTest.pse__End_Date__c = System.now().Date() + 7;
            
            insert objScheduleTest;
            
            // Create the Assignment
            pse__Assignment__c objAssignmentTest = new pse__Assignment__c(
                pse__Resource__c = testContact1.Id,
                pse__Resource__r = testContact1,
                pse__Project__c = testProject.Id,
                pse__Project__r = testProject,
                pse__Bill_Rate__c = 0,
                pse__Schedule__c = objScheduleTest.Id,
                pse__Schedule__r = objScheduleTest,
                pse__Closed_for_Expense_Entry__c = false
            );
            insert objAssignmentTest;
            
            pse__Project_Task_Assignment__c testPTA = new pse__Project_Task_Assignment__c(
                pse__Assignment__c = objAssignmentTest.Id,
                pse__Project_Task__c = testProjectTask.Id,
                pse__Resource__c = testContact1.Id
            );
            
            insert testPTA;
            
            Id installationBadgeRecordType = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByName().get('Installation - Badge').getRecordTypeId();
            
            List<ServiceAppointment> servicesAppointmentsToCreate = new List<ServiceAppointment>();
            ServiceAppointment testSA1 = new ServiceAppointment(
                Work_Order__c = listWO.get(0).Id,
                EarliestStartTime = System.now(),
                DueDate = System.now() + 7,
                Status = 'New',
                ParentRecordId = listWO.get(0).Id,
                Project__c = testProject.Id,
                RecordTypeId = installationBadgeRecordType,
                Assignee__c = testContact1.Id,
                SchedStartTime = System.now(),
                SchedEndTime = System.now() + 7,
                Assignment__c = objAssignmentTest.Id
            );
            servicesAppointmentsToCreate.add(testSA1);
            
            insert servicesAppointmentsToCreate;
            
            Test.stopTest();
            // Assertions begin.
            
            //  Does related Assignment have other SAs related to it? -- NO
            FSL.GlobalAPIS.addStatusTransition('New', 'Scheduled');
            testSA1.Status = 'Scheduled';
            update testSA1;
            
            testSA1 = [SELECT Id, Assignment__c FROM ServiceAppointment WHERE Id =:testSA1.Id LIMIT 1];
            //System.assertEquals(null, testSA1.Assignment__c, 'Delete the related Assignment record on the SA');
            
            //List<pse__Project_Task_Assignment__c> deletedPTA = [SELECT Id FROM pse__Project_Task_Assignment__c WHERE pse__Assignment__c = :objAssignmentTest.Id];
            //System.assertEquals(true, deletedPTA.isEmpty(), 'Delete the PTA related to the Assignment');
        }
    }
    
    /**
* @description 
* @author Luis Campos (LC) | 12/28/2020 
* @return void 
**/
    
    
    @IsTest
    static void testNulledScenario3()
    {
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
            
            User userTest = TestDataGenerator.createUser('Bella','Rosche','16');
            insert userTest;
            
            List<Contact> contactsToCreate = new List<Contact>();
            
            Contact testContact1 = new Contact(
                FirstName = 'Test',
                LastName = 'Test Contact',
                Primary_Phone__c = '5555555555',
                Email = 'test@email.com',
                Phone = '5555555555',
                TimeZone__c = 'Central Time',
                pse__Is_Resource__c = true,
                pse__Salesforce_User__c = UserInfo.getUserId(),
                pse__Is_Resource_Active__c = true,
                pse__Region__c = testRegion.Id,
                pse__Practice__c = testPractice.Id
            );
            contactsToCreate.add(testContact1);
            
            Contact testContact2 = new Contact(
                FirstName = 'Test',
                LastName = 'Test Contact',
                Primary_Phone__c = '5555555555',
                Email = 'test@email.com',
                Phone = '5555555555',
                TimeZone__c = 'Central Time',
                pse__Is_Resource__c = true,
                pse__Salesforce_User__c = userTest.Id,
                pse__Is_Resource_Active__c = true,
                pse__Region__c = testRegion.Id,
                pse__Practice__c = testPractice.Id
            );
            contactsToCreate.add(testContact2);
            
            insert contactsToCreate;
            
            pse__Proj__c testProject = new pse__Proj__c(
                Name = 'Test Project',
                pse__Start_Date__c = System.today(),
                pse__End_Date__c = System.today() + 7,
                pse__Project_Phase__c = 'Setup',
                pse__Project_Type__c = 'Standard',
                pse__Stage__c = 'Draft',
                pse__Project_Manager__c = testContact1.Id,
                pse__Region__c = testRegion.Id,
                pse__Practice__c = testPractice.Id,
                pse__Is_Active__c = true
            );
            insert testProject;
            
            Test.startTest();
            testProject.pse__End_Date__c = System.today() + 7;
            
            update testProject;
            
            pse__Project_Task__c testProjectTask = new pse__Project_Task__c(
                Name = 'Test Project Task',
                pse__Start_Date_Time__c = System.now(),
                pse__End_Date_Time__c = System.now() + 7,
                pse__Estimated_Hours__c = 8,
                pse__Project__c = testProject.Id
            );
            insert testProjectTask;
            
            Account account = new Account();
            account.Name = 'AccountName';
            account.Site_Access_Required__c = 'Yes';
            insert account;
            
            Id installationBadgeRecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('Installation_Badge').getRecordTypeId();
            List<WorkOrder> listWO = new List<WorkOrder>();
            WorkOrder testWorkOrder = new WorkOrder();
            testWorkOrder.Status = 'FF - Work In Progress';
            testWorkOrder.RecordTypeId = installationBadgeRecordTypeId;
            testWorkOrder.Project_Task__c = testProjectTask.Id;
            testWorkOrder.Account = account;
            testWorkOrder.AccountId = account.Id;
            listWO.add(testWorkOrder);
            
            WorkOrder testWorkOrder2 = new WorkOrder();
            testWorkOrder2.Status = 'FF - Work In Progress';
            testWorkOrder2.RecordTypeId = installationBadgeRecordTypeId;
            testWorkOrder2.Project_Task__c = testProjectTask.Id;
            testWorkOrder2.Account = account;
            testWorkOrder2.AccountId = account.Id;
            listWO.add(testWorkOrder2);
            INSERT listWO;
            
            pse__Permission_Control__c testPC = new pse__Permission_Control__c(
                pse__User__c = UserInfo.getUserId(),
                pse__Region__c = testRegion.Id,
                pse__Staffing__c = true,
                pse__Cascading_Permission__c = true
            );
            insert testPC;
            
            // Create the Schedule
            pse__Schedule__c objScheduleTest = new pse__Schedule__c();
            objScheduleTest.pse__Start_Date__c = System.now().Date();
            objScheduleTest.pse__End_Date__c = System.now().Date() + 7;
            
            insert objScheduleTest;
            
            //  Create the Assignment
            List<pse__Assignment__c> assignmentsToCreate = new List<pse__Assignment__c>();
            pse__Assignment__c objAssignmentTest = new pse__Assignment__c(
                pse__Resource__c = testContact1.Id,
                pse__Resource__r = testContact1,
                pse__Project__c = testProject.Id,
                pse__Project__r = testProject,
                pse__Bill_Rate__c = 0,
                pse__Schedule__c = objScheduleTest.Id,
                pse__Schedule__r = objScheduleTest,
                pse__Closed_for_Expense_Entry__c = false
            );
            
            assignmentsToCreate.add(objAssignmentTest);
            
            pse__Assignment__c objAssignmentTest1 = new pse__Assignment__c(
                pse__Resource__c = testContact2.Id,
                pse__Resource__r = testContact2,
                pse__Project__c = testProject.Id,
                pse__Project__r = testProject,
                pse__Bill_Rate__c = 0,
                pse__Schedule__c = objScheduleTest.Id,
                pse__Schedule__r = objScheduleTest,
                pse__Closed_for_Expense_Entry__c = false
            );
            
            assignmentsToCreate.add(objAssignmentTest1);
            
            insert assignmentsToCreate;
            
            /*pse__Project_Task_Assignment__c testPTA = new pse__Project_Task_Assignment__c(
pse__Assignment__c = objAssignmentTest.Id,
pse__Project_Task__c = testProjectTask.Id,
pse__Resource__c = testContact1.Id
);

insert testPTA;*/
            
            Id installationBadgeRecordType = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByName().get('Installation - Badge').getRecordTypeId();
            
            List<ServiceAppointment> servicesAppointmentsToCreate = new List<ServiceAppointment>();
            ServiceAppointment testSA1 = new ServiceAppointment(
                Work_Order__c = listWO.get(0).Id,
                EarliestStartTime = System.now(),
                DueDate = System.now() + 7,
                Status = 'New',
                ParentRecordId = listWO.get(0).Id,
                Project__c = testProject.Id,
                RecordTypeId = installationBadgeRecordType,
                Assignee__c = testContact1.Id,
                SchedStartTime = System.now(),
                SchedEndTime = System.now() + 7,
                Assignment__c = objAssignmentTest.Id
            );
            servicesAppointmentsToCreate.add(testSA1);
            
            ServiceAppointment testSA2 = new ServiceAppointment(
                Work_Order__c = listWO.get(1).Id,
                EarliestStartTime = System.now(),
                DueDate = System.now() + 7,
                Status = 'New',
                ParentRecordId = listWO.get(1).Id,
                Project__c = testProject.Id,
                RecordTypeId = installationBadgeRecordType,
                Assignee__c = testContact2.Id,
                SchedStartTime = System.now(),
                SchedEndTime = System.now() + 7,
                Assignment__c = objAssignmentTest1.Id
            );
            servicesAppointmentsToCreate.add(testSA2);
            
            insert servicesAppointmentsToCreate;
            
            Test.stopTest();
            // Assertions begin.
            
            //  Does related Assignment have other SAs related to it? -- NO
            FSL.GlobalAPIS.addStatusTransition('New', 'Scheduled');
            testSA1.Status = 'Scheduled';
            update testSA1;
            
            testSA1 = [SELECT Id, Assignment__c FROM ServiceAppointment WHERE Id =:testSA1.Id LIMIT 1];
            //System.assertEquals(null, testSA1.Assignment__c, 'Delete the related Assignment record on the SA');
            
            //List<pse__Project_Task_Assignment__c> deletedPTA = [SELECT Id FROM pse__Project_Task_Assignment__c WHERE pse__Assignment__c = :objAssignmentTest.Id];
            //System.assertEquals(true, deletedPTA.isEmpty(), 'Delete the PTA related to the Assignment');
        }
    }
    
    /**
* @description 
* @author Luis Campos (LC) | 12/28/2020 
* @return void 
**/
    @IsTest
    static void testChangedScenario1()
    {
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
            
            User userTest = TestDataGenerator.createUser('Song','Joong-ki','01');
            insert userTest;
            
            User userTest3 = TestDataGenerator.createUser('DeJong0','Hye-kyo','03');
            insert userTest3;
            
            List<Contact> contactsToCreate = new List<Contact>();
            
            Contact testContact1 = new Contact(
                FirstName = 'Test',
                LastName = 'Test Contact 1',
                Primary_Phone__c = '5555555555',
                Email = 'test@email.com',
                Phone = '5555555555',
                TimeZone__c = 'Central Time',
                pse__Is_Resource__c = true,
                pse__Salesforce_User__c = UserInfo.getUserId(),
                pse__Is_Resource_Active__c = true,
                pse__Region__c = testRegion.Id,
                pse__Practice__c = testPractice.Id
            );
            contactsToCreate.add(testContact1);
            
            Contact testContact2 = new Contact(
                FirstName = 'Test',
                LastName = 'Test Contact 2',
                Primary_Phone__c = '5555555555',
                Email = 'test@email.com',
                Phone = '5555555555',
                TimeZone__c = 'Central Time',
                pse__Is_Resource__c = true,
                pse__Salesforce_User__c = userTest.Id,
                pse__Is_Resource_Active__c = true,
                pse__Region__c = testRegion.Id,
                pse__Practice__c = testPractice.Id
            );
            contactsToCreate.add(testContact2);
            
            Contact testContact3 = new Contact(
                FirstName = 'Test',
                LastName = 'Test Contact 3',
                Primary_Phone__c = '5555555555',
                Email = 'test@email.com',
                Phone = '5555555555',
                TimeZone__c = 'Central Time',
                pse__Is_Resource__c = true,
                pse__Salesforce_User__c = userTest3.Id,
                pse__Is_Resource_Active__c = true,
                pse__Region__c = testRegion.Id,
                pse__Practice__c = testPractice.Id
            );
            contactsToCreate.add(testContact3);
            
            insert contactsToCreate;
            
            pse__Proj__c testProject = new pse__Proj__c(
                Name = 'Test Project',
                pse__Start_Date__c = System.today(),
                pse__End_Date__c = System.today() + 7,
                pse__Project_Phase__c = 'Setup',
                pse__Project_Type__c = 'Standard',
                pse__Stage__c = 'Draft',
                pse__Project_Manager__c = testContact1.Id,
                pse__Region__c = testRegion.Id,
                pse__Practice__c = testPractice.Id,
                pse__Is_Active__c = true
            );
            insert testProject;
            
            Test.startTest();
            testProject.pse__End_Date__c = System.today() + 7;
            
            update testProject;
            
            pse__Project_Task__c testProjectTask = new pse__Project_Task__c(
                Name = 'Test Project Task',
                pse__Start_Date_Time__c = System.now(),
                pse__End_Date_Time__c = System.now() + 7,
                pse__Estimated_Hours__c = 8,
                pse__Project__c = testProject.Id
            );
            insert testProjectTask;
            
            Account account = new Account();
            account.Name = 'AccountName';
            account.Site_Access_Required__c = 'Yes';
            insert account;
            
            Id installationBadgeRecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('Installation_Badge').getRecordTypeId();
            List<WorkOrder> listWO = new List<WorkOrder>();
            WorkOrder testWorkOrder = new WorkOrder();
            testWorkOrder.Status = 'FF - Work In Progress';
            testWorkOrder.RecordTypeId = installationBadgeRecordTypeId;
            testWorkOrder.Project_Task__c = testProjectTask.Id;
            testWorkOrder.Account = account;
            testWorkOrder.AccountId = account.Id;
            listWO.add(testWorkOrder);
            
            WorkOrder testWorkOrder2 = new WorkOrder();
            testWorkOrder2.Status = 'FF - Work In Progress';
            testWorkOrder2.RecordTypeId = installationBadgeRecordTypeId;
            testWorkOrder2.Project_Task__c = testProjectTask.Id;
            testWorkOrder2.Account = account;
            testWorkOrder2.AccountId = account.Id;
            listWO.add(testWorkOrder2);
            INSERT listWO;
            
            pse__Permission_Control__c testPC = new pse__Permission_Control__c(
                pse__User__c = UserInfo.getUserId(),
                pse__Region__c = testRegion.Id,
                pse__Staffing__c = true,
                pse__Cascading_Permission__c = true
            );
            insert testPC;
            
            //  Create the Schedule
            pse__Schedule__c objScheduleTest1 = new pse__Schedule__c();
            objScheduleTest1.pse__Start_Date__c = System.now().Date();
            objScheduleTest1.pse__End_Date__c = System.now().Date() + 7;
            
            insert objScheduleTest1;
            
            pse__Schedule__c objScheduleTest2 = new pse__Schedule__c();
            objScheduleTest2.pse__Start_Date__c = System.now().Date();
            objScheduleTest2.pse__End_Date__c = System.now().Date() + 7;
            
            insert objScheduleTest2;
            
            //  Create the Assignment
            pse__Assignment__c objAssignmentTest1 = new pse__Assignment__c(
                pse__Resource__c = testContact1.Id,
                pse__Resource__r = testContact1,
                pse__Project__c = testProject.Id,
                pse__Project__r = testProject,
                pse__Bill_Rate__c = 0,
                pse__Schedule__c = objScheduleTest1.Id,
                pse__Schedule__r = objScheduleTest1,
                pse__Closed_for_Expense_Entry__c = false
            );
            insert objAssignmentTest1;
            
            pse__Assignment__c objAssignmentTest2 = new pse__Assignment__c(
                pse__Resource__c = testContact2.Id,
                pse__Resource__r = testContact2,
                pse__Project__c = testProject.Id,
                pse__Project__r = testProject,
                pse__Bill_Rate__c = 0,
                pse__Schedule__c = objScheduleTest2.Id,
                pse__Schedule__r = objScheduleTest2,
                pse__Closed_for_Expense_Entry__c = false
            );
            insert objAssignmentTest2;      
            
            pse__Project_Task_Assignment__c testPTA1 = new pse__Project_Task_Assignment__c(
                pse__Assignment__c = objAssignmentTest1.Id,
                pse__Project_Task__c = testProjectTask.Id,
                pse__Resource__c = testContact1.Id
            );
            
            insert testPTA1;
            
            Id installationBadgeRecordType = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByName().get('Installation - Badge').getRecordTypeId();
            
            List<ServiceAppointment> servicesAppointmentsToCreate = new List<ServiceAppointment>();
            ServiceAppointment testSA1 = new ServiceAppointment(
                Work_Order__c = listWO.get(0).Id,
                EarliestStartTime = System.now(),
                DueDate = System.now() + 7,
                Status = 'New',
                ParentRecordId = listWO.get(0).Id,
                Project__c = testProject.Id,
                RecordTypeId = installationBadgeRecordType,
                Assignee__c = testContact1.Id,
                SchedStartTime = System.now(),
                SchedEndTime = System.now() + 7,
                Assignment__c = objAssignmentTest1.Id
            );
            servicesAppointmentsToCreate.add(testSA1);
            
            ServiceAppointment testSA2 = new ServiceAppointment(
                Work_Order__c = listWO.get(1).Id,
                EarliestStartTime = System.now(),
                DueDate = System.now() + 7,
                Status = 'New',
                ParentRecordId = listWO.get(1).Id,
                Project__c = testProject.Id,
                RecordTypeId = installationBadgeRecordType,
                Assignee__c = testContact2.Id,
                SchedStartTime = System.now(),
                SchedEndTime = System.now() + 7,
                Assignment__c = objAssignmentTest2.Id
            );
            servicesAppointmentsToCreate.add(testSA2);
            
            insert servicesAppointmentsToCreate;
            
            Test.stopTest();
            // Assertions begin.
            
            //Trigger changes
            testSA1.Assignee__c = testContact2.Id;
            update testSA1;
            
            // Was previous Assignee assigned to other SAs on same Project? -- NO
            
            // Delete Assignment record related to SA
            List<pse__Assignment__c> deletedAssignment = [SELECT Id FROM pse__Assignment__c WHERE pse__Resource__c =: testContact1.Id];
            //System.assertEquals(true, deletedAssignment.isEmpty(), 'Delete Assignment record related to SA');
            
            //  Delete the PTA related to the Assignment
            List<pse__Project_Task_Assignment__c> deletedPTA = [SELECT Id FROM pse__Project_Task_Assignment__c WHERE pse__Project_Task__c =: testProjectTask.Id and pse__Resource__c =: testContact1.Id];
            //System.assertEquals(true, deletedPTA.isEmpty(), 'Delete the PTA related to the Assignment');
            
            //         Does new Assignee already have Assignment on Project? -- YES
            
            //testSA1 = [SELECT Id, Assignment__c FROM ServiceAppointment WHERE Id =:testSA1.Id LIMIT 1];
            //System.assertEquals(objAssignmentTest2.Id, testSA1.Assignment__c, 'Populate existing Assignment record on SA');
            
            //  Is there a PTA for the same Project Task on SA? -- NO
            //pse__Project_Task_Assignment__c testPTA2 = [SELECT Id FROM pse__Project_Task_Assignment__c WHERE pse__Project_Task__c =: testProjectTask.Id and pse__Resource__c =: testContact2.Id LIMIT 1];
            //System.assertNotEquals(null, testPTA2, 'Create new PTA for Project Task related to SA');
        }
    }
    
    /**
* @description 
* @author Luis Campos (LC) | 12/28/2020 
* @return void 
**/
    @IsTest
    static void testChangedScenario2()
    {
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
            
            User userTest = TestDataGenerator.createUser('Kang','Chul','11');
            insert userTest;
            
            User userTest3 = TestDataGenerator.createUser('TaeKim','Jiwon','13');
            insert userTest3;
            
            List<Contact> contactsToCreate = new List<Contact>();
            
            Contact testContact1 = new Contact(
                FirstName = 'Test',
                LastName = 'Test Contact 1',
                Primary_Phone__c = '5555555555',
                Email = 'test@email.com',
                Phone = '5555555555',
                TimeZone__c = 'Central Time',
                pse__Is_Resource__c = true,
                pse__Salesforce_User__c = UserInfo.getUserId(),
                pse__Is_Resource_Active__c = true,
                pse__Region__c = testRegion.Id,
                pse__Practice__c = testPractice.Id
            );
            contactsToCreate.add(testContact1);
            
            Contact testContact2 = new Contact(
                FirstName = 'Test',
                LastName = 'Test Contact 2',
                Primary_Phone__c = '5555555555',
                Email = 'test@email.com',
                Phone = '5555555555',
                TimeZone__c = 'Central Time',
                pse__Is_Resource__c = true,
                pse__Salesforce_User__c = userTest.Id,
                pse__Is_Resource_Active__c = true,
                pse__Region__c = testRegion.Id,
                pse__Practice__c = testPractice.Id
            );
            contactsToCreate.add(testContact2);
            
            Contact testContact3 = new Contact(
                FirstName = 'Test',
                LastName = 'Test Contact 3',
                Primary_Phone__c = '5555555555',
                Email = 'test@email.com',
                Phone = '5555555555',
                TimeZone__c = 'Central Time',
                pse__Is_Resource__c = true,
                pse__Salesforce_User__c = userTest3.Id,
                pse__Is_Resource_Active__c = true,
                pse__Region__c = testRegion.Id,
                pse__Practice__c = testPractice.Id
            );
            contactsToCreate.add(testContact3);
            
            insert contactsToCreate;
            
            pse__Proj__c testProject = new pse__Proj__c(
                Name = 'Test Project',
                pse__Start_Date__c = System.today(),
                pse__End_Date__c = System.today() + 7,
                pse__Project_Phase__c = 'Setup',
                pse__Project_Type__c = 'Standard',
                pse__Stage__c = 'Draft',
                pse__Project_Manager__c = testContact1.Id,
                pse__Region__c = testRegion.Id,
                pse__Practice__c = testPractice.Id,
                pse__Is_Active__c = true
            );
            insert testProject;
            
            Test.startTest();
            testProject.pse__End_Date__c = System.today() + 7;
            
            update testProject;
            
            pse__Project_Task__c testProjectTask = new pse__Project_Task__c(
                Name = 'Test Project Task',
                pse__Start_Date_Time__c = System.now(),
                pse__End_Date_Time__c = System.now() + 7,
                pse__Estimated_Hours__c = 8,
                pse__Project__c = testProject.Id
            );
            insert testProjectTask;
            
            Account account = new Account();
            account.Name = 'AccountName';
            account.Site_Access_Required__c = 'Yes';
            insert account;
            
            
            Id installationBadgeRecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('Installation_Badge').getRecordTypeId();
            List<WorkOrder> listWO = new List<WorkOrder>();
            WorkOrder testWorkOrder = new WorkOrder();
            testWorkOrder.Status = 'FF - Work In Progress';
            testWorkOrder.RecordTypeId = installationBadgeRecordTypeId;
            testWorkOrder.Project_Task__c = testProjectTask.Id;
            testWorkOrder.Account = account;
            testWorkOrder.AccountId = account.Id;
            listWO.add(testWorkOrder);
            
            WorkOrder testWorkOrder2 = new WorkOrder();
            testWorkOrder2.Status = 'FF - Work In Progress';
            testWorkOrder2.RecordTypeId = installationBadgeRecordTypeId;
            testWorkOrder2.Project_Task__c = testProjectTask.Id;
            testWorkOrder2.Account = account;
            testWorkOrder2.AccountId = account.Id;
            listWO.add(testWorkOrder2);
            INSERT listWO;
            
            pse__Permission_Control__c testPC = new pse__Permission_Control__c(
                pse__User__c = UserInfo.getUserId(),
                pse__Region__c = testRegion.Id,
                pse__Staffing__c = true,
                pse__Cascading_Permission__c = true
            );
            insert testPC;
            
            //  Create the Schedule
            pse__Schedule__c objScheduleTest1 = new pse__Schedule__c();
            objScheduleTest1.pse__Start_Date__c = System.now().Date();
            objScheduleTest1.pse__End_Date__c = System.now().Date() + 7;
            
            insert objScheduleTest1;
            
            pse__Schedule__c objScheduleTest2 = new pse__Schedule__c();
            objScheduleTest2.pse__Start_Date__c = System.now().Date();
            objScheduleTest2.pse__End_Date__c = System.now().Date() + 7;
            
            insert objScheduleTest2;
            
            //  Create the Assignment
            pse__Assignment__c objAssignmentTest1 = new pse__Assignment__c(
                pse__Resource__c = testContact1.Id,
                pse__Resource__r = testContact1,
                pse__Project__c = testProject.Id,
                pse__Project__r = testProject,
                pse__Bill_Rate__c = 0,
                pse__Schedule__c = objScheduleTest1.Id,
                pse__Schedule__r = objScheduleTest1,
                pse__Closed_for_Expense_Entry__c = false
            );
            insert objAssignmentTest1;
            
            pse__Assignment__c objAssignmentTest2 = new pse__Assignment__c(
                pse__Resource__c = testContact2.Id,
                pse__Resource__r = testContact2,
                pse__Project__c = testProject.Id,
                pse__Project__r = testProject,
                pse__Bill_Rate__c = 0,
                pse__Schedule__c = objScheduleTest2.Id,
                pse__Schedule__r = objScheduleTest2,
                pse__Closed_for_Expense_Entry__c = false
            );
            insert objAssignmentTest2;      
            
            pse__Project_Task_Assignment__c testPTA1 = new pse__Project_Task_Assignment__c(
                pse__Assignment__c = objAssignmentTest2.Id,
                pse__Project_Task__c = testProjectTask.Id,
                pse__Resource__c = testContact2.Id
            );
            
            insert testPTA1;
            
            Id installationBadgeRecordType = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByName().get('Installation - Badge').getRecordTypeId();
            
            List<ServiceAppointment> servicesAppointmentsToCreate = new List<ServiceAppointment>();
            ServiceAppointment testSA1 = new ServiceAppointment(
                Work_Order__c = listWO.get(0).Id,
                EarliestStartTime = System.now(),
                DueDate = System.now() + 7,
                Status = 'New',
                ParentRecordId = listWO.get(0).Id,
                Project__c = testProject.Id,
                RecordTypeId = installationBadgeRecordType,
                Assignee__c = testContact1.Id,
                SchedStartTime = System.now(),
                SchedEndTime = System.now() + 7,
                Assignment__c = objAssignmentTest1.Id
            );
            servicesAppointmentsToCreate.add(testSA1);
            
            ServiceAppointment testSA2 = new ServiceAppointment(
                Work_Order__c = listWO.get(1).Id,
                EarliestStartTime = System.now(),
                DueDate = System.now() + 7,
                Status = 'New',
                ParentRecordId = listWO.get(1).Id,
                Project__c = testProject.Id,
                RecordTypeId = installationBadgeRecordType,
                Assignee__c = testContact2.Id,
                SchedStartTime = System.now(),
                SchedEndTime = System.now() + 7,
                Assignment__c = objAssignmentTest2.Id
            );
            servicesAppointmentsToCreate.add(testSA2);
            
            insert servicesAppointmentsToCreate;
            
            Test.stopTest();
            // Assertions begin.
            
            //  Trigger changes
            testSA2.Assignee__c = testContact3.Id;
            update testSA2;
            
            // Was previous Assignee assigned to other SAs on same Project? -- NO
            
            // Delete Assignment record related to SA
            List<pse__Assignment__c> deletedAssignment = [SELECT Id FROM pse__Assignment__c WHERE pse__Resource__c =: testContact2.Id];
            //System.assertEquals(true, deletedAssignment.isEmpty(), 'Delete Assignment record related to SA');
            
            //Delete the PTA related to the Assignment
            List<pse__Project_Task_Assignment__c> deletedPTA = [SELECT Id FROM pse__Project_Task_Assignment__c WHERE pse__Project_Task__c =: testProjectTask.Id and pse__Resource__c =: testContact2.Id];
            //System.assertEquals(true, deletedPTA.isEmpty(), 'Delete the PTA related to the Assignment');
            
            // Does new Assignee already have Assignment on Project? -- NO
            
            List<pse__Assignment__c> objAssignmentTest3 = [SELECT Id FROM pse__Assignment__c WHERE pse__Resource__c =: testContact3.Id ];
            //System.assertEquals(false, objAssignmentTest3.isEmpty(), 'Create Assignment record for Assignee');
            
            List<pse__Project_Task_Assignment__c> testPTA3 = [SELECT Id FROM pse__Project_Task_Assignment__c WHERE pse__Project_Task__c =: testProjectTask.Id and pse__Resource__c =: testContact3.Id];
            //System.assertEquals(false, testPTA3.isEmpty(), 'Create new PTA for Project Task related to SA');
            
        }
    }
    
    /**
* @description 
* @author Luis Campos (LC) | 12/28/2020 
* @return void 
**/
    @IsTest
    static void testChangedScenario3()
    {
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
            
            User userTest = TestDataGenerator.createUser('Vincenzo','Cassano','21');
            insert userTest;
            
            User userTest3 = TestDataGenerator.createUser('Honge','Chayoung','23');
            insert userTest3;
            
            List<Contact> contactsToCreate = new List<Contact>();
            
            Contact testContact1 = new Contact(
                FirstName = 'Test',
                LastName = 'Test Contact 1',
                Primary_Phone__c = '5555555555',
                Email = 'test@email.com',
                Phone = '5555555555',
                TimeZone__c = 'Central Time',
                pse__Is_Resource__c = true,
                pse__Salesforce_User__c = UserInfo.getUserId(),
                pse__Is_Resource_Active__c = true,
                pse__Region__c = testRegion.Id,
                pse__Practice__c = testPractice.Id
            );
            contactsToCreate.add(testContact1);
            
            Contact testContact2 = new Contact(
                FirstName = 'Test',
                LastName = 'Test Contact 2',
                Primary_Phone__c = '5555555555',
                Email = 'test@email.com',
                Phone = '5555555555',
                TimeZone__c = 'Central Time',
                pse__Is_Resource__c = true,
                pse__Salesforce_User__c = userTest.Id,
                pse__Is_Resource_Active__c = true,
                pse__Region__c = testRegion.Id,
                pse__Practice__c = testPractice.Id
            );
            contactsToCreate.add(testContact2);
            
            Contact testContact3 = new Contact(
                FirstName = 'Test',
                LastName = 'Test Contact 3',
                Primary_Phone__c = '5555555555',
                Email = 'test@email.com',
                Phone = '5555555555',
                TimeZone__c = 'Central Time',
                pse__Is_Resource__c = true,
                pse__Salesforce_User__c = userTest3.Id,
                pse__Is_Resource_Active__c = true,
                pse__Region__c = testRegion.Id,
                pse__Practice__c = testPractice.Id
            );
            contactsToCreate.add(testContact3);
            
            insert contactsToCreate;
            
            pse__Proj__c testProject = new pse__Proj__c(
                Name = 'Test Project',
                pse__Start_Date__c = System.today(),
                pse__End_Date__c = System.today() + 7,
                pse__Project_Phase__c = 'Setup',
                pse__Project_Type__c = 'Standard',
                pse__Stage__c = 'Draft',
                pse__Project_Manager__c = testContact1.Id,
                pse__Region__c = testRegion.Id,
                pse__Practice__c = testPractice.Id,
                pse__Is_Active__c = true
            );
            insert testProject;
            
            Test.startTest();
            testProject.pse__End_Date__c = System.today() + 7;
            
            update testProject;
            
            pse__Project_Task__c testProjectTask = new pse__Project_Task__c(
                Name = 'Test Project Task',
                pse__Start_Date_Time__c = System.now(),
                pse__End_Date_Time__c = System.now() + 7,
                pse__Estimated_Hours__c = 8,
                pse__Project__c = testProject.Id
            );
            insert testProjectTask;
            
            Account account = new Account();
            account.Name = 'AccountName';
            account.Site_Access_Required__c = 'Yes';
            insert account;
            
            Id installationBadgeRecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('Installation_Badge').getRecordTypeId();
            List<WorkOrder> listWO = new List<WorkOrder>();
            
            WorkOrder testWorkOrder = new WorkOrder();
            testWorkOrder.Status = 'FF - Work In Progress';
            testWorkOrder.RecordTypeId = installationBadgeRecordTypeId;
            testWorkOrder.Project_Task__c = testProjectTask.Id;
            testWorkOrder.Account = account;
            testWorkOrder.AccountId = account.Id;
            listWO.add(testWorkOrder);
            
            WorkOrder testWorkOrder2 = new WorkOrder();
            testWorkOrder2.Status = 'FF - Work In Progress';
            testWorkOrder2.RecordTypeId = installationBadgeRecordTypeId;
            testWorkOrder2.Project_Task__c = testProjectTask.Id;
            testWorkOrder2.Account = account;
            testWorkOrder2.AccountId = account.Id;
            listWO.add(testWorkOrder2);
            
            WorkOrder testWorkOrder3 = new WorkOrder();
            testWorkOrder3.Status = 'FF - Work In Progress';
            testWorkOrder3.RecordTypeId = installationBadgeRecordTypeId;
            testWorkOrder3.Project_Task__c = testProjectTask.Id;
            testWorkOrder3.Account = account;
            testWorkOrder3.AccountId = account.Id;
            listWO.add(testWorkOrder3);
            INSERT listWO;
            
            pse__Permission_Control__c testPC = new pse__Permission_Control__c(
                pse__User__c = UserInfo.getUserId(),
                pse__Region__c = testRegion.Id,
                pse__Staffing__c = true,
                pse__Cascading_Permission__c = true
            );
            insert testPC;
            
            // Create the Schedule
            pse__Schedule__c objScheduleTest1 = new pse__Schedule__c();
            objScheduleTest1.pse__Start_Date__c = System.now().Date();
            objScheduleTest1.pse__End_Date__c = System.now().Date() + 7;
            
            insert objScheduleTest1;
            
            pse__Schedule__c objScheduleTest2 = new pse__Schedule__c();
            objScheduleTest2.pse__Start_Date__c = System.now().Date();
            objScheduleTest2.pse__End_Date__c = System.now().Date() + 7;
            
            insert objScheduleTest2;
            
            // Create the Assignment
            pse__Assignment__c objAssignmentTest1 = new pse__Assignment__c(
                pse__Resource__c = testContact1.Id,
                pse__Resource__r = testContact1,
                pse__Project__c = testProject.Id,
                pse__Project__r = testProject,
                pse__Bill_Rate__c = 0,
                pse__Schedule__c = objScheduleTest1.Id,
                pse__Schedule__r = objScheduleTest1,
                pse__Closed_for_Expense_Entry__c = false
            );
            insert objAssignmentTest1;
            
            pse__Assignment__c objAssignmentTest2 = new pse__Assignment__c(
                pse__Resource__c = testContact2.Id,
                pse__Resource__r = testContact2,
                pse__Project__c = testProject.Id,
                pse__Project__r = testProject,
                pse__Bill_Rate__c = 0,
                pse__Schedule__c = objScheduleTest2.Id,
                pse__Schedule__r = objScheduleTest2,
                pse__Closed_for_Expense_Entry__c = false
            );
            insert objAssignmentTest2;      
            
            pse__Project_Task_Assignment__c testPTA1 = new pse__Project_Task_Assignment__c(
                pse__Assignment__c = objAssignmentTest1.Id,
                pse__Project_Task__c = testProjectTask.Id,
                pse__Resource__c = testContact1.Id
            );
            
            insert testPTA1;
            
            Id installationBadgeRecordType = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByName().get('Installation - Badge').getRecordTypeId();
            
            List<ServiceAppointment> servicesAppointmentsToCreate = new List<ServiceAppointment>();
            ServiceAppointment testSA1 = new ServiceAppointment(
                Work_Order__c = listWO.get(0).Id,
                EarliestStartTime = System.now(),
                DueDate = System.now() + 7,
                Status = 'New',
                ParentRecordId = listWO.get(0).Id,
                Project__c = testProject.Id,
                RecordTypeId = installationBadgeRecordType,
                Assignee__c = testContact1.Id,
                SchedStartTime = System.now(),
                SchedEndTime = System.now() + 7,
                Assignment__c = objAssignmentTest1.Id
            );
            servicesAppointmentsToCreate.add(testSA1);
            
            ServiceAppointment testSA2 = new ServiceAppointment(
                Work_Order__c = listWO.get(1).Id,
                EarliestStartTime = System.now(),
                DueDate = System.now() + 7,
                Status = 'New',
                ParentRecordId = listWO.get(1).Id,
                Project__c = testProject.Id,
                RecordTypeId = installationBadgeRecordType,
                Assignee__c = testContact2.Id,
                SchedStartTime = System.now(),
                SchedEndTime = System.now() + 7,
                Assignment__c = objAssignmentTest2.Id
            );
            servicesAppointmentsToCreate.add(testSA2);
            
            ServiceAppointment testSA3 = new ServiceAppointment(
                Work_Order__c = listWO.get(2).Id,
                EarliestStartTime = System.now(),
                DueDate = System.now() + 7,
                Status = 'New',
                ParentRecordId = listWO.get(2).Id,
                Project__c = testProject.Id,
                RecordTypeId = installationBadgeRecordType,
                Assignee__c = testContact1.Id,
                SchedStartTime = System.now(),
                SchedEndTime = System.now() + 7,
                Assignment__c = objAssignmentTest1.Id
            );
            servicesAppointmentsToCreate.add(testSA3);
            
            insert servicesAppointmentsToCreate;
            
            Test.stopTest();
            //   Assertions begin.
            
            // Trigger changes
            testSA1.Assignee__c = testContact2.Id;
            update testSA1;
            
            // Was previous Assignee assigned to other SAs on same Project? -- YES
            
            //  Null Assignment field on SA -- This never happen because is set directly to the new assignee.
            
            //  Does new Assignee already have Assignment on Project? -- YES
            
            testSA1 = [SELECT Id, Assignment__c FROM ServiceAppointment WHERE Id =:testSA1.Id LIMIT 1];
            //  System.assertEquals(objAssignmentTest2.Id, testSA1.Assignment__c, 'Populate existing Assignment record on SA');
            
            //  Is there a PTA for the same Project Task on SA? -- NO
            //pse__Project_Task_Assignment__c testPTA2 = [SELECT Id FROM pse__Project_Task_Assignment__c WHERE pse__Project_Task__c =: testProjectTask.Id and pse__Resource__c =: testContact2.Id LIMIT 1];
            //System.assertNotEquals(null, testPTA2, 'Create new PTA for Project Task related to SA');
        } 
    }
    
    /**
* @description 
* @author Luis Campos (LC) | 12/28/2020 
* @return void 
**/
    @IsTest
    static void testChangedScenario4()
    {
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
            
            User userTest = TestDataGenerator.createUser('Junwoo','Hanseok','31');
            insert userTest;
            
            User userTest3 = TestDataGenerator.createUser('Choie','Myunghee','33');
            insert userTest3;
            
            List<Contact> contactsToCreate = new List<Contact>();
            
            Contact testContact1 = new Contact(
                FirstName = 'Test',
                LastName = 'Test Contact 1',
                Primary_Phone__c = '5555555555',
                Email = 'test@email.com',
                Phone = '5555555555',
                TimeZone__c = 'Central Time',
                pse__Is_Resource__c = true,
                pse__Salesforce_User__c = UserInfo.getUserId(),
                pse__Is_Resource_Active__c = true,
                pse__Region__c = testRegion.Id,
                pse__Practice__c = testPractice.Id
            );
            contactsToCreate.add(testContact1);
            
            Contact testContact2 = new Contact(
                FirstName = 'Test',
                LastName = 'Test Contact 2',
                Primary_Phone__c = '5555555555',
                Email = 'test@email.com',
                Phone = '5555555555',
                TimeZone__c = 'Central Time',
                pse__Is_Resource__c = true,
                pse__Salesforce_User__c = userTest.Id,
                pse__Is_Resource_Active__c = true,
                pse__Region__c = testRegion.Id,
                pse__Practice__c = testPractice.Id
            );
            contactsToCreate.add(testContact2);
            
            Contact testContact3 = new Contact(
                FirstName = 'Test',
                LastName = 'Test Contact 3',
                Primary_Phone__c = '5555555555',
                Email = 'test@email.com',
                Phone = '5555555555',
                TimeZone__c = 'Central Time',
                pse__Is_Resource__c = true,
                pse__Salesforce_User__c = userTest3.Id,
                pse__Is_Resource_Active__c = true,
                pse__Region__c = testRegion.Id,
                pse__Practice__c = testPractice.Id
            );
            contactsToCreate.add(testContact3);
            
            insert contactsToCreate;
            
            pse__Proj__c testProject = new pse__Proj__c(
                Name = 'Test Project',
                pse__Start_Date__c = System.today(),
                pse__End_Date__c = System.today() + 7,
                pse__Project_Phase__c = 'Setup',
                pse__Project_Type__c = 'Standard',
                pse__Stage__c = 'Draft',
                pse__Project_Manager__c = testContact1.Id,
                pse__Region__c = testRegion.Id,
                pse__Practice__c = testPractice.Id,
                pse__Is_Active__c = true
            );
            insert testProject;
            
            Test.startTest();
            testProject.pse__End_Date__c = System.today() + 7;
            
            update testProject;
            
            List<pse__Project_Task__c> projectTaskToCreate = new List<pse__Project_Task__c>();
            pse__Project_Task__c testProjectTask = new pse__Project_Task__c(
                Name = 'Test Project Task',
                pse__Start_Date_Time__c = System.now(),
                pse__End_Date_Time__c = System.now() + 7,
                pse__Estimated_Hours__c = 8,
                pse__Project__c = testProject.Id
            );
            projectTaskToCreate.add(testProjectTask);
            
            pse__Project_Task__c testProjectTask1 = new pse__Project_Task__c(
                Name = 'Test Project Task',
                pse__Start_Date_Time__c = System.now(),
                pse__End_Date_Time__c = System.now() + 7,
                pse__Estimated_Hours__c = 8,
                pse__Project__c = testProject.Id
            );
            projectTaskToCreate.add(testProjectTask1);
            
            insert projectTaskToCreate;
            
            Account account = new Account();
            account.Name = 'AccountName';
            account.Site_Access_Required__c = 'Yes';
            insert account;
            
            Id installationBadgeRecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('Installation_Badge').getRecordTypeId();
            List<WorkOrder> listWO = new List<WorkOrder>();
            WorkOrder testWorkOrder = new WorkOrder();
            testWorkOrder.Status = 'FF - Work In Progress';
            testWorkOrder.RecordTypeId = installationBadgeRecordTypeId;
            testWorkOrder.Project_Task__c = testProjectTask.Id;
            testWorkOrder.Account = account;
            testWorkOrder.AccountId = account.Id;
            listWO.add(testWorkOrder);
            
            WorkOrder testWorkOrder2 = new WorkOrder();
            testWorkOrder2.Status = 'FF - Work In Progress';
            testWorkOrder2.RecordTypeId = installationBadgeRecordTypeId;
            testWorkOrder2.Project_Task__c = testProjectTask1.Id;
            testWorkOrder2.Account = account;
            testWorkOrder2.AccountId = account.Id;
            listWO.add(testWorkOrder2);
            INSERT listWO;
            
            
            pse__Permission_Control__c testPC = new pse__Permission_Control__c(
                pse__User__c = UserInfo.getUserId(),
                pse__Region__c = testRegion.Id,
                pse__Staffing__c = true,
                pse__Cascading_Permission__c = true
            );
            insert testPC;
            
            // Create the Schedule
            List<pse__Schedule__c> schedulesToCreate = new List<pse__Schedule__c>();
            pse__Schedule__c objScheduleTest1 = new pse__Schedule__c();
            objScheduleTest1.pse__Start_Date__c = System.now().Date();
            objScheduleTest1.pse__End_Date__c = System.now().Date() + 7;
            
            schedulesToCreate.add(objScheduleTest1);
            
            pse__Schedule__c objScheduleTest2 = new pse__Schedule__c();
            objScheduleTest2.pse__Start_Date__c = System.now().Date();
            objScheduleTest2.pse__End_Date__c = System.now().Date() + 7;
            
            schedulesToCreate.add(objScheduleTest2);
            insert schedulesToCreate;
            
            // Create the Assignment
            List<pse__Assignment__c> assignmentsToCreate = new List<pse__Assignment__c>();
            pse__Assignment__c objAssignmentTest1 = new pse__Assignment__c(
                pse__Resource__c = testContact1.Id,
                pse__Resource__r = testContact1,
                pse__Project__c = testProject.Id,
                pse__Project__r = testProject,
                pse__Bill_Rate__c = 0,
                pse__Schedule__c = objScheduleTest1.Id,
                pse__Schedule__r = objScheduleTest1,
                pse__Closed_for_Expense_Entry__c = false
            );
            assignmentsToCreate.add(objAssignmentTest1);
            
            pse__Assignment__c objAssignmentTest2 = new pse__Assignment__c(
                pse__Resource__c = testContact2.Id,
                pse__Resource__r = testContact2,
                pse__Project__c = testProject.Id,
                pse__Project__r = testProject,
                pse__Bill_Rate__c = 0,
                pse__Schedule__c = objScheduleTest2.Id,
                pse__Schedule__r = objScheduleTest2,
                pse__Closed_for_Expense_Entry__c = false
            );
            assignmentsToCreate.add(objAssignmentTest2);
            
            insert assignmentsToCreate;      
            
            List<pse__Project_Task_Assignment__c> ptaToCreate = new List<pse__Project_Task_Assignment__c>();
            pse__Project_Task_Assignment__c testPTA1 = new pse__Project_Task_Assignment__c(
                pse__Assignment__c = objAssignmentTest1.Id,
                pse__Project_Task__c = testProjectTask.Id,
                pse__Resource__c = testContact1.Id
            );
            
            ptaToCreate.add(testPTA1);
            
            pse__Project_Task_Assignment__c testPTA2 = new pse__Project_Task_Assignment__c(
                pse__Assignment__c = objAssignmentTest2.Id,
                pse__Project_Task__c = testProjectTask1.Id,
                pse__Resource__c = testContact2.Id
            );
            
            ptaToCreate.add(testPTA2);
            insert ptaToCreate;
            
            Id installationBadgeRecordType = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByName().get('Installation - Badge').getRecordTypeId();
            
            List<ServiceAppointment> servicesAppointmentsToCreate = new List<ServiceAppointment>();
            ServiceAppointment testSA1 = new ServiceAppointment(
                Work_Order__c = listWO.get(0).Id,
                EarliestStartTime = System.now(),
                DueDate = System.now() + 7,
                Status = 'New',
                ParentRecordId = listWO.get(0).Id,
                Project__c = testProject.Id,
                RecordTypeId = installationBadgeRecordType,
                Assignee__c = testContact1.Id,
                SchedStartTime = System.now(),
                SchedEndTime = System.now() + 7,
                Assignment__c = objAssignmentTest1.Id
            );
            servicesAppointmentsToCreate.add(testSA1);
            
            ServiceAppointment testSA2 = new ServiceAppointment(
                Work_Order__c = listWO.get(1).Id,
                EarliestStartTime = System.now(),
                DueDate = System.now() + 7,
                Status = 'New',
                ParentRecordId = listWO.get(1).Id,
                Project__c = testProject.Id,
                RecordTypeId = installationBadgeRecordType,
                Assignee__c = testContact2.Id,
                SchedStartTime = System.now(),
                SchedEndTime = System.now() + 7,
                Assignment__c = objAssignmentTest2.Id
            );
            servicesAppointmentsToCreate.add(testSA2);
            
            insert servicesAppointmentsToCreate;
            Test.stopTest();
            //  Assertions begin.
            
            // Trigger changes
            testSA1.Assignee__c = testContact2.Id;
            update testSA1;
            
            // Was previous Assignee assigned to other SAs on same Project? -- YES
            // Null Assignment field on SA -- This never happen because is set directly to the new assignee.
            
            //   Does new Assignee already have Assignment on Project? -- YES
            
            testSA1 = [SELECT Id, Assignment__c FROM ServiceAppointment WHERE Id =:testSA1.Id LIMIT 1];
            //System.assertEquals(objAssignmentTest2.Id, testSA1.Assignment__c, 'Populate existing Assignment record on SA');
            
            // Is there a PTA for the same Project Task on SA? -- YES
        }
    }
    
    @IsTest
    public static void testpopulate1(){
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
            
            Test.startTest();
            
            Contact testContact = new Contact(
                FirstName = 'Test',    
                LastName = 'Test Contact',
                Primary_Phone__c = '5555555555',
                Email = 'test@email.com',
                Phone = '5555555555',
                TimeZone__c = 'Central Time',
                pse__Is_Resource__c = true,
                pse__Salesforce_User__c = UserInfo.getUserId(),
                pse__Is_Resource_Active__c = true,
                pse__Region__c = testRegion.Id,
                pse__Practice__c = testPractice.Id
            );
            INSERT testContact;
            
            pse__Proj__c testProject = new pse__Proj__c(
                Name = 'Test Project',
                pse__Start_Date__c = System.today(),
                pse__End_Date__c = System.today() + 7,
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
                pse__Start_Date_Time__c = System.now(),
                pse__End_Date_Time__c = System.now() + 7,
                pse__Estimated_Hours__c = 8,
                pse__Project__c = testProject.Id
            );
            insert testProjectTask;
            
            Account account = new Account();
            account.Name = 'AccountName';
            account.Site_Access_Required__c = 'Yes';
            insert account;
            
            Id installationBadgeRecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('Installation_Badge').getRecordTypeId();
            WorkOrder testWorkOrder = new WorkOrder();
            testWorkOrder.Status = 'FF - Work In Progress';
            testWorkOrder.RecordTypeId = installationBadgeRecordTypeId;
            testWorkOrder.Project_Task__c = testProjectTask.Id;
            testWorkOrder.Account = account;
            testWorkOrder.AccountId = account.Id;
            insert testWorkOrder;
            
            pse__Permission_Control__c testPC = new pse__Permission_Control__c(
                pse__User__c = UserInfo.getUserId(),
                pse__Region__c = testRegion.Id,
                pse__Staffing__c = true,
                pse__Cascading_Permission__c = true
            );
            insert testPC;
            
            pse__Schedule__c objScheduleTest = new pse__Schedule__c();
            objScheduleTest.pse__Start_Date__c = System.now().Date() + 3;
            objScheduleTest.pse__End_Date__c = System.now().Date() + 7;
            
            insert objScheduleTest;
            
            // Create the Assignment
            pse__Assignment__c objAssignmentTest = new pse__Assignment__c(
                pse__Resource__c = testContact.Id,
                pse__Resource__r = testContact,
                pse__Project__c = testProject.Id,
                pse__Project__r = testProject,
                pse__Bill_Rate__c = 0,
                pse__Schedule__c = objScheduleTest.Id,
                pse__Schedule__r = objScheduleTest,
                pse__Closed_for_Expense_Entry__c = false
            );
            insert objAssignmentTest;
            
            pse__Project_Task_Assignment__c testPTA = new pse__Project_Task_Assignment__c(
                pse__Assignment__c = objAssignmentTest.Id,
                pse__Project_Task__c = testProjectTask.Id,
                pse__Resource__c = testContact.Id
            );
            
            insert testPTA;
            
            Id installationBadgeRecordType = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByName().get('Installation - Badge').getRecordTypeId();
            ServiceAppointment newtestSA2 = new ServiceAppointment(
                Work_Order__c = testWorkOrder.Id,
                EarliestStartTime = System.now(),
                DueDate = System.now() + 7,
                Status = 'New',
                ParentRecordId = testWorkOrder.Id,
                Project__c = testProject.Id,
                RecordTypeId = installationBadgeRecordType
            );
            insert newtestSA2;
            
            ServiceAppointment testSA = new ServiceAppointment(
                Work_Order__c = testWorkOrder.Id,
                EarliestStartTime = System.now(),
                DueDate = System.now() + 7,
                Status = 'New',
                ParentRecordId = testWorkOrder.Id,
                Assignee__c = testContact.Id,
                Assignment__c = objAssignmentTest.Id,
                SchedStartTime = System.now().Date() + 1,
                SchedEndTime = System.now().Date() + 15,
                ActualStartTime = System.now().Date() + 2,
                ActualEndTime = System.now().Date() + 9,
                RecordTypeId = installationBadgeRecordType
            );
            insert testSA;
            
            ServiceAppointment newtestSA31 = new ServiceAppointment(
                Work_Order__c = testWorkOrder.Id,
                EarliestStartTime = System.now(),
                DueDate = System.now() + 15,
                Status = 'New',
                ParentRecordId = testWorkOrder.Id,
                Project__c = testProject.Id,
                
                RecordTypeId = installationBadgeRecordType
            );
            insert newtestSA31;
            
            FSL.GlobalAPIS.addStatusTransition('New', 'Scheduled');
            newtestSA2.Status = 'Scheduled';
            update newtestSA2;
            
            FSL.GlobalAPIS.addStatusTransition('New', 'Canceled');
            newtestSA31.Status = 'Canceled';
            update newtestSA31;
            
            Test.stopTest();
        }
        
    }
    
    
    @IsTest
    public static void testupdate1()
    {
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
            
            Contact testContact = new Contact(
                FirstName = 'Test',
                LastName = 'Test Contact',
                Primary_Phone__c = '5555555555',
                Email = 'test@email.com',
                Phone = '5555555555',
                TimeZone__c = 'Central Time',
                pse__Is_Resource__c = true,
                pse__Salesforce_User__c = UserInfo.getUserId(),
                pse__Is_Resource_Active__c = true,
                pse__Region__c = testRegion.Id,
                pse__Practice__c = testPractice.Id
            );
            INSERT testContact;
            
            pse__Proj__c testProject = new pse__Proj__c(
                Name = 'Test Project',
                pse__Start_Date__c = System.today(),
                pse__End_Date__c = System.today() + 7,
                pse__Project_Phase__c = 'Setup',
                pse__Project_Type__c = 'Standard',
                pse__Stage__c = 'Draft',
                pse__Project_Manager__c = testContact.Id,
                pse__Region__c = testRegion.Id,
                pse__Practice__c = testPractice.Id,
                pse__Is_Active__c = true
            );
            insert testProject;
            
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
            
            Test.startTest();
            
            Account account = new Account();
            account.Name = 'AccountName';
            account.Site_Access_Required__c = 'Yes';
            insert account;
            
            WorkOrder testWorkOrder = new WorkOrder();
            testWorkOrder.Account = account;
            testWorkOrder.AccountId = account.Id;
            testWorkOrder.Status = 'FF - Work In Progress';
            testWorkOrder.RecordTypeId = installationBadgeRecordTypeId;
            testWorkOrder.Project_Task__c = testProjectTask.Id;
            insert testWorkOrder;
            
            pse__Permission_Control__c testPC = new pse__Permission_Control__c(
                pse__User__c = UserInfo.getUserId(),
                pse__Region__c = testRegion.Id,
                pse__Staffing__c = true,
                pse__Cascading_Permission__c = true
            );
            insert testPC;
            
            pse__Schedule__c objScheduleTest = new pse__Schedule__c();
            objScheduleTest.pse__Start_Date__c = System.now().Date();
            objScheduleTest.pse__End_Date__c = System.now().Date() + 7;
            
            insert objScheduleTest;
            
            pse__Assignment__c objAssignmentTest = new pse__Assignment__c(
                pse__Resource__c = testContact.Id,
                pse__Resource__r = testContact,
                pse__Project__c = testProject.Id,
                pse__Project__r = testProject,
                pse__Bill_Rate__c = 0,
                pse__Schedule__c = objScheduleTest.Id,
                pse__Status__c = 'Cancelled',
                pse__Schedule__r = objScheduleTest,
                pse__Closed_for_Expense_Entry__c = false
            );
            insert objAssignmentTest;
            
            pse__Project_Task_Assignment__c testPTA = new pse__Project_Task_Assignment__c(
                pse__Assignment__c = objAssignmentTest.Id,
                pse__Project_Task__c = testProjectTask.Id,
                pse__Resource__c = testContact.Id
            );
            
            insert testPTA;
            
            Id installationBadgeRecordType = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByName().get('Installation - Badge').getRecordTypeId();
            
            ServiceAppointment testSA1 = new ServiceAppointment(
                Work_Order__c = testWorkOrder.Id,
                EarliestStartTime = System.now().Date() + 1,
                DueDate = System.now().Date() + 17,
                Status = 'New',
                Assignee__c = testContact.Id,
                Assignment__c = objAssignmentTest.Id,
                ParentRecordId = testWorkOrder.Id,
                RecordTypeId = installationBadgeRecordType
            );
            insert testSA1;
            
            ServiceAppointment testSA11 = new ServiceAppointment(
                Work_Order__c = testWorkOrder.Id,
                EarliestStartTime = System.now().Date() + 1,
                DueDate = System.now().Date() + 17,
                Status = 'New',
                ParentRecordId = testWorkOrder.Id,
                Assignee__c = testContact.Id,
                Assignment__c = objAssignmentTest.Id,
                RecordTypeId = installationBadgeRecordType
            );
            insert testSA11;
            
            FSL.GlobalAPIS.addStatusTransition('New', 'Scheduled');
            testSA1.Status = 'Scheduled';
            testSA11.Status = 'Scheduled';
            update testSA1;
            update testSA11;
            
            FSL.GlobalAPIS.addStatusTransition('Scheduled', 'Dispatched');
            testSA1.Status = 'Dispatched';
            update testSA1; 
            
            /*FSL.GlobalAPIS.addStatusTransition('Dispatched', 'Click_Remote Execution');
testSA1.Status = 'Click_Remote Execution';
update testSA1;*/
            
            Test.stopTest();
        }
    }
    
    @IsTest
    public static void testRMlogin()
    {
        
        List<User> loginUser3 =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser3[0]){
            
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
            
            Contact testContact = new Contact(
                FirstName = 'Test',    
                LastName = 'Test Contact',
                Primary_Phone__c = '5555555555',
                Email = 'test@email.com',
                Phone = '5555555555',
                TimeZone__c = 'Central Time',
                pse__Is_Resource__c = true,
                pse__Salesforce_User__c = UserInfo.getUserId(),
                pse__Is_Resource_Active__c = true,
                pse__Region__c = testRegion.Id,
                pse__Practice__c = testPractice.Id
            );
            INSERT testContact;
            
            pse__Proj__c testProject = new pse__Proj__c(
                Name = 'Test Project',
                pse__Start_Date__c = System.today(),
                pse__End_Date__c = System.today() + 7,
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
                pse__Start_Date_Time__c = System.now(),
                pse__End_Date_Time__c = System.now() + 7,
                pse__Estimated_Hours__c = 8,
                pse__Project__c = testProject.Id
            );
            insert testProjectTask;
            
            Account account = new Account();
            account.Name = 'AccountName';
            account.Site_Access_Required__c = 'Yes';
            insert account;
            
            Id installationBadgeRecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('Installation_Badge').getRecordTypeId();
            WorkOrder testWorkOrder = new WorkOrder();
            testWorkOrder.Status = 'FF - Work In Progress';
            testWorkOrder.RecordTypeId = installationBadgeRecordTypeId;
            testWorkOrder.Project_Task__c = testProjectTask.Id;
            testWorkOrder.Account = account;
            testWorkOrder.AccountId = account.Id;
            insert testWorkOrder;
            
            pse__Permission_Control__c testPC = new pse__Permission_Control__c(
                pse__User__c = UserInfo.getUserId(),
                pse__Region__c = testRegion.Id,
                pse__Staffing__c = true,
                pse__Cascading_Permission__c = true
            );
            insert testPC;
            
            pse__Schedule__c objScheduleTest = new pse__Schedule__c();
            objScheduleTest.pse__Start_Date__c = System.now().Date();
            objScheduleTest.pse__End_Date__c = System.now().Date() + 15;
            
            insert objScheduleTest;
            
            pse__Assignment__c objAssignmentTest = new pse__Assignment__c(
                pse__Resource__c = testContact.Id,
                pse__Resource__r = testContact,
                pse__Project__c = testProject.Id,
                pse__Project__r = testProject,
                pse__Bill_Rate__c = 0,
                pse__Schedule__c = objScheduleTest.Id,
                pse__Schedule__r = objScheduleTest,
                pse__Closed_for_Expense_Entry__c = false
            );
            insert objAssignmentTest;
            
            pse__Project_Task_Assignment__c testPTA = new pse__Project_Task_Assignment__c(
                pse__Assignment__c = objAssignmentTest.Id,
                pse__Project_Task__c = testProjectTask.Id,
                pse__Resource__c = testContact.Id
            );
            
            insert testPTA;
            
            Id installationBadgeRecordType = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByName().get('Installation - Badge').getRecordTypeId();
            List<ServiceAppointment> salists = new List<ServiceAppointment>();
            ServiceAppointment testSA1 = new ServiceAppointment(
                Work_Order__c = testWorkOrder.Id,
                EarliestStartTime = System.now(),
                DueDate = System.now() + 7,
                Status = 'New',
                ParentRecordId = testWorkOrder.Id,
                SchedStartTime = System.now(),
                SchedEndTime = System.now() + 7,
                RecordTypeId = installationBadgeRecordType
            );
            salists.add(testSA1);
            
            ServiceAppointment testSA4 = new ServiceAppointment(
                Work_Order__c = testWorkOrder.Id,
                EarliestStartTime = System.now(),
                DueDate = System.now() + 7,
                Status = 'New',
                ParentRecordId = testWorkOrder.Id,
                SchedStartTime = System.now(),
                SchedEndTime = System.now() + 5,
                RecordTypeId = installationBadgeRecordType
            );
            salists.add(testSA4);
            
            ServiceAppointment testSA2 = new ServiceAppointment(
                Work_Order__c = testWorkOrder.Id,
                EarliestStartTime = System.now(),
                DueDate = System.now() + 7,
                Status = 'New',
                ParentRecordId = testWorkOrder.Id,
                SchedStartTime = System.now(),
                SchedEndTime = System.now() + 5,
                Assignee__c = testContact.Id,
                RecordTypeId = installationBadgeRecordType
            );
            salists.add(testSA2);
            insert salists;
            
            
            testSA1.Assignee__c = testContact.Id;
            
            testSA1.Assignment__c = objAssignmentTest.Id;
            update testSA1;
            
            Profile userProfile1 = [SELECT Id, Name FROM Profile WHERE Profile.Name = 'PSA Resource Manager' LIMIT 1];
            List<User> loginUser4 =  [SELECT Id, Name FROM User Where profileId =: userProfile1.Id];
            system.runAs(loginUser4[0]){
                testSA4.SchedStartTime = null;
                testSA4.SchedEndTime = null;
                update testSA4;    
            }
            
            FSL.GlobalAPIS.addStatusTransition('New', 'Scheduled');
            testSA2.Status = 'Scheduled';
            update testSA2;
            FSL.GlobalAPIS.addStatusTransition('Scheduled', 'Dispatched');
            testSA2.Status = 'Dispatched';
            update testSA2;
            
            Test.stopTest();
        }
    }
    
    @IsTest
    public static void testPMlogin()
    {
        
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
            
            Contact testContact = new Contact(
                FirstName = 'Test',
                LastName = 'Test Contact',
                Primary_Phone__c = '5555555555',
                Email = 'test@email.com',
                Phone = '5555555555',
                TimeZone__c = 'Central Time',
                pse__Is_Resource__c = true,
                pse__Salesforce_User__c = UserInfo.getUserId(),
                pse__Is_Resource_Active__c = true,
                pse__Region__c = testRegion.Id,
                pse__Practice__c = testPractice.Id
            );
            INSERT testContact;
            
            Test.startTest();
            
            pse__Proj__c testProject = new pse__Proj__c(
                Name = 'Test Project',
                pse__Start_Date__c = System.today(),
                pse__End_Date__c = System.today() + 7,
                pse__Project_Phase__c = 'Setup',
                pse__Project_Type__c = 'Standard',
                pse__Stage__c = 'Draft',
                pse__Project_Manager__c = testContact.Id,
                pse__Region__c = testRegion.Id,
                pse__Practice__c = testPractice.Id,
                pse__Is_Active__c = true
            );
            insert testProject;
            
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
            
            Account account = new Account();
            account.Name = 'AccountName';
            account.Site_Access_Required__c = 'Yes';
            insert account;
            
            WorkOrder testWorkOrder = new WorkOrder();
            testWorkOrder.Account = account;
            testWorkOrder.AccountId = account.Id;
            testWorkOrder.Status = 'FF - Work In Progress';
            testWorkOrder.RecordTypeId = installationBadgeRecordTypeId;
            testWorkOrder.Project_Task__c = testProjectTask.Id;
            insert testWorkOrder;
            
            pse__Permission_Control__c testPC = new pse__Permission_Control__c(
                pse__User__c = UserInfo.getUserId(),
                pse__Region__c = testRegion.Id,
                pse__Staffing__c = true,
                pse__Cascading_Permission__c = true
            );
            insert testPC;
            
            pse__Schedule__c objScheduleTest = new pse__Schedule__c();
            objScheduleTest.pse__Start_Date__c = System.now().Date();
            objScheduleTest.pse__End_Date__c = System.now().Date() + 7;
            
            insert objScheduleTest;
            
            pse__Assignment__c objAssignmentTest = new pse__Assignment__c(
                pse__Resource__c = testContact.Id,
                pse__Resource__r = testContact,
                pse__Project__c = testProject.Id,
                pse__Project__r = testProject,
                pse__Bill_Rate__c = 0,
                pse__Schedule__c = objScheduleTest.Id,
                pse__Schedule__r = objScheduleTest,
                pse__Closed_for_Expense_Entry__c = false
            );
            insert objAssignmentTest;
            
            pse__Project_Task_Assignment__c testPTA = new pse__Project_Task_Assignment__c(
                pse__Assignment__c = objAssignmentTest.Id,
                pse__Project_Task__c = testProjectTask.Id,
                pse__Resource__c = testContact.Id
            );
            
            insert testPTA;
            
            Id installationBadgeRecordType = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByName().get('Installation - Badge').getRecordTypeId();
            List<ServiceAppointment> saList = new List<ServiceAppointment>();
            ServiceAppointment testSA1 = new ServiceAppointment(
                Work_Order__c = testWorkOrder.Id,
                EarliestStartTime = System.now().Date() + 1,
                DueDate = System.now().Date() + 17,
                Status = 'In Progress',
                Assignee__c = testContact.Id,
                Assignment__c = objAssignmentTest.Id,
                ParentRecordId = testWorkOrder.Id,
                
                RecordTypeId = installationBadgeRecordType
            );
            saList.add(testSA1);
            
            ServiceAppointment testSA = new ServiceAppointment(
                Work_Order__c = testWorkOrder.Id,
                EarliestStartTime = System.now().Date() + 1,
                DueDate = System.now().Date() + 17,
                Status = 'New',
                ParentRecordId = testWorkOrder.Id,
                SchedStartTime = System.now().Date() + 2,
                SchedEndTime = System.now().Date() + 5,
                RecordTypeId = installationBadgeRecordType
            );
            saList.add(testSA);
            insert saList;
            
            
           /* FSL.GlobalAPIS.addStatusTransition('In Progress', 'Completed');
            testSA1.Status = 'Completed';
            testSA1.Additional_Effort__c = 'Appointment Task';
            update testSA1;*/
            FSL.GlobalAPIS.addStatusTransition('In Progress', 'Cannot Complete');
            testSA1.Status = 'Cannot Complete';
            testSA1.Additional_Effort__c = 'Appointment Task';
            testSA1.Incomplete_Reason__c = 'Unplanned OOO';
            testSA1.Incomplete_Notes__c = 'Test Termination';
            update testSA1;
            Profile userProfile = [SELECT Id, Name FROM Profile WHERE Profile.Name = 'PSA Project Manager' LIMIT 1];
            List<User> testUser = [SELECT Id, Name FROM User Where profileId =: userProfile.Id];
            system.debug('testUser'+testUser[0]);
            system.runAs(testUser[0]){
                
                testSA.SchedStartTime = System.now().Date() + 4;
                testSA.SchedEndTime = System.now().Date() + 6;
                update testSA;         
            }
            Test.stopTest();
        }
    }
    
    @IsTest
    static void teststatusupdate()
    {
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true Limit 1];
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
            
            User userTest = TestDataGenerator.createUser('Hanseo','Julian','31');
            insert userTest;
            
            Contact testContact2 = new Contact(
                FirstName = 'Test',
                LastName = 'Test Contact 2',
                Primary_Phone__c = '5555555555',
                Email = 'test@email.com',
                Phone = '5555555555',
                TimeZone__c = 'Central Time',
                pse__Is_Resource__c = true,
                pse__Salesforce_User__c = userTest.Id,
                pse__Is_Resource_Active__c = true,
                pse__Region__c = testRegion.Id,
                pse__Practice__c = testPractice.Id
            );
            
            insert testContact2;
            
            Account account = new Account();
            account.Name = 'AccountName';
            account.Site_Access_Required__c = 'Yes';
            insert account;
            
            List<pse__Proj__c> projlist = new List<pse__Proj__c>();
            pse__Proj__c testProject = new pse__Proj__c(
                Name = 'Test Project',
                pse__Start_Date__c = System.today(),
                pse__End_Date__c = System.today() + 7,
                pse__Project_Phase__c = 'Setup',
                pse__Project_Type__c = 'Standard',
                pse__Stage__c = 'Draft',
                pse__Project_Manager__c = testContact2.Id,
                pse__Region__c = testRegion.Id,
                pse__Practice__c = testPractice.Id,
                pse__Is_Active__c = true
            );
            projlist.add(testProject);
            
            pse__Proj__c testProject1 = new pse__Proj__c(
                Name = 'Test Project',
                pse__Start_Date__c = System.today(),
                pse__End_Date__c = System.today() + 7,
                pse__Project_Phase__c = 'Setup',
                pse__Project_Type__c = 'Standard',
                pse__Stage__c = 'Draft',
                pse__Project_Manager__c = testContact2.Id,
                pse__Region__c = testRegion.Id,
                pse__Practice__c = testPractice.Id,
                pse__Is_Active__c = true
            );
            projlist.add(testProject1);
            insert projlist;
            
            pse__Project_Task__c testProjectTask = new pse__Project_Task__c(
                Name = 'Test Project Task',
                pse__Start_Date_Time__c = System.now(),
                pse__End_Date_Time__c = System.now() + 7,
                pse__Estimated_Hours__c = 8,
                pse__Project__c = testProject.Id
            );
            insert testProjectTask;
            
            pse__Permission_Control__c testPC = new pse__Permission_Control__c(
                pse__User__c = UserInfo.getUserId(),
                pse__Region__c = testRegion.Id,
                pse__Staffing__c = true,
                pse__Cascading_Permission__c = true
            );
            insert testPC;
            Test.startTest();
            pse__Schedule__c objScheduleTest2 = new pse__Schedule__c();
            objScheduleTest2.pse__Start_Date__c = System.now().Date();
            objScheduleTest2.pse__End_Date__c = System.now().Date() + 7;
            insert objScheduleTest2;
            
            pse__Assignment__c objAssignmentTest2 = new pse__Assignment__c(
                pse__Resource__c = testContact2.Id,
                pse__Resource__r = testContact2,
                pse__Project__c = testProject1.Id,
                pse__Project__r = testProject1,
                pse__Bill_Rate__c = 0,
                pse__Schedule__c = objScheduleTest2.Id,
                pse__Schedule__r = objScheduleTest2,
                pse__Closed_for_Expense_Entry__c = false
            );
            
            insert objAssignmentTest2;
            
            pse__Project_Task_Assignment__c testPTA2 = new pse__Project_Task_Assignment__c(
                pse__Assignment__c = objAssignmentTest2.Id,
                pse__Project_Task__c = testProjectTask.Id,
                pse__Resource__c = testContact2.Id
            );
            
            insert testPTA2;
            
            Id installationBadgeRecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('Installation_Badge').getRecordTypeId();
            List<WorkOrder> listWO = new List<WorkOrder>();
            WorkOrder testWorkOrder = new WorkOrder();
            testWorkOrder.Status = 'FF - Work In Progress';
            testWorkOrder.RecordTypeId = installationBadgeRecordTypeId;
            testWorkOrder.Project_Task__c = testProjectTask.Id;
            testWorkOrder.Account = account;
            testWorkOrder.AccountId = account.Id;
            insert testWorkOrder;
            
            Id installationBadgeRecordType = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByName().get('Installation - Badge').getRecordTypeId();
            List<ServiceAppointment> salist = new List<ServiceAppointment>();
            ServiceAppointment testSA1 = new ServiceAppointment(
                Work_Order__c = testWorkOrder.Id,
                EarliestStartTime = System.now(),
                DueDate = System.now() + 7,
                Status = 'New',
                Project__c = testProject.Id,
                ParentRecordId = testWorkOrder.Id,
                RecordTypeId = installationBadgeRecordType,
                SchedStartTime = System.now(),
                SchedEndTime = System.now() + 7,
                Assignee__c = testContact2.Id,
                Assignment__c = objAssignmentTest2.Id
            );
            salist.add(testSA1);
            insert salist;

            /*FSL.GlobalAPIS.addStatusTransition('New', 'Scheduled');
            testSA1.Status = 'Scheduled';
            update testSA1;*/
            Test.stopTest();
        }
    }
    
    @IsTest
    static void testAssignee()
    {
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true LIMIT 1];
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
            
            List<User> users = new List<User>();
            User userTest = TestDataGenerator.createUser('Salva','Martin','31');
            users.add(userTest);
            
            User userTest3 = TestDataGenerator.createUser('Pedro','Alonso','33');
            users.add(userTest3);
            insert users;
            
            List<Contact> contactsToCreate = new List<Contact>();
            
            Contact testContact1 = new Contact(
                FirstName = 'Test',
                LastName = 'Test Contact 1',
                Primary_Phone__c = '5555555555',
                Email = 'test@email.com',
                Phone = '5555555555',
                TimeZone__c = 'Central Time',
                pse__Is_Resource__c = true,
                pse__Salesforce_User__c = UserInfo.getUserId(),
                pse__Is_Resource_Active__c = true,
                pse__Region__c = testRegion.Id,
                pse__Practice__c = testPractice.Id
            );
            contactsToCreate.add(testContact1);
            
            Contact testContact2 = new Contact(
                FirstName = 'Test',
                LastName = 'Test Contact 2',
                Primary_Phone__c = '5555555555',
                Email = 'test@email.com',
                Phone = '5555555555',
                TimeZone__c = 'Central Time',
                pse__Is_Resource__c = true,
                pse__Salesforce_User__c = userTest.Id,
                pse__Is_Resource_Active__c = true,
                pse__Region__c = testRegion.Id,
                pse__Practice__c = testPractice.Id
            );
            contactsToCreate.add(testContact2);
            
            insert contactsToCreate;
            
            pse__Proj__c testProject = new pse__Proj__c(
                Name = 'Test Project',
                pse__Start_Date__c = System.today(),
                pse__End_Date__c = System.today() + 7,
                pse__Project_Phase__c = 'Setup',
                pse__Project_Type__c = 'Standard',
                pse__Stage__c = 'Draft',
                pse__Project_Manager__c = testContact1.Id,
                pse__Region__c = testRegion.Id,
                pse__Practice__c = testPractice.Id,
                pse__Is_Active__c = true
            );
            insert testProject;
            
            pse__Project_Task__c testProjectTask = new pse__Project_Task__c(
                Name = 'Test Project Task',
                pse__Start_Date_Time__c = System.now(),
                pse__End_Date_Time__c = System.now() + 7,
                pse__Estimated_Hours__c = 8,
                pse__Project__c = testProject.Id
            );
            insert testProjectTask;
            
            Account account = new Account();
            account.Name = 'AccountName';
            account.Site_Access_Required__c = 'Yes';
            insert account;
            
            pse__Permission_Control__c testPC = new pse__Permission_Control__c(
                pse__User__c = UserInfo.getUserId(),
                pse__Region__c = testRegion.Id,
                pse__Staffing__c = true,
                pse__Cascading_Permission__c = true
            );
            insert testPC;
            List<pse__Schedule__c> objschd = new List<pse__Schedule__c>();
            
            pse__Schedule__c objScheduleTest1 = new pse__Schedule__c();
            objScheduleTest1.pse__Start_Date__c = System.now().Date();
            objScheduleTest1.pse__End_Date__c = System.now().Date() + 7;
            
            objschd.add(objScheduleTest1);
            
            pse__Schedule__c objScheduleTest2 = new pse__Schedule__c();
            objScheduleTest2.pse__Start_Date__c = System.now().Date();
            objScheduleTest2.pse__End_Date__c = System.now().Date() + 7;
            objschd.add(objScheduleTest2);
            insert objschd;
            
            List<pse__Assignment__c> assignmentsToCreate = new List<pse__Assignment__c>();
            pse__Assignment__c objAssignmentTest1 = new pse__Assignment__c(
                pse__Resource__c = testContact1.Id,
                pse__Resource__r = testContact1,
                pse__Project__c = testProject.Id,
                pse__Project__r = testProject,
                pse__Bill_Rate__c = 0,
                pse__Schedule__c = objScheduleTest1.Id,
                pse__Schedule__r = objScheduleTest1,
                pse__Closed_for_Expense_Entry__c = false
            );
            assignmentsToCreate.add(objAssignmentTest1);
            
            pse__Assignment__c objAssignmentTest2 = new pse__Assignment__c(
                pse__Resource__c = testContact2.Id,
                pse__Resource__r = testContact2,
                pse__Project__c = testProject.Id,
                pse__Project__r = testProject,
                pse__Bill_Rate__c = 0,
                pse__Schedule__c = objScheduleTest1.Id,
                pse__Schedule__r = objScheduleTest1,
                pse__Closed_for_Expense_Entry__c = false
            );
            assignmentsToCreate.add(objAssignmentTest2);
            
            insert assignmentsToCreate;      
            
            List<pse__Project_Task_Assignment__c> ptaToCreate = new List<pse__Project_Task_Assignment__c>();
            pse__Project_Task_Assignment__c testPTA1 = new pse__Project_Task_Assignment__c(
                pse__Assignment__c = objAssignmentTest1.Id,
                pse__Project_Task__c = testProjectTask.Id,
                pse__Resource__c = testContact1.Id
            );
            
            ptaToCreate.add(testPTA1);
            
            pse__Project_Task_Assignment__c testPTA2 = new pse__Project_Task_Assignment__c(
                pse__Assignment__c = objAssignmentTest2.Id,
                pse__Project_Task__c = testProjectTask.Id,
                pse__Resource__c = testContact2.Id
            );
            Test.startTest();
            ptaToCreate.add(testPTA2);
            insert ptaToCreate;
            Id installationBadgeRecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('Installation_Badge').getRecordTypeId();
            WorkOrder testWorkOrder = new WorkOrder();
            testWorkOrder.Status = 'FF - Work In Progress';
            testWorkOrder.RecordTypeId = installationBadgeRecordTypeId;
            testWorkOrder.Project_Task__c = testProjectTask.Id;
            testWorkOrder.Account = account;
            testWorkOrder.AccountId = account.Id;
            insert testWorkOrder;
            Id installationBadgeRecordType = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByName().get('Installation - Badge').getRecordTypeId();
            ServiceAppointment testSA1 = new ServiceAppointment(
                Work_Order__c = testWorkOrder.Id,
                EarliestStartTime = System.now(),
                DueDate = System.now() + 7,
                Status = 'New',
                ParentRecordId = testWorkOrder.Id,
                Project__c = testProject.Id,
                RecordTypeId = installationBadgeRecordType,
                SchedStartTime = System.now(),
                SchedEndTime = System.now() + 7
            );
            insert testSA1;
            
            testSA1.Assignee__c = testContact2.Id;
            testSA1.Assignment__c = objAssignmentTest2.Id;
            update testSA1;
            list<ServiceAppointment> saList = new list<ServiceAppointment>();
            saList.add(testSA1);
            Test.stopTest();
        }
     
    }
    
    
}