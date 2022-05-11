@isTest
public class ExpenseReportTriggerHandlerTest {
    static testmethod void rollUpAmountOnProjectTest(){
        //Create User 
        User user2 = TestDataUtility.getUser('testexprep@dell.com');
        System.runAs(user2){
            //Create region
            pse__Region__c region = TestDataUtility.getRegion(True);
            //Create permission Control
            pse__Permission_Control__c pc = TestDataUtility.getPermissionControl(UserInfo.getUserId(),region.id,false);
            pc.pse__Staffing__c = true;
            insert pc;
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
            con.pse__Salesforce_User__c = user2.Id;
            con.Phone='1234567890';
            insert con;
            //Create Project
            pse__Proj__c proj = TestDataUtility.createProject(acc.id,region.id,True);
            //Create Assignment
            pse__Assignment__c asm = TestDataUtility.getAssignment(proj.id,con.id,0,True);
            //Create Budget
          pse__Budget__c bud =  TestDataUtility.getBudget(false,proj.Id);
            bud.pse__Effective_Date__c = date.today();
            bud.pse__Amount__c = 100;
            insert bud;
            //Insert Expense Report
            pse__Expense_Report__c expense =  TestDataUtility.getexpenseReport(false,proj.Id,con.Id,asm.id);
            expense.pse__Approved__c = false;
            expense.pse__Submitted__c = true;
            expense.pse__First_Expense_Date__c = date.today();
            insert expense;
            System.Test.startTest();
            //Update Expense Report
            expense.pse__Approved__c = true;
            expense.pse__Total_Billable_Amount__c = 100;
            update expense;
            pse__Budget__c bud1 = [Select Actual_Expenses__c From  pse__Budget__c Where Id=:bud.id];
            System.assertEquals(100, bud1.Actual_Expenses__c);
            pse__proj__c project = [Select EAC_Cost_from_Expenses__c, Actual_Expenses__c From pse__Proj__c Where Id=:proj.id];
            
             //Insert Expense Report
            pse__Expense_Report__c expense1 =  TestDataUtility.getexpenseReport(false,proj.Id,con.Id,asm.id);
            expense1.pse__Approved__c = false;
            expense1.pse__Submitted__c = true;
            expense1.pse__First_Expense_Date__c = date.today();
            insert expense1;
            //Update Expense Report
            expense1.pse__Approved__c = true;
            expense1.pse__Total_Billable_Amount__c = 100;
            Update expense1;
            pse__proj__c pro = [Select name,Actual_Expenses__c From pse__Proj__c Where Id=:proj.id];
            pse__Budget__c bud2 = [Select Actual_Expenses__c From  pse__Budget__c Where Id=:bud.id];
            System.assertEquals(200, bud2.Actual_Expenses__c);
            System.Test.stopTest();
        }
    }
}