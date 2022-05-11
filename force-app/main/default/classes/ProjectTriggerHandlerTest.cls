@isTest
public class ProjectTriggerHandlerTest {
    @testSetup static void setup() {
        user u1 = TestDataUtility.getUser('cxyz@xyz.com');
        //Create Custom Domain
        //TestDataUtility.createDomainSettings(1,false, true);
        //Create region
        pse__Region__c region = TestDataUtility.getRegion(True);
        //Create Account
        Account acc = TestDataUtility.createAccounts(1,True)[0];
        //create work calendar
        pse__Work_Calendar__c wc = TestDataUtility.createWorkCalender(true);
        //Create Resource
        Contact con = TestDataUtility.createContacts(1,acc.id,false,true)[0];
        con.pse__Salesforce_User__c = u1.id;
        con.pse__Region__c = region.id;
        con.pse__Work_Calendar__c = wc.id;
        con.pse__Resource_Role__c = 'Project Manager Analyst';
        con.pse__Is_Resource__c = true;
        insert con;
    }
    
    @isTest static void testPopulateNextBillingDate7(){
        //Create Custom Data
       Billing_Request_T_M_Configration__c p = new Billing_Request_T_M_Configration__c();
       p.Batch_Running_Hours__c = datetime.now().hour();
       p.Batch_Running_Minutes__c = datetime.now().minute();
       insert p;
        pse__Region__c region = [Select id from pse__Region__c Limit 1];
        region.name = 'Global';
        update region;
        Account acc = [Select id from Account Limit 1];
        Contact con = [Select id from Contact Limit 1];
        //Create Project
        list<pse__Proj__c> lstProj = new list<pse__Proj__c>();
        pse__Proj__c proj = TestDataUtility.createProject(acc.id,region.id,false);
        proj.pse__Project_Manager__c = con.id;
        proj.pse__Internal_Costs__c = 12000;
        proj.pse__Project_Phase__c = 'Setup';
        proj.Deal_Type__c = 'Custom';
        proj.pse__Expense_Costs__c = 200;
        proj.Next_Billing_Date__c = System.today();
        proj.BUID__c = '1121';
        proj.Local_Channel__c = '2212';
        proj.Association_Flag__c = true;
        proj.pse__Is_Billable__c = true;
        lstProj.add(proj);
        pse__Proj__c proj2 = TestDataUtility.createProject(acc.id,region.id,false);
        proj2.pse__Project_Manager__c = con.id;
        proj2.pse__Internal_Costs__c = 12000;
        proj2.pse__Project_Phase__c = 'Setup';
        proj2.Deal_Type__c = 'Custom';
        proj2.pse__Expense_Costs__c = 200;
        proj2.Billing_Cadence__c = 'Monthly';
        proj2.Billing_Period__c = '25';
        proj2.Next_Billing_Date__c = System.today();
        proj2.BUID__c = '1121';
        proj2.Local_Channel__c = '2212';
        proj2.Association_Flag__c = true;
        proj2.pse__Is_Billable__c = true;
        lstProj.add(proj2);
        pse__Proj__c proj3 = TestDataUtility.createProject(acc.id,region.id,false);
        proj3.pse__Project_Manager__c = con.id;
        proj3.pse__Internal_Costs__c = 12000;
        proj3.pse__Project_Phase__c = 'Setup';
        proj3.Deal_Type__c = 'Custom';
        proj3.pse__Expense_Costs__c = 200;
        proj3.Billing_Cadence__c = 'Monthly';
        proj3.Billing_Period__c = '6';
        proj3.Next_Billing_Date__c = System.today();
        proj3.BUID__c = '1121';
        proj3.Local_Channel__c = '2212';
        proj3.Association_Flag__c = true;
        proj3.pse__Is_Billable__c = true;
        lstProj.add(proj3);
        insert lstProj;
        Test.startTest();
        for(pse__Proj__c p1: lstProj){
            p1.Association_Flag__c = false;
        	p1.pse__Project_Phase__c = 'Initiate';
        }
        update lstProj;
        pse__proj__c project = [Select Next_Billing_Date__c From pse__Proj__c Where Id=:proj.id];
        //System.assertEquals(date.ValueOf('2020-12-04'), project.Next_Billing_Date__c);
        System.debug(project.Next_Billing_Date__c);
        test.stopTest();
      }
    
