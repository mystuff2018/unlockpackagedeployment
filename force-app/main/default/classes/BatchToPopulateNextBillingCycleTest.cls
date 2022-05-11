@isTest
public class BatchToPopulateNextBillingCycleTest {
     @testSetup static void setup() {
        user u1 = TestDataUtility.getUser('cxy121z@xyz.com');
        //Create Custom Data
       Billing_Request_T_M_Configration__c p = new Billing_Request_T_M_Configration__c();
       p.Batch_Running_Hours__c = 11;
       p.Batch_Running_Minutes__c = 00;
       p.fourth_Quarter_Date__c = Date.newInstance(Date.today().year(), 12, 31);
       p.Third_Quarter_Date__c = Date.newInstance(Date.today().year(), 9, 30);
       p.Secound_Quarter_Date__c = Date.newInstance(Date.today().year(), 6, 30);
       p.First_Quarter__c = Date.newInstance(Date.today().year(), 3, 31);
       insert p;
        //Create Custom Domain
        //TestDataUtility.createDomainSettings(1,false, true);
        //Create region
        pse__Region__c region = TestDataUtility.getRegion(True);
        //Create Account
        Account acc = TestDataUtility.createAccounts(1,true)[0];
        //Create Resource
        Contact con = TestDataUtility.createContacts(1,acc.id,false,true)[0];
        con.pse__Salesforce_User__c = u1.id;
        con.pse__Resource_Role__c = 'Project Manager Analyst';
        con.pse__Is_Resource__c = true;
        insert con;
        
    }
    
