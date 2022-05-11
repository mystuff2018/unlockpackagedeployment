@isTest
public class OrderAssociationTriggerHandlerTest{

	@testSetup 
	static void setup(){
        //Login with Integration User Profile to create Account as a validation rule is in place to prevent Account creation by Other user in SFDC.
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){ 
		SKU_Effort_Map__c skuEffortMap = new SKU_Effort_Map__c( 
            Active__c = true,
            Description__c = 'ProDeploy Dell Storage SC Series vXXXX SAN - Deployment Verification',
            X30_Day_Support__c = true
        );
		insert skuEffortMap;
		
		SKU_Effort_Map__c skuEffortMap2 = new SKU_Effort_Map__c(
            Active__c = true,
            Description__c = 'Custom Activity Template',
            X30_Day_Support__c = true
        );
        insert skuEffortMap2;

        SKU_Number__c skuNumber1 = new SKU_Number__c();
        skuNumber1.SKU_Number__c = '777-1000';
        skuNumber1.SKU_to_Effort_Mapping__c = skuEffortMap.Id;
		insert skuNumber1;
		
		SKU_Number__c skuNumberCustom = new SKU_Number__c();
        skuNumberCustom.SKU_Number__c = 'CUSTOM SKU';
        skuNumberCustom.SKU_to_Effort_Mapping__c = skuEffortMap2.Id;
		insert skuNumberCustom;

		pse__Proj__c project = OPRTestFactory.createSimpleProject();
		Order order1 = OPRTestFactory.createSimpleOrder();
		Order order2 = OPRTestFactory.createSimpleOrder();

		List<Contact> lstContact = new List<Contact>();
		for(Contact contact :[SELECT Id, Mailing_Country__c From Contact]){
			contact.MailingCountry = contact.Mailing_Country__c;
			lstContact.add(contact);
		}
		update lstContact;
	}
    }

	@isTest
	static void shouldInitializeTriggerHandler() {
        TriggerHandler.bypass(ProjectTriggerHandler.class.getName());
        TriggerHandler.bypass(BudgetTriggerHandler.class.getName());
        TriggerHandler.bypass(MilestoneTriggerHandler.class.getName());
        TriggerHandler.bypass(ProjectTaskTriggerHandler.class.getName());
        TriggerHandler.bypass(RequestTriggerHandler.class.getName()); 
	TriggerHandler.bypass(ExpenseReportTriggerHandler.class.getName()); 
        TriggerHandler.bypass(ProjectTaskAssignmentTriggerHandler.class.getName());

		List<Order> orders = [SELECT Id, (Select Id From OrderItems) FROM Order];
		pse__Proj__c project = [SELECT Id FROM pse__Proj__c LIMIT 1];
		List<Order_Association__e> eventList = new List<Order_Association__e>();
		for(Order ord: orders){
			OrderItem item = ord.OrderItems[0];
			
			Order_Association__e event = new Order_Association__e(
				Order_ID__c = ord.Id,
				Project_ID__c = project.Id,
				Order_Item_Id__c = item.Id
			);
				
			eventList.add(event);
		}
		

		Test.startTest();
		EventBus.publish(eventList);
		Test.stopTest();

		for(OrderItem item: [SELECT Id, Project__c FROM OrderItem]){
			//System.assertEquals(item.Project__c, project.Id, 'project field of Order Item should be project Id');
            
          
		}
		
		
	}

	@isTest
	static void shouldThrowAnError(){

		List<Order> orders = [SELECT Id, (Select Id From OrderItems) FROM Order];

		pse__Proj__c project = [SELECT Id FROM pse__Proj__c LIMIT 1];

		List<Order_Association__e> eventList = new List<Order_Association__e>();
		for(Order ord: orders){
			OrderItem item = ord.OrderItems[0];
			
			Order_Association__e event = new Order_Association__e(
				Order_ID__c = ord.Id,
				Project_ID__c = 'IdWithProblem',
				Order_Item_Id__c = item.Id
			);
			
			eventList.add(event);
		}

		Test.startTest();
		List<Database.saveResult> publish = EventBus.publish(eventList);
		Test.stopTest();

		List<ExceptionLogger__c> logger = [
			SELECT Id
			FROM ExceptionLogger__c
		];

		System.assertEquals(1, logger.size(), 'It should saved a error');

	}

	@isTest
	static void shouldThrowAnDMLError(){

		List<Order> orders = [SELECT Id, (SELECT Id FROM OrderItems) FROM Order];

		pse__Proj__c project = [SELECT Id, pse__Start_Date__c FROM pse__Proj__c LIMIT 1];

		List<Order_Association__e> eventList = new List<Order_Association__e>();
		for(Order ord: orders){
			OrderItem item = ord.OrderItems[0];
			
			Order_Association__e event = new Order_Association__e(
				Order_ID__c = item.Id,
				Project_ID__c = project.Id,
				Order_Item_Id__c = item.Id
			);
			
			eventList.add(event);
		}

		Test.startTest();
		List<Database.saveResult> publish = EventBus.publish(eventList);
		Test.stopTest();

		List<ExceptionLogger__c> logger = [
			SELECT Id
			FROM ExceptionLogger__c
		];

		System.assertEquals(1, logger.size(), 'It should saved a error');

	}
 
}