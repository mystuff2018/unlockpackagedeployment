/***************************************************************************************
* Created By - Shweta Meshram
* Created On - March 10,2021
* Related Task - 
* Purpose - TEST Class for  BillingEventTriggerHandler
****************************************************************************************/
@isTest
public class BillingEventTriggerHandlerTest {
static testmethod void createPORequestForBilling(){
    	//Create User 
        User user1 = FBE_UtilityFactory_Test.getIntegrationUser();
    	System.runAs(user1){
            //Create region
             pse__Region__c region = TestDataUtility.getRegion(True);
            //Create permission Control
            pse__Permission_Control__c pc = TestDataUtility.getPermissionControl(UserInfo.getUserId(),region.id,false);
            pc.pse__Billing__c= true;
            insert pc;
            //Create Account
            Account acc = TestDataUtility.createAccounts(1,True)[0];
            //Create Custom Domain
            //TestDataUtility.createDomainSettings(1,true, true);
            //Create Project
            pse__Proj__c proj = TestDataUtility.createProject(acc.id,region.id,false);
            proj.pse__Billing_Type__c = 'Fixed Price';
            proj.pse__Exclude_From_Billing__c = false;
            insert proj;
            //Create Billing Event
            pse__Billing_Event__c bill = TestDataUtility.CreateBillingEvent(true,proj.id);
            Request__c req = [Select id, Project__c From Request__c Where Billing_Event__c=:bill.id limit 1];
            pse__proj__c project1 = [Select id From pse__Proj__c Where Id=:proj.id];
            System.assertEquals(project1.id, req.Project__c);
        	}
		}
}