    @isTest static void createPmNotificationTask(){
        pse__Region__c region = [Select id from pse__Region__c Limit 1];
        region.name = 'Global';
        update region;
        Account acc = [Select id from Account Limit 1];
        User user1 =  [Select id from User Limit 1];
        //update Resource
        Contact con = [Select id from Contact Limit 1];
        //Create Project
        TriggerHandler.bypass(FFProjectTriggerHandler.class.getName());
        pse__Proj__c proj = TestDataUtility.createProject(acc.id,region.id,false);
        proj.pse__Project_Manager__c = con.id;
        proj.pse__Project_Phase__c = 'Setup';
        proj.Deal_Type__c = 'Custom';
        proj.BUID__c = '1121';
        proj.Local_Channel__c = '2212';
        insert proj;
        pse__proj__c proj1 = TestDataUtility.createproject(acc.id,region.id,False);
        proj1.pse__project_Manager__c = con.id;
        proj1.pse__project_Phase__c = 'Setup';
        proj1.pse__Billing_Type__c = 'Time and Materials';
        proj1.Deal_Type__c = 'Custom';
        proj1.BUID__c = '1121';
        proj1.Local_Channel__c = '2212';
        insert proj1;
        Test.startTest();
        //Create Project task
        pse__Project_Task__c pTask = TestDataUtility.getProjectTask(false,proj.id);
        pTask.Name ='PM Activities';
        pTask.OwnerID = user1.id;
        pTask.pse__Project__c = proj.id;
        insert pTask;
        pse__Project_Task__c pTask1 = TestDataUtility.getProjectTask(false,proj.id);
        pTask1.Name ='PM Activities';
        pTask1.OwnerID = user1.id;
        pTask1.pse__Project__c = proj.id;
        insert pTask1;
        TriggerHandler.clearbypass(FFProjectTriggerHandler.class.getName());
        pse__Proj__c upadedProj = [Select ID, pse__Project_Phase__c from pse__Proj__c where id =: proj.ID];
        system.debug('upadedProj:::'+upadedProj.pse__Project_Phase__c);
        //update project
        proj.pse__Project_Phase__c = 'Initiate';
        proj.Billing_Cadence__c = 'Weekly';
        proj.Billing_Period__c = 'Tuesday';
        proj.Next_Billing_Date__c = System.today().adddays(30);
        update proj;
        proj1.pse__project_Phase__c = 'Initiate';
        //proj.Billing_Cadence__c = 'Weekly';
        //proj.Billing_Period__c = 'Tuesday';
        update proj1;
        Test.stopTest();
    }
    
