/*
 * @class OrderDisassociationTask
 * @authors Pablo Dunke and Romulo Spier
 * @date 04/28/2020
 */

@isTest
private class OrderDisassociationTaskTest 
{
    @IsTest
    static void testNoWorkOrders() 
    {
        // Create the data
       pse__Proj__c project = OPRTestFactory.createProject();
		Order order = OPRTestFactory.createSimpleOrder();
        List<OrderItem> listOrderItem = [SELECT Id, SKU_Number__c FROM OrderItem WHERE OrderId =: order.Id];
        for(OrderItem orderItem: listOrderItem){
            orderItem.Project__c = project.Id;
            orderItem.SKU_Number__c = '111-1111';
        }
        update listOrderItem;

        pse__Project_Task__c parentTask = new pse__Project_Task__c();
        parentTask.pse__Project__c = project.Id;
        parentTask.Name = 'Initiate';
        insert parentTask;

        pse__Project_Task__c projectTask = new pse__Project_Task__c();
        projectTask.pse__Project__c = project.Id;
        projectTask.pse__Parent_Task__c = parentTask.Id;
        projectTask.pse__Estimated_Hours__c = 10;
        projectTask.Name = 'Scoping';
        insert projectTask;

        Order_Item_Sku_Effort_Map__c orderItemSkuEffortMap = new Order_Item_Sku_Effort_Map__c();
        orderItemSkuEffortMap.Order_Product__c = listOrderItem.get(0).Id;
        orderItemSkuEffortMap.Project_Task__c = projectTask.Id;
        insert orderItemSkuEffortMap;

        List<String> skuNumbersToMap = new List<String>{'111-1111'};
        Map<String, String> phaseByTask = new Map<String, String>();
        phaseByTask.put('Scoping', 'Initiate');
        phaseByTask.put('Planning', 'Plan');

        SKU_Effort_Map__c skuEffortMap = OPRTestFactory.createSkuEffortMap(skuNumbersToMap, 10, false, phaseByTask);

        SKU_Number__c skuNumber = [SELECT SKU_to_Effort_Mapping__c FROM SKU_Number__c WHERE SKU_Number__c = '111-1111'];
        SKU_Effort_Map_Entry__c skuEffortMapEntry = [SELECT Id FROM SKU_Effort_Map_Entry__c WHERE SKU_Effort_Map__c = :skuNumber.SKU_to_Effort_Mapping__c AND Name__c = 'Planning' LIMIT 1];
        Skill_SKU_Effort_Map_Entry__c skillSkuEffortMapEntry = [SELECT Id, Skill_Certification__c FROM Skill_SKU_Effort_Map_Entry__c WHERE SKU_Effort_Map_Entry__c = :skuEffortMapEntry.Id LIMIT 1];

        Project_Task_SKU_Effort_Mapping_Entry__c effortMapEntry = new Project_Task_SKU_Effort_Mapping_Entry__c();
        effortMapEntry.Project_Task__c = projectTask.Id;
        effortMapEntry.SKU_Effort_Mapping_Entry__c = skuEffortMapEntry.Id;
        insert effortMapEntry;

        Project_Task_Skill__c projectTaskSkill = new Project_Task_Skill__c();
        projectTaskSkill.Skill_Certification__c = skillSkuEffortMapEntry.Skill_Certification__c;
        projectTaskSkill.Project_Task__c = projectTask.Id;
        projectTaskSkill.Minimum_Rate__c = '1';
        insert projectTaskSkill;

        Map<Id, List<OrderItem>> mapProjectIdListOrderItem = new Map<Id, List<OrderItem>>();
        mapProjectIdListOrderItem.put(project.Id, listOrderItem);
        System.debug('@mapProjectIdListOrderItem: ' + mapProjectIdListOrderItem);
 
        // Create the context
        OrderDisassociationDataContext context = new OrderDisassociationDataContext(new Set<Id>{order.Id}); 

        // Action
        Test.startTest();
        OrderDisassociationTask.disassociateTasks(context);
        Test.stopTest();

        // Assertion
        System.assertEquals(1, context.projectTasksToDelete.size());
        System.assertEquals(1, context.projectTaskSkuEffortMappingEntryToDelete.size());
        System.assertEquals(1, context.orderItemTaskSkuToDelete.size());
        System.assertEquals(1, context.projectTaskSkillToDelete.size());
    }
    @IsTest
    static void testWorkOrdersStatusFFNew() 
    {
        // Create the data
        pse__Proj__c project = OPRTestFactory.createProject();
        Order order = OPRTestFactory.createSimpleOrder();
        List<OrderItem> listOrderItem = [SELECT Id FROM OrderItem WHERE OrderId =: order.Id];
        for(OrderItem orderItem: listOrderItem){
            orderItem.Project__c = project.Id;
            orderItem.SKU_Number__c = '111-1111';
        }
        update listOrderItem;

        pse__Project_Task__c projectTask = new pse__Project_Task__c();
        projectTask.pse__Project__c = project.Id;
        projectTask.Name = 'Initiate';
        insert projectTask;

        Order_Item_Sku_Effort_Map__c orderItemSkuEffortMap = new Order_Item_Sku_Effort_Map__c();
        orderItemSkuEffortMap.Order_Product__c = listOrderItem.get(0).Id;
        orderItemSkuEffortMap.Project_Task__c = projectTask.Id;
        insert orderItemSkuEffortMap;

        WorkOrder workOrder = new WorkOrder();
        workOrder.Project_Task__c = projectTask.Id;
        workOrder.Status = 'FF - New';
        insert workOrder;
        
        List<String> skuNumbersToMap = new List<String>{'111-1111'};
        Map<String, String> phaseByTask = new Map<String, String>();
        phaseByTask.put('Scoping', 'Initiate');
        phaseByTask.put('Planning', 'Plan');

        SKU_Effort_Map__c skuEffortMap = OPRTestFactory.createSkuEffortMap(skuNumbersToMap, 10, false, phaseByTask);

        Map<Id, List<OrderItem>> mapProjectIdListOrderItem = new Map<Id, List<OrderItem>>();
        mapProjectIdListOrderItem.put(project.Id, listOrderItem);

        // Create the context
        OrderDisassociationDataContext context = new OrderDisassociationDataContext(new Set<Id>{order.Id}); 
        context.projectOrderItemsToBeDissociateMap = mapProjectIdListOrderItem;

        // Action
        Test.startTest();
        OrderDisassociationTask.disassociateTasks(context);
        Test.stopTest();

        // Assertion
        System.assertEquals(0, context.projectTasksToDelete.size());
        System.assertEquals(0, context.projectTaskSkuEffortMappingEntryToDelete.size());
        System.assertEquals(0, context.orderItemTaskSkuToDelete.size());
        System.assertEquals(0, context.projectTaskSkillToDelete.size());
    }

