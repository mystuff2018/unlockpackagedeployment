@isTest
public class BatchToPopulateCurrencyTest {
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
       // TestDataUtility.createDomainSettings(1,false, true);
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
    static testmethod void PopulateCurrencyFromRatecardTest(){
        User u1 = [Select id from User Limit 1];
        System.runAs(u1){
            Account acc = [Select id from Account Limit 1];
            Contact con = [Select id from Contact Limit 1];
            pse__Region__c region = [Select id from pse__Region__c Limit 1];
            //Create Project
            pse__Proj__c proj = TestDataUtility.createProject(acc.id,region.id,False);
            proj.pse__Project_Manager__c = con.id;
            proj.pse__Billing_Type__c = 'Time and Materials';
            insert proj;
            pse__Rate_Card__c rateCard = TestDataUtility.createRateCard(region.id,false,'Project Manager Analyst');
            rateCard.CurrencyIsoCode = 'BRL';
            insert rateCard;
            //Create Project task
            pse__Project_Task__c pTask = TestDataUtility.getProjectTask(false,proj.id);
            pTask.pse__Estimated_Hours__c =20;
            pTask.pse__Actual_Hours__c =10;
            pTask.Cost_Rate_Card__c = rateCard.id;
           // pTask.Account_Name__c = 'Abc';
            pTask.Resource_Role__c ='Project Manager Analyst';
            insert pTask;
            pse__Project_Task__c pTask2 = [ select id, Cost_Rate__c, Bill_Rate__c from pse__Project_Task__c limit 1 ];
            system.debug(pTask2.Cost_Rate__c);
            system.debug(pTask2.Bill_Rate__c);
            pTask.CurrencyIsoCode = 'USD';
            pTask.Cost_Rate__c = rateCard.pse__Average_Cost_Rate__c;
            pTask.Bill_Rate__c = rateCard.pse__Suggested_Bill_Rate__c;
            update pTask;  
            pse__Project_Task__c pTask3 = [ select id, Cost_Rate__c, Bill_Rate__c from pse__Project_Task__c limit 1 ];
            system.debug(pTask3.Cost_Rate__c);
            system.debug(pTask3.Bill_Rate__c);
            test.startTest();
            BatchToPopulateCurrency c = new BatchToPopulateCurrency();
           // Database.executeBatch(c);
            test.stopTest();
        }}
}