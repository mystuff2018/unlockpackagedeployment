@IsTest
public class FSLCreateShadowAppointmentCtrlTest {
     public testmethod static void testServiceSA(){
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
                Primary_Phone__c = '555-5555',
                Email = 'test@email.com',
                Phone = '2367895624',
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
            Test.startTest();
            ServiceAppointment testSA = new ServiceAppointment(
                Work_Order__c = testWorkOrder.Id,
                EarliestStartTime = System.now(),
                DueDate = System.now() + 7,
                Status = 'New',
                ParentRecordId = testWorkOrder.Id,
                RecordTypeId = installationBadgeRecordType
            );
            insert testSA;
            try{
                String result = FSLCreateShadowAppointmentCtrl.createChildShadowSA(testSA.Id);
                
            }
            catch(Exception e)
            {
                system.debug('error '+e.getMessage());
                
            }
           List<ServiceAppointment> testSA21 = [Select Id FROM ServiceAppointment Where FSL__Related_Service__c =: testSA.Id];
           system.debug('salist'+testSA21);
            Test.stopTest();
        }
    }
}