    @IsTest
    static void testWorkOrdersStatusAfterFFNew() 
    {
        // Create the data
        pse__Proj__c project = OPRTestFactory.createProject();
        Order order = OPRTestFactory.createSimpleOrder();
        List<OrderItem> listOrderItem = [SELECT Id FROM OrderItem WHERE OrderId =: order.Id];
        for(OrderItem orderItem: listOrderItem){
            orderItem.Project__c = project.Id;
            orderItem.SKU_Number__c = '111-1111';
        }
        update listOrderItem;

        pse__Project_Task__c projectTask = new pse__Project_Task__c();
        projectTask.pse__Project__c = project.Id;
        projectTask.Name = 'Initiate';
        insert projectTask;

        Order_Item_Sku_Effort_Map__c orderItemSkuEffortMap = new Order_Item_Sku_Effort_Map__c();
        orderItemSkuEffortMap.Order_Product__c = listOrderItem.get(0).Id;
        orderItemSkuEffortMap.Project_Task__c = projectTask.Id;
        insert orderItemSkuEffortMap;

        WorkOrder workOrder = new WorkOrder();
        workOrder.Project_Task__c = projectTask.Id;
        workOrder.Status = 'FF - Submitted';
        insert workOrder;

        List<String> skuNumbersToMap = new List<String>{'111-1111'};
        Map<String, String> phaseByTask = new Map<String, String>();
        phaseByTask.put('Scoping', 'Initiate');
        phaseByTask.put('Planning', 'Plan');

        SKU_Effort_Map__c skuEffortMap = OPRTestFactory.createSkuEffortMap(skuNumbersToMap, 10, false, phaseByTask);

        Map<Id, List<OrderItem>> mapProjectIdListOrderItem = new Map<Id, List<OrderItem>>();
        mapProjectIdListOrderItem.put(project.Id, listOrderItem);

        // Create the context
        OrderDisassociationDataContext context = new OrderDisassociationDataContext(new Set<Id>{order.Id}); 

        // Action
        Test.startTest();
        OrderDisassociationTask.disassociateTasks(context);
        Test.stopTest();

        // Assertion
        System.assertEquals(0, context.projectTasksToDelete.size());
        System.assertEquals(0, context.orderItemTaskSkuToDelete.size());
    }

