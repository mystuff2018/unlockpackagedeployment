/***************************************************************************************
* Created By - Saurav Raj
* Created On - December 03, 2020
* Related Task - 
* Purpose - TEST Class for  ProjectTaskAssignmentTriggerHandler
****************************************************************************************/
@isTest
public class ProjectTaskAssignmentTriggerHandlerTest {
/***************************************************************************************
* Test method test function popualateRateCardProjectTask
****************************************************************************************/
    static testmethod void popualateRateCardProjectTask(){
       //Create User 
        User user1 = FBE_UtilityFactory_Test.getIntegrationUser();
        System.runAs(user1){
            //Create region
            pse__Region__c region = TestDataUtility.getRegion(false);
            region.pse__Region_ID_Chain__c = 'abc';
            insert region;
      	    //Create Account
            Account acc = TestDataUtility.createAccounts(1,True)[0];
            //Create Custom Domain
            //TestDataUtility.createDomainSettings(1,true, true);
            //create work calendar
            pse__Work_Calendar__c wc = TestDataUtility.createWorkCalender(true);
            //Create Resource
            Contact con = TestDataUtility.createContacts(1,acc.id,false,True)[0];
            con.pse__Region__c = region.id;
            con.pse__Work_Calendar__c = wc.id;
            con.pse__Salesforce_User__c = user1.Id;
            con.pse__Resource_Role__c = 'Project Manager Analyst';
            con.pse__Is_Resource__c = true;
            insert con;
            //Create Project
            pse__Proj__c proj = TestDataUtility.createProject(acc.id,region.id,True);
            update proj;
            pse__Rate_Card__c rateCard = TestDataUtility.createRateCard(region.id,True);
            test.startTest();
            //Create Project task
            pse__Project_Task__c pTask = TestDataUtility.getProjectTask(false,proj.id);
            pTask.pse__Estimated_Hours__c =50;
            pTask.pse__Actual_Hours__c =30;
            pTask.Resource_Role__c = 'Project Manager Analyst';
            //pTask.Account_Name__c = 'Abc';		
            pTask.pse__Status__c = 'Complete ';
            pTask.pse__Started__c = true;
            insert pTask;
            //Create Project Task Assignment
            pse__Project_Task_Assignment__c psa = TestDataUtility.getProjectTaskAssignment(false,pTask.id);
            psa.pse__Resource__c = con.id;
            psa.pse__Allocation_Hours__c = 10;
            insert psa;
            pse__Project_Task__c UpdateTask = [select Actual_Cost__c, Planned_Cost__c, pse__Number_of_Assignments__c,Cost_Rate_Card__c from pse__Project_Task__c where id=:pTask.Id];
            System.assertEquals(UpdateTask.Cost_Rate_Card__c, rateCard.ID);
            test.stopTest();
        }
    }
}