    static testmethod void PopulateNextBillingDate1(){
        pse__Region__c region = [Select id from pse__Region__c Limit 1];
        Account acc = [Select id from Account Limit 1];
        Contact con = [Select id from Contact Limit 1];
        //Create Project
        pse__Proj__c proj = TestDataUtility.createProject(acc.id,region.id,False);
        proj.pse__Project_Manager__c = con.id;
        proj.pse__Internal_Costs__c = 12000;
        proj.pse__Project_Phase__c = 'Setup';
        proj.pse__Billing_Type__c = 'Time and Materials';
        proj.Actual_Expenses__c = 100;
        proj.Billing_Cadence__c = 'Weekly';
        proj.Billing_Period__c = 'Monday';
        proj.BUID__c = '1121';
        proj.Local_Channel__c = '2212';
        proj.Association_Flag__c = true;
        proj.Next_Billing_Date__c = System.today();
        proj.pse__Is_Billable__c = true;
        insert proj;
        test.startTest();
        BatchToPopulateNextBillingCycle c = new BatchToPopulateNextBillingCycle();
        Database.executeBatch(c);
        test.stopTest();
        pse__Proj__c proj1 = [Select Next_Billing_Date__c from pse__Proj__c where Id=:proj.id];
        System.assertEquals(proj.Next_Billing_Date__c.addDays(7), proj1.Next_Billing_Date__c);
        
    }
    static testmethod void PopulateNextBillingDate2(){
        pse__Region__c region = [Select id from pse__Region__c Limit 1];
        Account acc = [Select id from Account Limit 1];
        Contact con = [Select id from Contact Limit 1];
        //Create Project
        pse__Proj__c proj = TestDataUtility.createProject(acc.id,region.id,False);
        proj.pse__Project_Manager__c = con.id;
        proj.pse__Internal_Costs__c = 12000;
        proj.pse__Project_Phase__c = 'Setup';
        proj.Deal_Type__c = 'Custom';
        proj.pse__Expense_Costs__c = 200;
        proj.Billing_Cadence__c = 'Monthly';
        proj.Billing_Period__c = '16';
        proj.BUID__c = '1121';
        proj.Local_Channel__c = '2212';
        proj.Association_Flag__c = true;
        proj.Next_Billing_Date__c = System.today();
        proj.pse__Is_Billable__c = true;
        insert proj;
        test.startTest();
        BatchToPopulateNextBillingCycle c = new BatchToPopulateNextBillingCycle();
        Database.executeBatch(c);
        test.stopTest();
        pse__Proj__c proj1 = [Select Next_Billing_Date__c from pse__Proj__c where Id=:proj.id];
        System.assertEquals(proj.Next_Billing_Date__c.addMonths(1), proj1.Next_Billing_Date__c);
        
    }
    static testmethod void PopulateNextBillingDate3(){
        pse__Region__c region = [Select id from pse__Region__c Limit 1];
        Account acc = [Select id from Account Limit 1];
        Contact con = [Select id from Contact Limit 1];
        //Create Project
        pse__Proj__c proj = TestDataUtility.createProject(acc.id,region.id,False);
        proj.pse__Project_Manager__c = con.id;
        proj.pse__Internal_Costs__c = 12000;
        proj.pse__Project_Phase__c = 'Setup';
        proj.Deal_Type__c = 'Custom';
        proj.Actual_Expenses__c = 100;
        proj.Billing_Cadence__c = 'Quarterly';
        proj.Billing_Period__c = '4';
        proj.BUID__c = '1121';
        proj.Local_Channel__c = '2212';
        proj.Association_Flag__c = true;
        proj.Next_Billing_Date__c = System.today();
        proj.pse__Is_Billable__c = true;
        insert proj;
        test.startTest();
        BatchToPopulateNextBillingCycle c = new BatchToPopulateNextBillingCycle();
        Database.executeBatch(c);
        test.stopTest();
        pse__Proj__c proj1 = [Select Next_Billing_Date__c from pse__Proj__c where Id=:proj.id];
        System.assertEquals(proj.Next_Billing_Date__c.addMonths(3), proj1.Next_Billing_Date__c);
    }
    static testmethod void testSchedule() {
     Test.StartTest();
     BatchToPopulateNextBillingCycle sh1 = new BatchToPopulateNextBillingCycle();
     String sch = '0 0 23 * * ?';
     system.schedule('Test BatchToPopulateNextBillingCycle', sch, sh1);
     Test.stopTest();
} 
    static testmethod void ProjectIDWithPMActivityTask(){
        User u1 = [Select Id from User where FBE_Integration_User__c = true];
        System.runAs(u1){
        Account acc = [Select id from Account Limit 1];
        Contact con = [Select id from Contact Limit 1];
        pse__Region__c region = [Select id from pse__Region__c Limit 1];
        //Create Project
        
        pse__Proj__c proj = TestDataUtility.createProject(acc.id,region.id,False);
        proj.pse__Project_Manager__c = con.id;
        proj.Billing_Cadence__c = 'Monthly';
        proj.pse__Billing_Type__c = 'Time and Materials';
        proj.Actual_Expenses__c = 100;
        proj.Billing_Period__c = '13';
        proj.Next_Billing_Date__c = System.today();
        proj.pse__Is_Active__c = true;
        proj.pse__Is_Billable__c = true;
        proj.Association_Flag__c = true;
        proj.BUID__c = 'ABLHJDLw5';
        proj.Local_Channel__c = 'sadfs3ra';
        insert proj;
        //Create Project task
            pse__Project_Task__c pTask = TestDataUtility.getProjectTask(false,proj.id);
            pTask.Name ='PM Activities';
            pTask.OwnerID = u1.id;
            insert pTask;
            TriggerHandler.clearbypass(FFProjectTriggerHandler.class.getName());
            pse__Project_Task__c ptask2 = [Select Id from pse__Project_Task__c limit 1];
           System.debug(ptask2);
           proj.Association_Flag__c = false;
           update proj;
        test.startTest();
        BatchToPopulateNextBillingCycle c = new BatchToPopulateNextBillingCycle();
        Database.executeBatch(c);
        test.stopTest();
        pse__Proj__c proj1 = [Select Next_Billing_Date__c from pse__Proj__c where Id=:proj.id];
        System.assertEquals(proj.Next_Billing_Date__c.addMonths(1), proj1.Next_Billing_Date__c);
    }
    }
}