    @IsTest
    static void testOneDisassociationMultipleOrderItems() 
    {
        // Create the data
        pse__Proj__c project = OPRTestFactory.createProject();
        Order order = OPRTestFactory.createSimpleOrder();
         List<OrderItem> listOrderItem = [SELECT Id, Item_Class_Description__c, PriceBookEntryId FROM OrderItem WHERE OrderId =: order.Id];
        for(OrderItem orderItem: listOrderItem){
            orderItem.Project__c = project.Id;
            orderItem.SKU_Number__c = '111-1111';
        }
        update listOrderItem;
        
        OrderItem orderItem1 = listOrderItem.get(0);

        OrderItem orderItem2 = new OrderItem();
        orderItem2.SKU_Description__c = 'SKU Desc 2';
        orderItem2.SKU_Number__c = '777-1000';
        orderItem2.Quantity = 1;
        orderItem2.UnitPrice = 2;
        orderItem2.Item_Class_Description__c = orderItem1.Item_Class_Description__c;
        orderItem2.Tie_Number__c = '1';
        orderItem2.OrderId = order.Id;
        orderItem2.PriceBookEntryId = orderItem1.PriceBookEntryId;
        orderItem2.SKU_Cost__c = 2;
        orderItem2.SKU_Cost_Local__c = 2;
        orderItem2.Unit_Selling_Price_USD__c = 85000;
        orderItem2.Unit_Selling_Price_Local__c = 85000;
        orderItem2.SKU_Cost_USD__c = 85000;
        insert orderItem2;

        List<String> skuNumbersToMap = new List<String>{'111-1111'};
        Map<String, String> phaseByTask = new Map<String, String>();
        phaseByTask.put('Scoping', 'Initiate');
        phaseByTask.put('Planning', 'Plan');

        SKU_Effort_Map__c skuEffortMap = OPRTestFactory.createSkuEffortMap(skuNumbersToMap, 10, false, phaseByTask);

        pse__Project_Task__c projectTask = new pse__Project_Task__c();
        projectTask.pse__Project__c = project.Id;
        projectTask.Name = 'Initiate';
        insert projectTask;

        Order_Item_Sku_Effort_Map__c orderItemSkuEffortMap1 = new Order_Item_Sku_Effort_Map__c();
        orderItemSkuEffortMap1.Order_Product__c = orderItem1.Id;
        orderItemSkuEffortMap1.Project_Task__c = projectTask.Id;
        insert orderItemSkuEffortMap1;

        Order_Item_Sku_Effort_Map__c orderItemSkuEffortMap2 = new Order_Item_Sku_Effort_Map__c();
        orderItemSkuEffortMap2.Order_Product__c = orderItem2.Id;
        orderItemSkuEffortMap2.Project_Task__c = projectTask.Id;
        insert orderItemSkuEffortMap2;

        Map<Id, List<OrderItem>> mapProjectIdListOrderItem = new Map<Id, List<OrderItem>>();
        mapProjectIdListOrderItem.put(project.Id, listOrderItem);
 
        // Create the context
        OrderDisassociationDataContext context = new OrderDisassociationDataContext(new Set<Id>{order.Id}); 

        // Action
        Test.startTest();
        OrderDisassociationTask.disassociateTasks(context);
        Test.stopTest();

        // Assertion
        System.assertEquals(0, context.projectTasksToDelete.size());
        System.assertEquals(0, context.orderItemTaskSkuToDelete.size());
    }

