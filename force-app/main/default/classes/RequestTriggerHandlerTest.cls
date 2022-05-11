@isTest
public class RequestTriggerHandlerTest {
	    static testmethod void rollUpAmountOnProjectTest(){
        //Create User 
        User user1 = FBE_UtilityFactory_Test.getIntegrationUser();
        System.runAs(user1){
        //Create region
        pse__Region__c region = TestDataUtility.getRegion(True);
         //Create Account
        Account acc = TestDataUtility.createAccounts(1,True)[0];
         //Create Custom Domain
        //TestDataUtility.createDomainSettings(1,true, true);
         //Create Project
        pse__Proj__c proj = TestDataUtility.createProject(acc.id,region.id,True);
            pse__Proj__c pr = new pse__Proj__c();
            pr.id = proj.id;
            pr.EAC_Cost_from_POs__c = 100;
            pr.Planned_Cost_from_POs__c = 100;
            System.debug('@@17 ' +proj.EAC_Cost_from_POs__c);
            update pr;
            System.debug('@@21 ' + pr);
            //create Request
            Request__c req = TestDataUtility.getRequest(proj.Id , false);
            req.RecordTypeId = Schema.SObjectType.Request__c.getRecordTypeInfosByName().get('PO/DO - New / Change').getRecordTypeId();
            insert req;
            //create PO Expense Line
            PO_Expense_Line__c po = TestDataUtility.getPoExpenseLine(false,req.Id);
            po.Amount__c = 100;
            insert po;
            pse__proj__c project = [Select EAC_Cost_from_POs__c,Planned_Cost_from_POs__c From pse__proj__c Where id = : proj.id];
            //system.assertEquals(0, project.EAC_Cost_from_POs__c);
            //system.assertEquals(0, project.Planned_Cost_from_POs__c);
            //create Request
            Request__c req1 = TestDataUtility.getRequest(proj.Id , false);
            req1.RecordTypeId = Schema.SObjectType.Request__c.getRecordTypeInfosByName().get('PO/DO - New / Change').getRecordTypeId();
            insert req1;
            //create PO Expense Line
            PO_Labor_Line__c pos = TestDataUtility.getPoLabourLine(false,req.Id);
            pos.Amount__c = 100;
            insert pos;
            pse__proj__c project1 = [Select EAC_Cost_from_POs__c,Planned_Cost_from_POs__c From pse__proj__c Where id = : proj.id];
            /*system.assertEquals(200, project1.EAC_Cost_from_POs__c);
            system.assertEquals(200, project1.Planned_Cost_from_POs__c);*/
            delete req1;
            pse__proj__c project2 = [Select EAC_Cost_from_POs__c,Planned_Cost_from_POs__c From pse__proj__c Where id = : proj.id];
           /* system.assertEquals(200, project2.EAC_Cost_from_POs__c);
            system.assertEquals(200, project2.Planned_Cost_from_POs__c);*/
            list<Request__c> reqLst = [select id from Request__c];
            delete reqLst;
            pse__proj__c project3 = [Select EAC_Cost_from_POs__c,Planned_Cost_from_POs__c From pse__proj__c Where id = : proj.id];
            system.assertEquals(null, project3.EAC_Cost_from_POs__c);
            system.assertEquals(null, project3.Planned_Cost_from_POs__c);            
        }
       
        } 
    
     static testmethod void populateProjectMangerFromProjectTest(){
        //Create region
        pse__Region__c region = TestDataUtility.getRegion(True);
        //Create Account
        Account acc = TestDataUtility.createAccounts(1,True)[0];
        //Create Custom Domain
        //TestDataUtility.createDomainSettings(1,true, true);
        //create work calendar
        pse__Work_Calendar__c wc = TestDataUtility.createWorkCalender(true);
        //Create Resource
        Contact con = TestDataUtility.createContacts(1,acc.id,false,true)[0];
        con.pse__Salesforce_User__c = UserInfo.getUserId();
        con.pse__Region__c = region.id;
        con.pse__Work_Calendar__c = wc.id;
        con.pse__Resource_Role__c = 'Project Manager Analyst';
        con.pse__Is_Resource__c = true;
        insert con;
        //Create Project
        pse__Proj__c proj = TestDataUtility.createProject(acc.id,region.id,false);
        proj.pse__Project_Manager__c = con.id;
        insert proj;
        //create Request
        Request__c req = TestDataUtility.getRequest(proj.Id , false);
        insert req;
        Request__c Request = [select id, Project_Manager__c from Request__c limit 1];
        system.assertEquals(proj.pse__Project_Manager__c, Request.Project_Manager__c);
        
    }
    
}