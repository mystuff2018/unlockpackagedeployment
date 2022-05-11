@isTest
public class ExpenseTriggerHandlerTest {
     static testmethod void test(){
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){
        	//Create region
        	pse__Region__c region = TestDataUtility.getRegion(True);
        
        	//Create Account
        	Account acc = TestDataUtility.createAccounts(1,True)[0];
        
        	//Create Custom Domain
        	//TestDataUtility.createDomainSettings(1,true, true);
        	//Create Resource
			Contact con = TestDataUtility.createContacts(1,acc.id,false,True)[0];
        	con.pse__Salesforce_User__c = loginUser[0].Id;
        	con.pse__Region__c = region.id;
        	insert con;
            
            pse__Permission_Control__c pc = TestDataUtility.getPermissionControl(UserInfo.getUserId(),region.id,false);
       		pc.pse__Staffing__c = true;
        	insert pc;
            
        	Test.startTest();
        		//Create Project
        		pse__Proj__c proj = TestDataUtility.createProject(acc.id,region.id,True);
            
            	Request__c req =  TestDataUtility.getRequest(proj.Id , true);
        		//create schedule
        		pse__Schedule__c sc = new pse__Schedule__c();
        		sc.pse__Start_Date__c = date.today();
        		sc.pse__End_Date__c = date.today()+30;
        		sc.pse__Monday_Hours__c = 0;
        		sc.pse__Tuesday_Hours__c = 0;
        		sc.pse__Wednesday_Hours__c = 0;
        		sc.pse__Thursday_Hours__c = 0;
        		sc.pse__Friday_Hours__c = 0;
        		sc.pse__Saturday_Hours__c = 0;
        		sc.pse__Sunday_Hours__c = 0;
        		insert sc;
            	
        		//Create Assignment Record
				pse__Assignment__c assign =	TestDataUtility.getAssignment(proj.id,con.id,0,false);
        		assign.pse__Schedule__c = sc.id;
        		assign.pse__Resource__c = con.id;
        		assign.pse__Is_Billable__c = true;
            	assign.PO_Request__c = req.Id;
        		insert assign;
            
            pse__Project_Methodology__c projMeth = new pse__Project_Methodology__c ();
            projMeth.Name = 'Test';
                projMeth.pse__Project__c = proj.Id;
                insert projMeth;
            
            pse__Expense__c expense = new pse__Expense__c();
            expense.pse__Resource__c  =  con.Id;
            expense.pse__Amount__c = 30.00;
            expense.pse__Type__c = 'Taxi';
            expense.pse__Expense_Date__c = Date.today() - 1;
            expense.pse__Assignment__c = assign.Id;
            expense.pse__Project__c = proj.Id;
            expense.pse__Project_Methodology__c = projMeth.Id;
            expense.pse__Status__c = 'Draft';
			insert expense;
            expense.pse__Status__c = 'Approved';
      		update expense;
        	Test.stopTest();
       // System.assertEquals(1,[SELECT count() From pse__Miscellaneous_Adjustment__c]);
          
    	}
    }

}