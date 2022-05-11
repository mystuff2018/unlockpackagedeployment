/**************
* @ Class Name        : ContactEndDateUpdateTest
* @ Description       : Test class for ContactEndDateUpdate, Created as part of IDS Feature #10672632.
* @ CreatedBy         : DFN Services
* @ CreatedOn         : 09/11/2021
* @ Modification Log  : Version 1.0 - [Sivakumari Ediga] : Initially created the script.
***************/


@isTest
public class ContactEndDateUpdateTest {
    @testSetup
     static void setupTestData(){
      List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){	
             Profile p = [SELECT Id FROM Profile WHERE Name='PSA Project Manager']; 
                       
            User u = TestDataUtility.getUser('abcdefg1242@xyz.com');
                 u.LastName = 'Pathos';
                 u.ProfileId = p.id;
                 //u.Username = 'random1235423testtsw@xyz.com';
                 update u;
              System.debug('@@ User ## ' +u);
            
            list<Account> accountList = TestDataUtility.createAccounts(1, false);
            insert accountList;
            System.debug('@@ accountList ' +accountList);

            pse__Practice__c practice = TestDataUtility.getPractice(True);
             System.debug('@@ practice @ ' +practice);
            
            pse__Region__c region = TestDataUtility.getRegion(True);
              System.debug('@@ region ## ' +region);
            
            pse__Permission_Control__c pc = TestDataUtility.getPermissionControl(loginUser[0].id,region.id,false);
            pc.pse__User__c = loginUser[0].id;
            pc.pse__Resource_Request_Entry__c = true;
            pc.pse__Staffing__c = true;
            insert pc;
            System.debug('@@ pc ## ' +pc);
         
            pse__Work_Calendar__c wc = TestDataUtility.createWorkCalender(True);
            
          
            List<Contact> contactList = TestDataUtility.createContacts(1 ,accountList[0].Id , false , true);
            contactList = TestDataUtility.createContacts(1,accountList[0].Id,false,True);
           // integer i =0;
            for(Contact con : contactList){
                //if(i == 0)
                    con.pse__Salesforce_User__c = u.Id;
                con.pse__Resource_Role__c = 'Engineer';
                con.FirstName = 'testNammo';
                con.LastName =  'testLast';
                con.pse__Work_Calendar__c = wc.id;
                con.pse__Region__c = region.id; 
                con.Phone='9876541234';
               // i++;
            }
            insert contactList; 
             System.debug('@@ contactList ## ' +contactList);
          
            
            
            pse__Proj__c project = TestDataUtility.createProject(false);  
            project.Name = 'Test Project';
            project.pse__Region__c = region.Id;
            project.pse__Practice__c = practice.id;
            project.pse__Account__c = accountList[0].Id;
            project.pse__Start_Date__c = System.today();
            project.pse__End_Date__c = System.today() + 30;
            project.pse__Project_Manager__c = contactList[0].id;
            
            insert project;
            
              System.debug('@@ project** ' +project);
             
          /*  pse__Project_Task__c testProjectTask = new pse__Project_Task__c(
                Name = 'Test Project Task',
                pse__Start_Date_Time__c = System.now(),
                pse__End_Date_Time__c = System.now() + 7,
                pse__Estimated_Hours__c = 8,
                pse__Started__c = true,
                pse__Project__c = project.Id
            );
            insert testProjectTask;
            
            System.debug('@@ testProjectTask %% ' +testProjectTask);*/

            
           Id installationBadgeRecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('Installation_Badge').getRecordTypeId();
            
            WorkOrder testWorkOrder = new WorkOrder();
            testWorkOrder.Account = accountList[0];
            testWorkOrder.AccountId = accountList[0].Id;
            testWorkOrder.Status = 'FF - Work In Progress';
            testWorkOrder.RecordTypeId = installationBadgeRecordTypeId;
           // testWorkOrder.Project_Task__c = testProjectTask.Id;
            insert testWorkOrder;
               System.debug('@@ testWorkOrder %% ' +testWorkOrder);  
            
            pse__Schedule__c testSchedule = new pse__Schedule__c();
            testSchedule.pse__Is_Blocking__c = false;
            testSchedule.pse__Start_Date__c = system.today();
            testSchedule.pse__End_Date__c = system.today()+30;
            
            insert testSchedule;
             System.debug('@@ testSchedule %% ' +testSchedule);  
            
              pse__Assignment__c testAssignment = new pse__Assignment__c(
                 Name = 'Test Assignment',
                 pse__Resource__c = contactList[0].Id,
                 pse__Project__c = project.id,
                 pse__Schedule__c = testSchedule.id,
                 pse__Bill_Rate__c = 0,
                 pse__Cost_Rate_Amount__c = 100          
                
            );
            Insert testAssignment;
           System.debug('@@ testAssignment %% ' +testAssignment);  
            
            serviceResource sr = new serviceResource();
            sr.Name = 'Test Reasource';
            //sr.ResourceType = 'Agent';
            sr.FBE_Contact__c = contactList[0].id;
            sr.RelatedRecordId = u.id;
            sr.IsActive = false;
            insert sr;
            
            Id installationBadgeRecordType = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByName().get('Installation - Badge').getRecordTypeId();
            
            ServiceAppointment testSA = new ServiceAppointment();
                testSA.Work_Order__c = testWorkOrder.Id;
                testSA.Project__c = project.id;
                testSA.EarliestStartTime = System.now();
                testSA.DueDate = System.now() + 7;
                testSA.Status = 'Dispatched';
                testSA.Description = 'Test';
                testSA.Assignee__c = contactList[0].id;
                testSA.Assignment__c = testAssignment.id;
                testSA.ParentRecordId = testWorkOrder.Id;
                testSA.RecordTypeId = installationBadgeRecordType;
            
            insert testSA;
              System.debug('@@ testSA %% ' +testSA);  
             
            
            ServiceAppointment testSAOne = new ServiceAppointment();
                testSAOne.id = testSA.id;
                testSAOne.SchedStartTime = System.now();
                testSAOne.SchedEndTime = System.now().Date() + 10;
                testSAOne.Status = 'In Progress';
               update testSAOne;
              System.debug('@@ testSAOne %% ' +testSAOne); 
    
        }                 
         
}
     
    
    @isTest
     static void updateContact(){
         
         
             User us =  [Select id, LastName, FBE_Services_Termination__c from User Where LastName = 'Pathos' Limit 1];
             us.FBE_Services_Termination__c = system.today().addDays(-1);
             update us;
             System.debug(' @@ user  ' +us);
           
            
         Test.startTest();
         ContactEndDateUpdate c = new ContactEndDateUpdate();  
         Database.executeBatch(c,200);
         Test.stopTest();

       
    }

    }