    @IsTest
    static void testBothDisassociationsMultipleOrderItems() 
    {
        // Create the data
        pse__Proj__c project = OPRTestFactory.createProject();
        Order order = OPRTestFactory.createSimpleOrder();
        List<OrderItem> listOrderItem = [SELECT Id, SKU_Number__c, Item_Class_Description__c, PriceBookEntryId FROM OrderItem WHERE OrderId =: order.Id];
        for(OrderItem orderItem: listOrderItem){
            orderItem.Project__c = project.Id;
            orderItem.SKU_Number__c = '111-1111';
        }
        update listOrderItem;

        pse__Project_Task__c parentTask = new pse__Project_Task__c();
        parentTask.pse__Project__c = project.Id;
        parentTask.Name = 'Initiate';
        insert parentTask;

        pse__Project_Task__c projectTask = new pse__Project_Task__c();
        projectTask.pse__Project__c = project.Id;
        projectTask.pse__Parent_Task__c = parentTask.Id;
        projectTask.pse__Estimated_Hours__c = 20;
        projectTask.Name = 'Scoping';
        insert projectTask;
        
        OrderItem orderItem1 = listOrderItem.get(0);

        OrderItem orderItem2 = new OrderItem();
        orderItem2.SKU_Description__c = 'SKU Desc 2';
        orderItem2.SKU_Number__c = '777-1000';
        orderItem2.Quantity = 1;
        orderItem2.UnitPrice = 2;
        orderItem2.Item_Class_Description__c = orderItem1.Item_Class_Description__c;
        orderItem2.Tie_Number__c = '1';
        orderItem2.OrderId = order.Id;
        orderItem2.PriceBookEntryId = orderItem1.PriceBookEntryId;
        orderItem2.SKU_Cost__c = 2;
        orderItem2.SKU_Cost_Local__c = 2;
        orderItem2.Unit_Selling_Price_USD__c = 85000;
        orderItem2.Unit_Selling_Price_Local__c = 85000;
        orderItem2.SKU_Cost_USD__c = 85000;
        insert orderItem2;

        List<String> skuNumbersToMap = new List<String>{'111-1111', '777-1000'};
        Map<String, String> phaseByTask = new Map<String, String>();
        phaseByTask.put('Scoping', 'Initiate');
        phaseByTask.put('Planning', 'Plan');
        SKU_Effort_Map__c skuEffortMap = OPRTestFactory.createSkuEffortMap(skuNumbersToMap, 10, false, phaseByTask);

        Order_Item_Sku_Effort_Map__c orderItemSkuEffortMap1 = new Order_Item_Sku_Effort_Map__c();
        orderItemSkuEffortMap1.Order_Product__c = orderItem1.Id;
        orderItemSkuEffortMap1.Project_Task__c = projectTask.Id;
        insert orderItemSkuEffortMap1;

        Order_Item_Sku_Effort_Map__c orderItemSkuEffortMap2 = new Order_Item_Sku_Effort_Map__c();
        orderItemSkuEffortMap2.Order_Product__c = orderItem2.Id;
        orderItemSkuEffortMap2.Project_Task__c = projectTask.Id;
        insert orderItemSkuEffortMap2;

        listOrderItem = [SELECT Id, SKU_Number__c, Quantity FROM OrderItem WHERE SKU_Number__c = '111-1111'];
        Map<Id, List<OrderItem>> mapProjectIdListOrderItem = new Map<Id, List<OrderItem>>();
        mapProjectIdListOrderItem.put(project.Id, listOrderItem);
 
        // Create the context
        OrderDisassociationDataContext context = new OrderDisassociationDataContext(new Set<Id>{order.Id}); 
        context.projectOrderItemsToBeDissociateMap = mapProjectIdListOrderItem;

        pse__Project_Task__c projectTaskBeforeDesassociate = [
            SELECT Id, pse__Estimated_Hours__c
            FROM pse__Project_Task__c
            WHERE Name = 'Scoping'
            LIMIT 1
        ];

        System.assertEquals(20, projectTaskBeforeDesassociate.pse__Estimated_Hours__c, 'Scoping task should have 20 hours estimated before disassociation');

        // Action
        Test.startTest();
        OrderDisassociationTask.disassociateTasks(context);

        context.save();
        Test.stopTest();

        pse__Project_Task__c projectTaskAfterDesassociate = [
            SELECT Id, pse__Estimated_Hours__c
            FROM pse__Project_Task__c
            WHERE Name = 'Scoping'
            LIMIT 1
        ];

        System.assertEquals(20, projectTaskAfterDesassociate.pse__Estimated_Hours__c, 'Scoping task should have 10 hours estimated after disassociation');


        // Assertion
        System.assertEquals(0, context.projectTasksToDelete.size());
        System.assertEquals(0, context.orderItemTaskSkuToDelete.size());
    }
}