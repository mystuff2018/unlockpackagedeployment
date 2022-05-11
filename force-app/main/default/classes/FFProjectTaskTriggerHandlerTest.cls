@isTest
public class FFProjectTaskTriggerHandlerTest {
    @isTest
    static void shouldTestDmls(){

        //Create region
        pse__Region__c region = TestDataUtility.getRegion(True);
         //Create Account
        Account acc = TestDataUtility.createAccounts(1,True)[0];
         //Create Custom Domain
        //TestDataUtility.createDomainSettings(1,true, true);
         //Create Project
        pse__Proj__c proj = TestDataUtility.createProject(acc.id,region.id,True);
        
        List<pse__Project_Task__c> projectTaskList = new List<pse__Project_Task__c>();
        pse__Project_Task__c ptask =  TestDataUtility.getProjectTask(false,proj.id);
        //projectTaskList.add(pt);
        Test.startTest();
        
        Database.saveResult insertResults = Database.insert(ptask, false);
        System.assertEquals(insertResults.isSuccess(),true);

        ptask.Name = 'Test 2';
        Database.saveResult updateResults = Database.update(ptask, false);
        System.assertEquals(updateResults.isSuccess(),true);

        Database.deleteResult deleteResults = Database.delete(ptask, false);
        System.assertEquals(deleteResults.isSuccess(), true);
        pse__Project_Task__c ptask2 =  TestDataUtility.getProjectTask(true,proj.id);
		delete ptask2;
        undelete ptask2;
        Test.stopTest();
    }

}