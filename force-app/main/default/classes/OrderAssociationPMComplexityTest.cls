/**
 * @File Name          : OrderAssociationPMComplexityTest.cls
 * @Description        : Test class of OrderAssociationPMComplexity
 * @Author             : Leonardo Santos | 2/18/2020
**/

@isTest
public with sharing class OrderAssociationPMComplexityTest {
    
    /**
    * @description It should test the PM Complexity for 'Low' Sku complexity tiers.
    * @author Leonardo Santos | 2/19/2020 
    * @return void 
    **/
    @isTest static void shouldSetPMComplexityLow(){

        List<String> skuNumbersToMap1 = new List<String>{'111-1111', '222-2222'};
        Map<String, String> phaseByTask = new Map<String, String>();
        phaseByTask.put('Scoping', 'Initiate');
        phaseByTask.put('Configuration', 'Execute'); 
        phaseByTask.put('Planning', 'Plan');

        SKU_Effort_Map__c skuEffort1 = OPRTestFactory.createSkuEffortMap(skuNumbersToMap1, 10, false, phaseByTask);

        pse__Proj__c project1 = OPRTestFactory.createSimpleProject();
        Order order1 = OPRTestFactory.createSimpleOrder();

        OrderItem orderItem = [
            SELECT Id, SKU_Number__c, PriceBookEntryId, Item_Class_Description__c
            FROM OrderItem
            WHERE OrderId = :order1.Id
            LIMIT 1
        ];
        orderItem.SKU_Number__c = '111-1111';
        update orderItem;

        List<Order> orders = [SELECT Id, (Select Id From OrderItems) FROM Order];
		
		List<Order_Association__e> eventList = new List<Order_Association__e>();
		for(Order ord: orders){
			OrderItem item = ord.OrderItems[0];
			Order_Association__e event = new Order_Association__e(
				Order_ID__c = ord.Id,
				Project_ID__c = project1.Id,
				Order_Item_Id__c = item.Id
			);
				
			eventList.add(event);
		}		
        OrderAssociationDataContext context = new OrderAssociationDataContext(eventList);

        Test.startTest();
        
        List<pse__Proj__c> listProjects = context.projectMap.values();
        pse__Proj__c project = null;
        if (listProjects.size() > 0) {
            project = listProjects.get(0);
        }
        List<OrderItem> listOrderItem = context.projectWithAllOrderItems.get(project.Id);
        
        OrderAssociationPMComplexity.setPMComplexity(project,listOrderItem, context.skuEffortMap);
        Test.stopTest();

        pse__Proj__c resultProject = context.projectMap.get(project1.Id);
        System.assertEquals('Low', resultProject.PM_Complexity__c, 'PM complexity should be High');
    }
    
    /**
    * @description It should test the PM Complexity for 'Medium' Sku complexity tiers.
    * @author Leonardo Santos | 2/19/2020 
    * @return void 
    **/
    @isTest static void shouldSetPMComplexityMedium(){

        List<String> skuNumbersToMap1 = new List<String>{'111-1111', '222-2222'};
        Map<String, String> phaseByTask = new Map<String, String>();
        phaseByTask.put('Scoping', 'Initiate');
        phaseByTask.put('Configuration', 'Execute');
        phaseByTask.put('Planning', 'Plan');

        SKU_Effort_Map__c skuEffort1 = OPRTestFactory.createSkuEffortMap(skuNumbersToMap1, 10, false, phaseByTask);

        List<SKU_Effort_Map_Entry__c> entries = [
            SELECT Id
            FROM SKU_Effort_Map_Entry__c
            LIMIT 2
        ];
        for(SKU_Effort_Map_Entry__c entry: entries){
            entry.Project_Complexity_Tier__c = 'Medium';
        }
        update entries;

        pse__Proj__c project1 = OPRTestFactory.createSimpleProject();
        Order order1 = OPRTestFactory.createSimpleOrder();

        OrderItem orderItem = [
            SELECT Id, SKU_Number__c, PriceBookEntryId, Item_Class_Description__c
            FROM OrderItem
            WHERE OrderId = :order1.Id
            LIMIT 1
        ];
        orderItem.SKU_Number__c = '111-1111';
        update orderItem;

        List<Order> orders = [SELECT Id, (Select Id From OrderItems) FROM Order];
		
		List<Order_Association__e> eventList = new List<Order_Association__e>();
		for(Order ord: orders){
			OrderItem item = ord.OrderItems[0];
			Order_Association__e event = new Order_Association__e(
				Order_ID__c = ord.Id,
				Project_ID__c = project1.Id,
				Order_Item_Id__c = item.Id
			);
				
			eventList.add(event);
		}		
        OrderAssociationDataContext context = new OrderAssociationDataContext(eventList);

        Test.startTest();
        List<pse__Proj__c> listProjects = context.projectMap.values();
        pse__Proj__c project = null;
        if (listProjects.size() > 0) {
            project = listProjects.get(0);
        }
        List<OrderItem> listOrderItem = context.projectWithAllOrderItems.get(project.Id);
        
        OrderAssociationPMComplexity.setPMComplexity(project,listOrderItem, context.skuEffortMap);
        Test.stopTest();

        pse__Proj__c resultProject = context.projectMap.get(project1.Id);
        System.assertEquals('Medium', resultProject.PM_Complexity__c, 'PM complexity should be Medium');
    }

    /**
    * @description It should test the PM Complexity for 'High' Sku complexity tiers.
    * @author Leonardo Santos | 2/19/2020 
    * @return void 
    **/
    @isTest static void shouldSetPMComplexityHigh(){

        List<String> skuNumbersToMap1 = new List<String>{'111-1111', '222-2222'};
        Map<String, String> phaseByTask = new Map<String, String>();
        phaseByTask.put('Scoping', 'Initiate');
        phaseByTask.put('Configuration', 'Execute');
        phaseByTask.put('Planning', 'Plan');

        SKU_Effort_Map__c skuEffort1 = OPRTestFactory.createSkuEffortMap(skuNumbersToMap1, 10, false, phaseByTask);

        List<SKU_Effort_Map_Entry__c> entries = [
            SELECT Id
            FROM SKU_Effort_Map_Entry__c
            LIMIT 2
        ];
        for(SKU_Effort_Map_Entry__c entry: entries){
            entry.Project_Complexity_Tier__c = 'High';
        }
        update entries;

        pse__Proj__c project1 = OPRTestFactory.createSimpleProject();
        Order order1 = OPRTestFactory.createSimpleOrder();

        OrderItem orderItem = [
            SELECT Id, SKU_Number__c, PriceBookEntryId, Item_Class_Description__c
            FROM OrderItem
            WHERE OrderId = :order1.Id
            LIMIT 1
        ];
        orderItem.SKU_Number__c = '111-1111';
        update orderItem;

        List<Order> orders = [SELECT Id, (Select Id From OrderItems) FROM Order];
		
		List<Order_Association__e> eventList = new List<Order_Association__e>();
		for(Order ord: orders){
			OrderItem item = ord.OrderItems[0];
			Order_Association__e event = new Order_Association__e(
				Order_ID__c = ord.Id,
				Project_ID__c = project1.Id,
				Order_Item_Id__c = item.Id
			);
				
			eventList.add(event);
		}		
        OrderAssociationDataContext context = new OrderAssociationDataContext(eventList);

        Test.startTest();
        List<pse__Proj__c> listProjects = context.projectMap.values();
        pse__Proj__c project = null;
        if (listProjects.size() > 0) {
            project = listProjects.get(0);
        }
        List<OrderItem> listOrderItem = context.projectWithAllOrderItems.get(project.Id);
        
        OrderAssociationPMComplexity.setPMComplexity(project,listOrderItem, context.skuEffortMap);
        Test.stopTest();

        pse__Proj__c resultProject = context.projectMap.get(project1.Id);
        System.assertEquals('High', resultProject.PM_Complexity__c, 'PM complexity should be High');
    }

}