    @isTest static void testPopulateNextBillingDate76(){
       //Create Custom Data
       Billing_Request_T_M_Configration__c p = new Billing_Request_T_M_Configration__c();
       p.Batch_Running_Hours__c = 11;
       p.Batch_Running_Minutes__c = 00;
       p.fourth_Quarter_Date__c = Date.newInstance(Date.today().year(), 12, 31);
       p.Third_Quarter_Date__c = Date.newInstance(Date.today().year(), 9, 30);
       p.Secound_Quarter_Date__c = Date.newInstance(Date.today().year(), 6, 30);
       p.First_Quarter__c = Date.newInstance(Date.today().year(), 3, 31);
       insert p;
      
        pse__Region__c region = [Select id from pse__Region__c Limit 1];
        region.name = 'Global';
        update region;
        Account acc = [Select id from Account Limit 1];
        Contact con = [Select id from Contact Limit 1];
     
        
         //Create Project
        pse__Proj__c proj = TestDataUtility.createProject(acc.id,region.id,False);
        proj.pse__Project_Manager__c = con.id;
        proj.pse__Internal_Costs__c = 12000;
        proj.pse__Project_Phase__c = 'Setup';
        proj.pse__Billing_Type__c = 'Time and Materials';
        proj.Actual_Expenses__c = 100;
        proj.Billing_Cadence__c = 'Monthly';
        proj.Billing_Period__c = string.valueof(Date.today().day());
        proj.BUID__c = '1121';
        proj.Local_Channel__c = '2212';
        proj.Association_Flag__c = true;
        proj.pse__Is_Billable__c = true;
        insert proj;
        proj.Association_Flag__c = false;
        proj.pse__Project_Phase__c = 'Initiate';
        update proj;
         
         Test.startTest();
        pse__Proj__c proj1 = TestDataUtility.createProject(acc.id,region.id,False);
        proj1.pse__Project_Manager__c = con.id;
        proj1.pse__Internal_Costs__c = 12000;
        proj1.pse__Project_Phase__c = 'Setup';
        proj1.pse__Billing_Type__c = 'Time and Materials';
        proj1.Deal_Type__c = 'Custom';
        proj1.Actual_Expenses__c = 100;
        proj1.Billing_Cadence__c = 'Monthly';
        proj1.Billing_Period__c = '1';
        proj1.BUID__c = '1121';
        proj1.Local_Channel__c = '2212';
        proj1.Association_Flag__c = true;
        proj.pse__Is_Billable__c = true;
        insert proj1;
        proj1.Association_Flag__c = false;
        proj1.pse__Project_Phase__c = 'Initiate';
        update proj1;

         //system.assertEquals(10,[select count() from pse__Project_Task__c where pse__Project__c =: proj.id]);
        Test.stopTest();
    }
    @isTest static void testPopulateNextBillingDate19(){
       //Create Custom Data
       Billing_Request_T_M_Configration__c p = new Billing_Request_T_M_Configration__c();
       p.Batch_Running_Hours__c = 11;
       p.Batch_Running_Minutes__c = 00;
       p.fourth_Quarter_Date__c = null;
       p.Third_Quarter_Date__c = Date.newInstance(Date.today().year(), 9, 30);
       p.Secound_Quarter_Date__c = Date.newInstance(Date.today().year(), 6, 30);
       p.First_Quarter__c = Date.newInstance(Date.today().year(), 3, 31);
       insert p;
        pse__Region__c region = [Select id from pse__Region__c Limit 1];
        region.name = 'Global';
        update region;
        Account acc = [Select id from Account Limit 1];
        Contact con = [Select id from Contact Limit 1];
        //Create Project
        
        pse__Proj__c proj = TestDataUtility.createProject(acc.id,region.id,False);
        proj.pse__Project_Manager__c = con.id;
        proj.pse__Internal_Costs__c = 26000;
        proj.pse__Project_Phase__c = 'Setup';
        proj.pse__Billing_Type__c = 'Time and Materials';
        proj.Deal_Type__c = 'Custom';
        proj.pse__Expense_Costs__c = 200;
        proj.Billing_Cadence__c = 'Quarterly';
        proj.Billing_Period__c = '1';
        proj.BUID__c = '1121';
        proj.Local_Channel__c = '2212';
        proj.Association_Flag__c = true;
        proj.pse__Is_Billable__c = true;
        insert proj;
        Test.startTest();
        proj.Association_Flag__c = false;
       proj.pse__Project_Phase__c = 'Initiate';
        update proj;
        
        //Create Project
        pse__Proj__c proj1 = TestDataUtility.createProject(acc.id,region.id,False);
        proj1.pse__Project_Manager__c = con.id;
        proj1.pse__Internal_Costs__c = 26000;
        proj1.pse__Project_Phase__c = 'Setup';
        proj1.pse__Billing_Type__c = 'Time and Materials';
        proj1.Deal_Type__c = 'Custom';
        proj1.pse__Expense_Costs__c = 200;
        proj1.Billing_Cadence__c = 'Quarterly';
        proj1.Billing_Period__c = '2';
        proj1.BUID__c = '1121';
        proj1.Local_Channel__c = '2212';
        proj1.Association_Flag__c = true;
        proj1.pse__Is_Billable__c = true;
        insert proj1;
        proj1.Association_Flag__c = false;
        proj1.pse__Project_Phase__c = 'Initiate';
        update proj1;
        //system.assertEquals(5,[select count() from pse__Project_Task__c where pse__Project__c =: proj.id]);
        Test.stopTest();
    }
    @isTest static void testPopulateNextBillingDate26(){
          //Create Custom Data
       Billing_Request_T_M_Configration__c p = new Billing_Request_T_M_Configration__c();
       p.Batch_Running_Hours__c = 11;
       p.Batch_Running_Minutes__c = 00;
      p.fourth_Quarter_Date__c = Date.newInstance(Date.today().year(), 12, 31);
       p.Third_Quarter_Date__c = Date.newInstance(Date.today().year(), 9, 30);
       p.Secound_Quarter_Date__c = null;
       p.First_Quarter__c = Date.newInstance(Date.today().year(), 3, 31);
       insert p;
        pse__Region__c region = [Select id from pse__Region__c Limit 1];
        region.name = 'Global';
        update region;
        Account acc = [Select id from Account Limit 1];
        Contact con = [Select id from Contact Limit 1];
        //Create Project
        pse__Proj__c proj = TestDataUtility.createProject(acc.id,region.id,False);
        proj.pse__Project_Manager__c = con.id;
        proj.pse__Internal_Costs__c = 510000;
        proj.pse__Project_Phase__c = 'Setup';
        proj.pse__Billing_Type__c = 'Time and Materials';
        proj.Deal_Type__c = 'Custom';
        proj.pse__Expense_Costs__c = 200;
        proj.Billing_Cadence__c = 'Quarterly';
        proj.Billing_Period__c = '3';
        proj.BUID__c = '1121';
        proj.Local_Channel__c = '2212';
        proj.Association_Flag__c = true;
        proj.pse__Is_Billable__c = true;
        insert proj;
        Test.startTest();
        proj.Association_Flag__c = false;
        proj.pse__Project_Phase__c = 'Initiate';
        update proj;
        Test.stopTest();
        //system.assertEquals(5,[select count() from pse__Project_Task__c where pse__Project__c =: proj.id]);

    } 
    @isTest static void testPopulateNextBillingDate38(){
            //Create Custom Data
       Billing_Request_T_M_Configration__c p = new Billing_Request_T_M_Configration__c();
       p.Batch_Running_Hours__c = datetime.now().hour();
       p.Batch_Running_Minutes__c = datetime.now().minute();
       p.fourth_Quarter_Date__c = Date.newInstance(Date.today().year(), 12, 31);
       p.Third_Quarter_Date__c = Date.newInstance(Date.today().year(), 9, 30);
       p.Secound_Quarter_Date__c = Date.newInstance(Date.today().year(), 6, 30);
       p.First_Quarter__c = null;
       insert p;
        pse__Region__c region = [Select id from pse__Region__c Limit 1];
        region.name = 'Global';
        update region;
        Account acc = [Select id from Account Limit 1];
        Contact con = [Select id from Contact Limit 1];
        //Create Project
        pse__Proj__c proj = TestDataUtility.createProject(acc.id,region.id,False);
        proj.pse__Project_Manager__c = con.id;
        proj.pse__Internal_Costs__c = 510000;
        proj.pse__Project_Phase__c = 'Setup';
        proj.pse__Billing_Type__c = 'Time and Materials';
        //proj.Deal_Type__c = 'Custom';
        proj.pse__Expense_Costs__c = 200;
        proj.Billing_Cadence__c = 'Monthly';
        proj.Billing_Period__c = '12';
        proj.BUID__c = '1121';
        proj.Local_Channel__c = '2212';
        proj.Association_Flag__c = true;
        proj.pse__Is_Billable__c = true;
        insert proj;
        Test.startTest();
        proj.Association_Flag__c = false;
        proj.pse__Project_Phase__c = 'Initiate';
        update proj;
        
        //Create Project
        pse__Proj__c proj1 = TestDataUtility.createProject(acc.id,region.id,False);
        proj1.pse__Project_Manager__c = con.id;
        proj1.pse__Internal_Costs__c = 510000;
        proj1.pse__Project_Phase__c = 'Setup';
        proj1.pse__Billing_Type__c = 'Time and Materials';
        proj1.Actual_Expenses__c= 100;
        proj1.Billing_Cadence__c = 'Quarterly';
        proj1.Billing_Period__c = '4';
        proj1.BUID__c = '1121';
        proj1.Local_Channel__c = '2212';
        proj1.Association_Flag__c = true;
        proj1.pse__Is_Billable__c = true;
        insert proj1;
        proj1.Association_Flag__c = false;
        proj1.pse__Project_Phase__c = 'Initiate';
        update proj1;
        //system.assertEquals(5,[select count() from pse__Project_Task__c where pse__Project__c =: proj.id]);
        Test.stopTest();
    }
    
