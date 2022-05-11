@isTest
public class ProjectTaskTriggerHandlerTest {
    
    static testmethod void testPupulateRateCard(){
        //Create region
        pse__Region__c region = TestDataUtility.getRegion(True);
        //Create Account
        Account acc = TestDataUtility.createAccounts(1,True)[0];
        //Create Custom Domain
        //TestDataUtility.createDomainSettings(1,true, true);
        //Create Project
        pse__Proj__c proj = TestDataUtility.createProject(acc.id,region.id,True);
        update proj;
        pse__Rate_Card__c rateCard = TestDataUtility.createRateCard(region.id,true,'Project Manager Analyst');
        test.startTest();
        //Create Project task
        pse__Project_Task__c pTask = TestDataUtility.getProjectTask(false,proj.id);
        pTask.pse__Estimated_Hours__c =20;
        pTask.pse__Actual_Hours__c =10;
        pTask.Cost_Rate_Card__c = rateCard.id;
        insert pTask;
        //pTask.Account_Name__c = 'Abc';
        pTask.Resource_Role__c ='Project Manager Analyst';
        update pTask;
        pse__Project_Task__c updatedTask = [Select Cost_Rate_Card__c from pse__Project_Task__c WHERE Id =: pTask.id];
        system.assertNotEquals(null, updatedTask.Cost_Rate_Card__c);
        pTask.Resource_Role__c = Null ;
        update pTask;
        test.stopTest();
    }
    static testmethod void rollUpPlannedCostAndActualCostOnProjectTest(){
        //Create region
        pse__Region__c region = TestDataUtility.getRegion(True);
        //Create Account
        Account acc = TestDataUtility.createAccounts(1,True)[0];
        //Create Custom Domain
        //TestDataUtility.createDomainSettings(1,true, true);
        //Create Project
        pse__Proj__c proj = TestDataUtility.createProject(acc.id,region.id,True);
        update proj;
       pse__Rate_Card__c rateCard = TestDataUtility.createRateCard(region.id,true,'Project Manager Analyst');
        test.startTest();
        //Create Project task
        pse__Project_Task__c pTask = TestDataUtility.getProjectTask(false,proj.id);
        pTask.pse__Estimated_Hours__c =20;
        pTask.pse__Actual_Hours__c =10;
        insert pTask;
        //pTask.Account_Name__c = 'Abc';
        pTask.Resource_Role__c ='Project Manager Analyst';
        pTask.pse__Status__c = 'Complete ';
        pTask.pse__Started__c = true;
        pTask.pse__Completed__c = true;
        update pTask;
        //Create Project task
        pse__Project_Task__c pTask1 = TestDataUtility.getProjectTask(false,proj.id);
        pTask1.pse__Estimated_Hours__c =20;
        pTask1.pse__Actual_Hours__c =10;
        insert pTask1;
        //pTask1.Account_Name__c = 'Abc';
        pTask1.Resource_Role__c ='Project Manager Analyst';
        update pTask1;
        pse__proj__c project = [Select Id, Planned_Cost_from_Labor__c, EAC_Cost_from_Labor__c From pse__Proj__c Where Id=:proj.id];
        System.assertEquals(4000, project.Planned_Cost_from_Labor__c);
        System.assertEquals(3000, project.EAC_Cost_from_Labor__c);
        //delete 
        list<pse__Project_Task__c> lstTask = new list<pse__Project_Task__c>();
        lstTask.add(pTask);
        lstTask.add(pTask1);
        delete  lstTask; 
        undelete lstTask;
        test.stopTest();
    }
}