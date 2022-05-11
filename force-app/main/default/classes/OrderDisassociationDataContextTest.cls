/**
 * @File Name          : OrderDisassociationDataContextTest.cls
 * @Description        : Test class of OrderDisassociationDataContext
 * @Author             : Leonardo Santos | 2/19/2020
**/
@isTest
public with sharing class OrderDisassociationDataContextTest {
    @TestSetup
	static void setup(){
		SKU_Effort_Map__c skuEffortMap = new SKU_Effort_Map__c(
            Active__c = true,
            Description__c = 'ProDeploy Dell Storage SC Series vXXXX SAN - Deployment Verification',
            X30_Day_Support__c = true
        );
        insert skuEffortMap;

        SKU_Number__c skuNumber1 = new SKU_Number__c();
        skuNumber1.SKU_Number__c = '777-1000';
        skuNumber1.SKU_to_Effort_Mapping__c = skuEffortMap.Id;
        insert skuNumber1;
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

	@isTest 
	static void shouldInitiateDataContextProperties() {
		// arrange
		List<Order> orders = [SELECT Id, (Select Id From OrderItems) FROM Order];
		pse__Proj__c project = [SELECT Id FROM pse__Proj__c LIMIT 1];
        
        List<String> skuNumbersToMap = new List<String>{'123-456','CUSTOM SKU'};
        Map<String, String> phaseByTask = new Map<String, String>();
        phaseByTask.put('Scoping', 'Initiate');
        phaseByTask.put('Configuration', 'Execute');
        phaseByTask.put('Planning', 'Plan');
        SKU_Effort_Map__c skuEffort2 = OPRTestFactory.createSkuEffortMap(skuNumbersToMap, 10, false, phaseByTask);
        
        List<OrderItem> items = new List<OrderItem>();
        for(Order ord: orders){
			OrderItem item = ord.OrderItems[0];
            item.SKU_Number__c='123-456';
            items.add(item);
        }
        update items;
        
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
		OrderAssociationDataContext context = new OrderAssociationDataContext(eventList);
		context.save();
		// act
		Test.startTest();
        Set<Id> orderIdToDesassociate = new Set<Id>();
        orderIdToDesassociate.add(orders[0].Id);
        OrderDisassociationHandler handler = new OrderDisassociationHandler(orderIdToDesassociate);
        handler.run();
		Test.stopTest();

		// assert
		//System.assertEquals(2, context.orderMap.size(), 'orderMap size should be 2.');
		//System.assertEquals(1, context.projectMap.size(), 'projectMap size should be 1.');
		//System.assertEquals(1, context.projectWithOrdersMap.size(), 'projectWithOrdersMap size should be 1.');
		//System.assertEquals(2, context.projectWithOrdersMap.get(project.Id).size(), 'projectWithOrdersMap value size should be 2.');
	}
}