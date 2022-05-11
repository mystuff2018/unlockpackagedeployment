/***************************************************************************************
* Created By - Saurav Raj (Wipro)
* Created On - September 28, 2021
* Related Task - I-423624
* Purpose - Test class for UtilityClass
****************************************************************************************/
@isTest
public class UtilityClassTest {
static testmethod void CreateProjectAssignmentTest() {
        user u1 = TestDataUtility.getUser('Testfinancialforceadmin@dellTest.com');
        System.runAs(u1){
            //Create region
            pse__Region__c region = TestDataUtility.getRegion(True);
            //Create permission Control
            pse__Permission_Control__c pc = TestDataUtility.getPermissionControl(UserInfo.getUserId(),region.id,false);
            pc.pse__Billing__c= true;
            pc.pse__Staffing__c = true;
            insert pc;
            //Create Account
            Account acc = TestDataUtility.createAccounts(1,True)[0];
            //create work calendar
            pse__Work_Calendar__c wc = TestDataUtility.createWorkCalender(true);
            //CreateRate Card
            pse__Rate_Card__c rc = TestDataUtility.createRateCard(region.Id, true);
            //Create Resource
            Contact con = TestDataUtility.createContacts(1,acc.id,false,true)[0];
            con.pse__Salesforce_User__c = u1.id;
            con.pse__Region__c = region.id;
            con.pse__Work_Calendar__c = wc.id;
            con.pse__Resource_Role__c = 'Project Manager Analyst';
            con.pse__Is_Resource__c = true;
            insert con;
            //Create Custom Domain
            //TestDataUtility.createDomainSettings(1,true, true);
            //Create Project
            pse__Proj__c proj = TestDataUtility.createProject(acc.id,region.id,false);
            proj.pse__Billing_Type__c = 'Time and Materials';
            proj.Deal_Type__c = 'Custom';
            proj.FBE_IDS_Residency__c = true;
            proj.pse__Project_Manager__c = con.id;
            insert proj;
            // Create schedule 
            pse__Schedule__c schedule = new pse__Schedule__c();
            schedule.pse__Start_Date__c= Date.today();
            schedule.pse__End_Date__c= Date.today() + 7;
            schedule.pse__Monday_Hours__c = 0;
            schedule.pse__Tuesday_Hours__c = 0;
            schedule.pse__Wednesday_Hours__c = 0;
            schedule.pse__Thursday_Hours__c = 0;
            schedule.pse__Friday_Hours__c = 0;
            schedule.pse__Saturday_Hours__c = 0;
            schedule.pse__Sunday_Hours__c = 0;
            insert schedule;
            Test.startTest();
            //Create Project task
            pse__Project_Task__c pTask = TestDataUtility.getProjectTask(false,proj.id);
            pTask.pse__Estimated_Hours__c =20;
            pTask.pse__Actual_Hours__c =10;
            pTask.Name = 'PM Time Entry';
            insert pTask;
            //Create Assignment Record
            pse__Assignment__c assign =	TestDataUtility.getAssignment(proj.id,con.id,0,false);
            assign.pse__Is_Billable__c = true;
            assign.pse__Schedule__c = schedule.Id;
            assign.pse__Role__c = 'Project Manager Analyst';
            insert assign;
            List <id> lst = new List<id>();
            lst.add(assign.Id);
            UtilityClass.CreateProjectAssignment(lst);
            Test.stopTest();
                       
        }
    }
}