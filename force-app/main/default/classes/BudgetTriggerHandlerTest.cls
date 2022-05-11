@isTest
public class BudgetTriggerHandlerTest {
  static testmethod void rollUpAmountOnProjectTest(){
        
        //Create region
        pse__Region__c region = TestDataUtility.getRegion(True);
        //Create Account
        Account acc = TestDataUtility.createAccounts(1,True)[0];
         //Create Custom Domain
       // TestDataUtility.createDomainSettings(1,true, true);
         //Create Project
        pse__Proj__c proj = TestDataUtility.createProject(acc.id,region.id,True);
        //Create Budget
        pse__Budget__c bud =  TestDataUtility.getBudget(false,proj.Id);
        bud.pse__Type__c = 'Expense';
        bud.pse__Status__c = 'Approved';
        bud.Actual_Expenses__c = 2000;
        bud.pse__Amount__c = 1000;
        bud.pse__Billable__c = true;
        insert bud;
        pse__proj__c project = [SELECT EAC_Cost_from_Expenses__c,Planned_Expenses__c FROM pse__proj__c limit 1];
        System.assertEquals(project.EAC_Cost_from_Expenses__c, 2000);
        System.assertEquals(project.Planned_Expenses__c, 1000);
        Test.startTest();
        //Create Budget
        pse__Budget__c bud1 =  TestDataUtility.getBudget(false,proj.Id);
        bud1.pse__Type__c = 'Expense';
        bud1.pse__Status__c = 'Approved';
        bud1.Actual_Expenses__c = 2000;
        bud1.pse__Amount__c = 1000;
        bud1.pse__Billable__c = true;
        insert bud1;
    pse__proj__c project1 = [SELECT EAC_Cost_from_Expenses__c,Planned_Expenses__c FROM pse__proj__c limit 1];
        System.assertEquals(project1.EAC_Cost_from_Expenses__c, 4000);
        System.assertEquals(project1.Planned_Expenses__c, 2000); 
        delete bud1;
        pse__proj__c project2 = [SELECT EAC_Cost_from_Expenses__c,Planned_Expenses__c FROM pse__proj__c limit 1];
        System.assertEquals(project2.EAC_Cost_from_Expenses__c, 2000);
        System.assertEquals(project2.Planned_Expenses__c, 1000);
        Delete bud;
        
        pse__Budget__c budgetTest =  TestDataUtility.getBudget(false,proj.Id);
        budgetTest.pse__Type__c = 'Expense';
        budgetTest.pse__Status__c = 'Approved';
        budgetTest.Actual_Expenses__c = 2000;
        budgetTest.pse__Amount__c = 1000;
        budgetTest.pse__Billable__c = true;
        insert budgetTest;
        
        List <pse__Transaction__c> tr = [Select ID,pse__Amount__c from pse__Transaction__c where pse__Budget__c  = : budgetTest.Id and pse__Category__c ='Internal Budget' limit 1];
    System.assertEquals(tr.get(0).pse__Amount__c, 0);
        Test.stopTest();
    }
    
    
}