    @isTest static void testPopulateNextBillingDate49(){
        //Create Custom Data
       Billing_Request_T_M_Configration__c p = new Billing_Request_T_M_Configration__c();
       p.Batch_Running_Hours__c = 11;
       p.Batch_Running_Minutes__c = 00;
       p.fourth_Quarter_Date__c = null;
       p.Third_Quarter_Date__c = null;
       p.Secound_Quarter_Date__c = null;
       p.First_Quarter__c = null;
       insert p;
        pse__Region__c region = [Select id from pse__Region__c Limit 1];
        region.name = 'Global';
        update region;
        Account acc = [Select id from Account Limit 1];
        Contact con = [Select id from Contact Limit 1];
        //Create Project
        pse__Proj__c proj = TestDataUtility.createProject(acc.id,region.id,false);
        proj.pse__Project_Manager__c = con.id;
        proj.pse__Internal_Costs__c = 12000;
        proj.pse__Project_Phase__c = 'Setup';
        proj.pse__Billing_Type__c = 'Time and Materials';
        proj.Actual_Expenses__c= 100;
        proj.Billing_Cadence__c = 'Weekly';
        proj.Billing_Period__c = 'Wednesday';
        proj.BUID__c = '1121';
        proj.Local_Channel__c = '2212';
        proj.Association_Flag__c = true;
        proj.pse__Is_Billable__c = true;
        insert proj;
        proj.Association_Flag__c = false;
        proj.pse__Project_Phase__c = 'Initiate';
        update proj;
        pse__proj__c project = [Select Next_Billing_Date__c From pse__Proj__c Where Id=:proj.id];
        //System.assertEquals(date.ValueOf('2020-12-09'), project.Next_Billing_Date__c);
        System.debug(project.Next_Billing_Date__c);
    }
    @isTest static void testPopulateNextBillingDate57(){
        //Create Custom Data
       Billing_Request_T_M_Configration__c p = new Billing_Request_T_M_Configration__c();
       p.Batch_Running_Hours__c = datetime.now().hour();
       p.Batch_Running_Minutes__c = datetime.now().minute();
       p.fourth_Quarter_Date__c = null;
       p.Third_Quarter_Date__c = null;
       p.Secound_Quarter_Date__c = null;
       p.First_Quarter__c = null;
       insert p;
        pse__Region__c region = [Select id from pse__Region__c Limit 1];
        region.name = 'Global';
        update region;
        Account acc = [Select id from Account Limit 1];
        Contact con = [Select id from Contact Limit 1];
        //Create Project
        pse__Proj__c proj = TestDataUtility.createProject(acc.id,region.id,false);
        proj.pse__Project_Manager__c = con.id;
        proj.pse__Internal_Costs__c = 12000;
        proj.pse__Project_Phase__c = 'Setup';
        proj.Deal_Type__c = 'Custom';
        proj.pse__Expense_Costs__c = 200;
        proj.Billing_Cadence__c = 'Weekly';
        proj.Billing_Period__c = 'Thursday';
        proj.BUID__c = '1121';
        proj.Local_Channel__c = '2212';
        proj.Association_Flag__c = true;
       proj.pse__Is_Billable__c = true;
        insert proj;
        proj.Association_Flag__c = false;
        proj.pse__Project_Phase__c = 'Initiate';
        update proj;
        pse__proj__c project = [Select Next_Billing_Date__c From pse__Proj__c Where Id=:proj.id];
       // System.assertEquals(date.ValueOf('2020-12-03'), project.Next_Billing_Date__c);
        System.debug(project.Next_Billing_Date__c);
    }
      @isTest static void testPopulateNextBillingDate62(){
        //Create Custom Data
       Billing_Request_T_M_Configration__c p = new Billing_Request_T_M_Configration__c();
       p.Batch_Running_Hours__c = null;
       p.Batch_Running_Minutes__c = null;
       insert p;
        pse__Region__c region = [Select id from pse__Region__c Limit 1];
        region.name = 'Global';
        update region;
        Account acc = [Select id from Account Limit 1];
        Contact con = [Select id from Contact Limit 1];
        //Create Project
        list<pse__Proj__c> lstProj = new list<pse__Proj__c>();
        pse__Proj__c proj = TestDataUtility.createProject(acc.id,region.id,false);
        proj.pse__Project_Manager__c = con.id;
        proj.pse__Internal_Costs__c = 12000;
        proj.pse__Project_Phase__c = 'Setup';
        proj.Deal_Type__c = 'Custom';
        proj.pse__Expense_Costs__c = 200;
        proj.Billing_Cadence__c = 'Weekly';
        proj.Billing_Period__c = 'Friday';
        proj.Next_Billing_Date__c = System.today().addDays(1);
        proj.BUID__c = '1121';
        proj.Local_Channel__c = '2212';
        proj.Association_Flag__c = true;
        proj.pse__Is_Billable__c = true;
        lstProj.add(proj);
        
        pse__Proj__c proj2 = TestDataUtility.createProject(acc.id,region.id,false);
        proj2.pse__Project_Manager__c = con.id;
        proj2.pse__Internal_Costs__c = 12000;
        proj2.pse__Project_Phase__c = 'Setup';
        proj2.Deal_Type__c = 'Custom';
        proj2.pse__Expense_Costs__c = 200;
        proj2.Billing_Cadence__c = 'Weekly';
        proj2.Billing_Period__c = 'Monday';
        proj2.Next_Billing_Date__c = System.today().addDays(1);
        proj2.BUID__c = '1121';
        proj2.Local_Channel__c = '2212';
        proj2.Association_Flag__c = true;
        proj2.pse__Is_Billable__c = true;
        lstProj.add(proj2);
        pse__Proj__c proj3 = TestDataUtility.createProject(acc.id,region.id,false);
        proj3.pse__Project_Manager__c = con.id;
        proj3.pse__Internal_Costs__c = 12000;
        proj3.pse__Project_Phase__c = 'Setup';
        proj3.Deal_Type__c = 'Custom';
        proj3.pse__Expense_Costs__c = 200;
        proj3.Billing_Cadence__c = 'Weekly';
        proj3.Billing_Period__c = 'Tuesday';
        proj3.Next_Billing_Date__c = System.today().addDays(1);
        proj3.BUID__c = '1121';
        proj3.Local_Channel__c = '2212';
        proj3.Association_Flag__c = true;
        proj3.pse__Is_Billable__c = true;
        lstProj.add(proj3);
        insert lstProj;
        Test.startTest();
        for(pse__Proj__c p1: lstProj){
            p1.Association_Flag__c = false;
              p1.pse__Project_Phase__c = 'Initiate';
        }
        update lstProj;
        pse__proj__c project = [Select Next_Billing_Date__c From pse__Proj__c Where Id=:proj.id];
        //System.assertEquals(date.ValueOf('2020-12-04'), project.Next_Billing_Date__c);
        System.debug(project.Next_Billing_Date__c);
          Test.stopTest();
      }
}