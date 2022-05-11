/**
 * @File Name          : OrderAssociationTaskCreationTest.cls
 * @Description        : Test class of OrderAssociationPMComplexity
 * @Author             : Leonardo Santos | 2/18/2020
**/

@isTest
public class OrderAssociationTaskCreationTest {

    /**
    * @description It should create tasks for one project with one order  with standard sku.
    * @author Leonardo Santos | 2/18/2020 
    * @return void 
    **/
    @isTest
    static void shouldCreateTasksOneOrder(){
        //Login with Integration User Profile to create Account as a validation rule is in place to prevent Account creation by Other user in SFDC.
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){ 
            List<String> skuNumbersToMap1 = new List<String>{'111-1111', '222-2222'};
            Map<String, String> phaseByTask = new Map<String, String>();
            phaseByTask.put('Scoping', 'Initiate');
            phaseByTask.put('Configuration', 'Execute');
            phaseByTask.put('Planning', 'Plan');
            
            SKU_Effort_Map__c skuEffort1 = OPRTestFactory.createSkuEffortMap(skuNumbersToMap1, 10, false, phaseByTask);
            
            pse__Proj__c project1 = OPRTestFactory.createSimpleProject();
            
            Order order1 = OPRTestFactory.createSimpleOrder();
            
            OrderItem orderItem = [
                SELECT Id, SKU_Number__c, PriceBookEntryId, Item_Class_Description__c, OrderId
                FROM OrderItem
                WHERE OrderId = :order1.Id
                LIMIT 1
            ];
            
            orderItem.Quantity = 2;
            orderItem.SKU_Number__c = '111-1111';
            update orderItem;
            
            List<Order_Association__e> eventList = new List<Order_Association__e>();
            Order_Association__e event = new Order_Association__e(
                Order_ID__c = orderItem.OrderId,
                Project_ID__c = project1.Id,
                Order_Item_Id__c = orderItem.Id
            );
            eventList.add(event);
            
            
            Test.startTest();
            OrderAssociationDataContext context = new OrderAssociationDataContext(eventList);
            OrderAssociationTaskCreation.createTasks(context);
            Test.stopTest();
            
            // Top tasks
            List<pse__Project_Task__c> projectTasks = [
                SELECT Id, Name, pse__Parent_Task__c, pse__Estimated_Hours__c
                FROM pse__Project_Task__c
                WHERE pse__Project__c = :project1.Id
            ];
            
            Map<String, pse__Project_Task__c> topTaskMap = new Map<String, pse__Project_Task__c>();
            Map<String, pse__Project_Task__c> childTaskMap = new Map<String, pse__Project_Task__c>();
            
            for(pse__Project_Task__c task: projectTasks){
                if(task.pse__Parent_Task__c == null){
                    topTaskMap.put(task.Name, task);
                }
                else{
                    childTaskMap.put(task.Name, task);
                }
            }
            
            System.assertEquals(3, topTaskMap.values().size(), 'It should have 3 top tasks');
            System.assert(topTaskMap.get('Initiate') != null, 'It should a top task called Initiate');
            System.assert(topTaskMap.get('Execute') != null, 'It should a top task called Execute');
            System.assert(topTaskMap.get('Plan') != null, 'It should a top task called Plan');
            
            System.assertEquals(3, childTaskMap.values().size(), 'It should have 3 child tasks');
            System.assertEquals(20, childTaskMap.get('Scoping').pse__Estimated_Hours__c, 'It should have a child task called Scoping with 20 estimated hours');
            System.assertEquals(20, childTaskMap.get('Configuration').pse__Estimated_Hours__c, 'It should have a child task called Configuration with 20 estimated hours');
            System.assertEquals(20, childTaskMap.get('Planning').pse__Estimated_Hours__c, 'It should have a child task called Planning with 20 estimated hours');
            
            // Project task skills
            List<Project_Task_Skill__c> projectTaskSkills = [
                SELECT Id
                FROM Project_Task_Skill__c
                WHERE Project_Task__c IN :childTaskMap.values()
            ];
            System.assertEquals(6, projectTaskSkills.size(), 'It should have 6 project task skills');
            
            // Project Task Sku Effort Mapping entry
            List<Project_Task_SKU_Effort_Mapping_Entry__c> projecTaskSkuEntries = [
                SELECT Id
                FROM Project_Task_SKU_Effort_Mapping_Entry__c
                WHERE Project_Task__c IN :childTaskMap.values()
            ];
            System.assertEquals(3, projecTaskSkuEntries.size(), 'It should have 3 project task sku effort mappings');
            
            // Order_Item_Sku_Effort_Map__c
            List<Order_Item_Sku_Effort_Map__c> orderItemSkuMap = [
                SELECT Id
                FROM Order_Item_Sku_Effort_Map__c
                WHERE Project_Task__c IN :childTaskMap.values()
            ];
            System.assertEquals(3, orderItemSkuMap.size(), 'It should have 3 order item sku effort mappings');  
        }
    }

    /**
    * @description It should create tasks for one project with two orders with standard sku.
    * @author Leonardo Santos | 2/18/2020 
    * @return void 
    **/
    @isTest
    static void shouldCreateTasksTwoOrders(){
        
        //Login with Integration User Profile to create Account as a validation rule is in place to prevent Account creation by Other user in SFDC.
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){ 
            List<String> skuNumbersToMap1 = new List<String>{'111-1111', '222-2222'};
            List<String> skuNumbersToMap2 = new List<String>{'333-3333'};
                    
            Map<String, String> phaseByTask = new Map<String, String>();
            phaseByTask.put('Scoping', 'Initiate');
            phaseByTask.put('Configuration', 'Execute');
            phaseByTask.put('Planning', 'Plan');
            
            SKU_Effort_Map__c skuEffort1 = OPRTestFactory.createSkuEffortMap(skuNumbersToMap1, 10, false, phaseByTask);
            SKU_Effort_Map__c skuEffort2 = OPRTestFactory.createSkuEffortMap(skuNumbersToMap2, 10, false, phaseByTask);
            
            pse__Proj__c project1 = OPRTestFactory.createSimpleProject();
            Order order1 = OPRTestFactory.createSimpleOrder();
            
            OrderItem orderItem = [
                SELECT Id, SKU_Number__c, PriceBookEntryId, Item_Class_Description__c, OrderId
                FROM OrderItem
                WHERE OrderId = :order1.Id
                LIMIT 1
            ];
            orderItem.Quantity = 2;
            orderItem.SKU_Number__c = '111-1111';
            update orderItem;
            
            OrderItem oi = new OrderItem();
            oi.SKU_Description__c = 'SKU Desc 1';
            oi.SKU_Number__c = '222-2222';
            oi.Quantity = 1;
            oi.UnitPrice = 2;
            oi.Item_Class_Description__c = orderItem.Item_Class_Description__c;
            oi.Tie_Number__c = '1';
            oi.OrderId = order1.Id;
            oi.PriceBookEntryId = orderItem.PriceBookEntryId;
            oi.SKU_Cost__c = 2;
            oi.Unit_Selling_Price_USD__c = 85000;
            oi.SKU_Cost_USD__c = 85000;
            insert oi;
            
            pse__Proj__c project2 = OPRTestFactory.createSimpleProject();
            Order order2 = OPRTestFactory.createSimpleOrder();
            
            OrderItem orderItem2 = [
                SELECT Id, SKU_Number__c, OrderId
                FROM OrderItem
                WHERE OrderId = :order2.Id
                LIMIT 1
            ];
            orderItem2.SKU_Number__c = '333-3333';
            update orderItem2;
            
            List<Order_Association__e> eventList = new List<Order_Association__e>();
            Order_Association__e event1 = new Order_Association__e(
                Order_ID__c = orderItem.OrderId,
                Project_ID__c = project1.Id,
                Order_Item_Id__c = orderItem.Id
            );
            eventList.add(event1);
            
            Order_Association__e event2 = new Order_Association__e(
                Order_ID__c = orderItem2.OrderId,
                Project_ID__c = project1.Id,
                Order_Item_Id__c = orderItem2.Id
            );
            eventList.add(event2);
            
            Order_Association__e event3 = new Order_Association__e(
                Order_ID__c = oi.OrderId,
                Project_ID__c = project1.Id,
                Order_Item_Id__c = oi.Id
            );
            eventList.add(event3);
            
            
            Test.startTest();
            OrderAssociationDataContext context = new OrderAssociationDataContext(eventList);
            OrderAssociationTaskCreation.createTasks(context);
            Test.stopTest();
            
            // Top tasks
            List<pse__Project_Task__c> projectTasks = [
                SELECT Id, Name, pse__Parent_Task__c, pse__Estimated_Hours__c
                FROM pse__Project_Task__c
                WHERE pse__Project__c = :project1.Id
            ];
            
            Map<String, pse__Project_Task__c> topTaskMap = new Map<String, pse__Project_Task__c>();
            Map<String, pse__Project_Task__c> childTaskMap = new Map<String, pse__Project_Task__c>();
            
            for(pse__Project_Task__c task: projectTasks){
                if(task.pse__Parent_Task__c == null){
                    topTaskMap.put(task.Name, task);
                }
                else{
                    childTaskMap.put(task.Name, task);
                }
            }
            
            System.assertEquals(3, topTaskMap.values().size(), 'It should have 3 top tasks');
            System.assert(topTaskMap.get('Initiate') != null, 'It should a top task called Initiate');
            System.assert(topTaskMap.get('Execute') != null, 'It should a top task called Execute');
            System.assert(topTaskMap.get('Plan') != null, 'It should a top task called Plan');
            
            System.assertEquals(3, childTaskMap.values().size(), 'It should have 3 child tasks');
            System.assertEquals(40, childTaskMap.get('Scoping').pse__Estimated_Hours__c, 'It should have a child task called Scoping with 40 estimated hours');
            System.assertEquals(40, childTaskMap.get('Configuration').pse__Estimated_Hours__c, 'It should have a child task called Configuration with 40 estimated hours');
            System.assertEquals(40, childTaskMap.get('Planning').pse__Estimated_Hours__c, 'It should have a child task called Planning with 40 estimated hours');
            
            // Project task skills
            List<Project_Task_Skill__c> projectTaskSkills = [
                SELECT Id
                FROM Project_Task_Skill__c
                WHERE Project_Task__c IN :childTaskMap.values()
            ];
            System.assertEquals(6, projectTaskSkills.size(), 'It should have 6 project task skills');
            
            // Project Task Sku Effort Mapping entry
            List<Project_Task_SKU_Effort_Mapping_Entry__c> projecTaskSkuEntries = [
                SELECT Id
                FROM Project_Task_SKU_Effort_Mapping_Entry__c
                WHERE Project_Task__c IN :childTaskMap.values()
            ];
            System.assertEquals(6, projecTaskSkuEntries.size(), 'It should have 6 project task sku effort mappings');
            
            // Order_Item_Sku_Effort_Map__c
            List<Order_Item_Sku_Effort_Map__c> orderItemSkuMap = [
                SELECT Id
                FROM Order_Item_Sku_Effort_Map__c
                WHERE Project_Task__c IN :childTaskMap.values()
            ];
            System.assertEquals(9, orderItemSkuMap.size(), 'It should have 9 order item sku effort mappings');
        }
    }

    /**
    * @description It should create tasks for one project with two orders with standard sku and custom sku.
    * @author Leonardo Santos | 2/18/2020 
    * @return void 
    **/
    //@isTest
    /*static void shouldCreateTasksTwoOrdersCustom(){

        List<String> skuNumbersToMap1 = new List<String>{'111-1111', '222-2222'};
        List<String> skuNumbersToMap2 = new List<String>{'333-3333'};
        List<String> skuNumbersToMapCustom = new List<String>{'CUSTOM SKU'};
        
        Map<String, String> phaseByTask = new Map<String, String>();
        phaseByTask.put('Scoping', 'Initiate');
        phaseByTask.put('Configuration', 'Execute');
        phaseByTask.put('Planning', 'Plan');

        Map<String, String> phaseByTaskCustom = new Map<String, String>();
        phaseByTaskCustom.put('Scoping', 'Initiate');
        phaseByTaskCustom.put('Physical Installation', 'Execute');
        phaseByTaskCustom.put('Planning', 'Plan');
        phaseByTaskCustom.put('Delivery', 'Close');

        SKU_Effort_Map__c skuEffort1 = OPRTestFactory.createSkuEffortMap(skuNumbersToMap1, 10, false, phaseByTask);
        SKU_Effort_Map__c skuEffort2 = OPRTestFactory.createSkuEffortMap(skuNumbersToMap2, 10, false, phaseByTask);
        SKU_Effort_Map__c skuEffortCustom = OPRTestFactory.createSkuEffortMap(skuNumbersToMapCustom, 10, false, phaseByTaskCustom);

        // Change estimated hours from custom entries
        List<SKU_Effort_Map_Entry__c> entries = [
            SELECT Id, Estimated_Hours__c
            FROM SKU_Effort_Map_Entry__c 
            WHERE SKU_Effort_Map__c IN 
                (SELECT SKU_to_Effort_Mapping__c 
                 FROM SKU_Number__c 
                 WHERE SKU_Number__c = 'CUSTOM SKU')
        ];
        for(SKU_Effort_Map_Entry__c entry: entries){
            entry.Estimated_Hours__c = 45;
        }

        update entries;

        pse__Proj__c project1 = OPRTestFactory.createSimpleProject();
        Order order1 = OPRTestFactory.createSimpleOrder();

        OrderItem orderItem = [
            SELECT Id, SKU_Number__c, PriceBookEntryId, Item_Class_Description__c, OrderId
            FROM OrderItem
            WHERE OrderId = :order1.Id
            LIMIT 1
        ];
        orderItem.SKU_Number__c = '111-1111';
        update orderItem;

        OrderItem oi = new OrderItem();
        oi.SKU_Description__c = 'SKU Desc 1';
        oi.SKU_Number__c = '222-2222';
        oi.Quantity = 1;
        oi.UnitPrice = 2;
        oi.Item_Class_Description__c = orderItem.Item_Class_Description__c;
        oi.Tie_Number__c = '1';
        oi.OrderId = order1.Id;
        oi.PriceBookEntryId = orderItem.PriceBookEntryId;
        oi.SKU_Cost__c = 2;
        oi.Unit_Selling_Price_USD__c = 85000;
        oi.SKU_Cost_USD__c = 85000;
        insert oi;

        OrderItem oi2 = new OrderItem();
        oi2.SKU_Description__c = 'SKU Desc 1';
        oi2.SKU_Number__c = '444-4444';
        oi2.Quantity = 1;
        oi2.UnitPrice = 2;
        oi2.Item_Class_Description__c = orderItem.Item_Class_Description__c;
        oi2.Tie_Number__c = '1';
        oi2.OrderId = order1.Id;
        oi2.PriceBookEntryId = orderItem.PriceBookEntryId;
        oi2.SKU_Cost__c = 2;
        oi2.Unit_Selling_Price_USD__c = 85000;
        oi2.SKU_Cost_USD__c = 85000;
        insert oi2;

        pse__Proj__c project2 = OPRTestFactory.createSimpleProject();
        Order order2 = OPRTestFactory.createSimpleOrder();
        
        OrderItem orderItem2 = [
            SELECT Id, SKU_Number__c, OrderId
            FROM OrderItem
            WHERE OrderId = :order2.Id
            LIMIT 1
        ];
        orderItem2.SKU_Number__c = '333-3333';
        update orderItem2;
		
		Test.startTest();
        List<Order_Association__e> eventList = new List<Order_Association__e>();
        Order_Association__e event1 = new Order_Association__e(
        	Order_ID__c = orderItem.OrderId,
			Project_ID__c = project1.Id,
			Order_Item_Id__c = orderItem.Id
		);
        eventList.add(event1);
        
        Order_Association__e event2 = new Order_Association__e(
        	Order_ID__c = orderItem2.OrderId,
			Project_ID__c = project1.Id,
			Order_Item_Id__c = orderItem2.Id
		);
        eventList.add(event2);
        
        Order_Association__e event3 = new Order_Association__e(
        	Order_ID__c = oi.OrderId,
			Project_ID__c = project1.Id,
			Order_Item_Id__c = oi.Id
		);
        eventList.add(event3);
        
         Order_Association__e event4 = new Order_Association__e(
        	Order_ID__c = oi2.OrderId,
			Project_ID__c = project1.Id,
			Order_Item_Id__c = oi2.Id
		);
        eventList.add(event4);
		
        
        OrderAssociationDataContext context = new OrderAssociationDataContext(eventList);
        OrderAssociationTaskCreation.createTasks(context);
        Test.stopTest();

        // Top tasks
        List<pse__Project_Task__c> projectTasks = [
            SELECT Id, Name, pse__Parent_Task__c, pse__Estimated_Hours__c
            FROM pse__Project_Task__c
            WHERE pse__Project__c = :project1.Id
        ];

        Map<String, pse__Project_Task__c> topTaskMap = new Map<String, pse__Project_Task__c>();
        Map<String, pse__Project_Task__c> childTaskMap = new Map<String, pse__Project_Task__c>();

        for(pse__Project_Task__c task: projectTasks){
            if(task.pse__Parent_Task__c == null){
                topTaskMap.put(task.Name, task);
            }
            else{
                childTaskMap.put(task.Name, task);
            }
        }

        System.assertEquals(4, topTaskMap.values().size(), 'It should have 4 top tasks');
        System.assert(topTaskMap.get('Initiate') != null, 'It should a top task called Initiate');
        System.assert(topTaskMap.get('Execute') != null, 'It should a top task called Execute');
        System.assert(topTaskMap.get('Plan') != null, 'It should a top task called Plan');
        System.assert(topTaskMap.get('Close') != null, 'It should a top task called Close');
       
        System.assertEquals(5, childTaskMap.values().size(), 'It should have 5 child tasks');
        System.assertEquals(75, childTaskMap.get('Scoping').pse__Estimated_Hours__c, 'It should have a child task called Scoping with 75 estimated hours');
        System.assertEquals(30, childTaskMap.get('Configuration').pse__Estimated_Hours__c, 'It should have a child task called Configuration with 30 estimated hours');
        System.assertEquals(75, childTaskMap.get('Planning').pse__Estimated_Hours__c, 'It should have a child task called Planning with 75 estimated hours');
        System.assertEquals(45, childTaskMap.get('Physical Installation').pse__Estimated_Hours__c, 'It should have a child task called Physical Installation with 45 estimated hours');
        System.assertEquals(45, childTaskMap.get('Delivery').pse__Estimated_Hours__c, 'It should have a child task called Delivery with 45 estimated hours');

        // Project task skills
        List<Project_Task_Skill__c> projectTaskSkills = [
            SELECT Id
            FROM Project_Task_Skill__c
            WHERE Project_Task__c IN :childTaskMap.values()
        ];
        System.assertEquals(10, projectTaskSkills.size(), 'It should have 10 project task skills');

        // Project Task Sku Effort Mapping entry
        List<Project_Task_SKU_Effort_Mapping_Entry__c> projecTaskSkuEntries = [
            SELECT Id
            FROM Project_Task_SKU_Effort_Mapping_Entry__c
            WHERE Project_Task__c IN :childTaskMap.values()
        ];
        System.assertEquals(10, projecTaskSkuEntries.size(), 'It should have 10 project task sku effort mappings');
        
        // Order_Item_Sku_Effort_Map__c
        List<Order_Item_Sku_Effort_Map__c> orderItemSkuMap = [
            SELECT Id
            FROM Order_Item_Sku_Effort_Map__c
            WHERE Project_Task__c IN :childTaskMap.values()
        ];
        System.assertEquals(13, orderItemSkuMap.size(), 'It should have 13 order item sku effort mappings');
    } */
 
    /**
    * @description It should create tasks for two projects, one of them with two orders with 
    * standard sku and custom sku and another with one order with standard sku.
    * @author Leonardo Santos | 2/18/2020 
    * @return void 
    **/
    /*@isTest
    static void shouldCreateTasksTwoProjects(){

        List<String> skuNumbersToMap1 = new List<String>{'111-1111', '222-2222'};
        List<String> skuNumbersToMap2 = new List<String>{'333-3333'};
        List<String> skuNumbersToMapCustom = new List<String>{'CUSTOM SKU'};
        
        Map<String, String> phaseByTask = new Map<String, String>();
        phaseByTask.put('Scoping', 'Initiate');
        phaseByTask.put('Configuration', 'Execute');
        phaseByTask.put('Planning', 'Plan');

        Map<String, String> phaseByTaskCustom = new Map<String, String>();
        phaseByTaskCustom.put('Scoping', 'Initiate');
        phaseByTaskCustom.put('Physical Installation', 'Execute');
        phaseByTaskCustom.put('Planning', 'Plan');
        phaseByTaskCustom.put('Delivery', 'Close');

        SKU_Effort_Map__c skuEffort1 = OPRTestFactory.createSkuEffortMap(skuNumbersToMap1, 10, false, phaseByTask);
        SKU_Effort_Map__c skuEffort2 = OPRTestFactory.createSkuEffortMap(skuNumbersToMap2, 10, false, phaseByTask);
        SKU_Effort_Map__c skuEffortCustom = OPRTestFactory.createSkuEffortMap(skuNumbersToMapCustom, 10, false, phaseByTaskCustom);

        // Change estimated hours from custom entries
        List<SKU_Effort_Map_Entry__c> entries = [
            SELECT Id, Estimated_Hours__c
            FROM SKU_Effort_Map_Entry__c 
            WHERE SKU_Effort_Map__c IN 
                (SELECT SKU_to_Effort_Mapping__c 
                 FROM SKU_Number__c 
                 WHERE SKU_Number__c = 'CUSTOM SKU')
        ];
        for(SKU_Effort_Map_Entry__c entry: entries){
            entry.Estimated_Hours__c = 45;
        }

        update entries;

        pse__Proj__c project1 = OPRTestFactory.createSimpleProject();
        Order order1 = OPRTestFactory.createSimpleOrder();

        OrderItem orderItem = [
            SELECT Id, SKU_Number__c, PriceBookEntryId, Item_Class_Description__c, OrderId
            FROM OrderItem
            WHERE OrderId = :order1.Id
            LIMIT 1
        ];
        orderItem.SKU_Number__c = '111-1111';
        update orderItem;

        OrderItem oi = new OrderItem();
        oi.SKU_Description__c = 'SKU Desc 1';
        oi.SKU_Number__c = '222-2222';
        oi.Quantity = 1;
        oi.UnitPrice = 2;
        oi.Item_Class_Description__c = orderItem.Item_Class_Description__c;
        oi.Tie_Number__c = '1';
        oi.OrderId = order1.Id;
        oi.PriceBookEntryId = orderItem.PriceBookEntryId;
        oi.SKU_Cost__c = 2;
        oi.Unit_Selling_Price_USD__c = 85000;
        oi.SKU_Cost_USD__c = 85000;
        insert oi;

        OrderItem oi2 = new OrderItem();
        oi2.SKU_Description__c = 'SKU Desc 1';
        oi2.SKU_Number__c = '444-4444';
        oi2.Quantity = 1;
        oi2.UnitPrice = 2;
        oi2.Item_Class_Description__c = orderItem.Item_Class_Description__c;
        oi2.Tie_Number__c = '1';
        oi2.OrderId = order1.Id;
        oi2.PriceBookEntryId = orderItem.PriceBookEntryId;
        oi2.SKU_Cost__c = 2;
        oi2.Unit_Selling_Price_USD__c = 85000;
        oi2.SKU_Cost_USD__c = 85000;
        insert oi2;

        Order order2 = OPRTestFactory.createSimpleOrder();
        
        OrderItem orderItem2 = [
            SELECT Id, SKU_Number__c, OrderId
            FROM OrderItem
            WHERE OrderId = :order2.Id
            LIMIT 1
        ];
        orderItem2.SKU_Number__c = '333-3333';
        update orderItem2;

        pse__Proj__c project2 = OPRTestFactory.createSimpleProject();
        Order order3 = OPRTestFactory.createSimpleOrder();

        OrderItem orderItem3 = [
            SELECT Id, SKU_Number__c, PriceBookEntryId, Item_Class_Description__c, OrderId
            FROM OrderItem
            WHERE OrderId = :order3.Id
            LIMIT 1
        ];
        orderItem3.Quantity = 3;
        orderItem3.SKU_Number__c = '333-3333';
        update orderItem3;

        /*Map<Id, Id> orderToBeAssociated = new Map<Id, Id>();
        orderToBeAssociated.put(order1.Id, project1.Id);
        orderToBeAssociated.put(order2.Id, project1.Id);
        orderToBeAssociated.put(order3.Id, project2.Id);
	
        OrderAssociationDataContext context = new OrderAssociationDataContext(orderToBeAssociated);
        */
		/*Test.startTest();
        List<Order_Association__e> eventList = new List<Order_Association__e>();
        Order_Association__e event1 = new Order_Association__e(
        	Order_ID__c = orderItem.OrderId,
			Project_ID__c = project1.Id,
			Order_Item_Id__c = orderItem.Id
		);
        eventList.add(event1);
        
        Order_Association__e event2 = new Order_Association__e(
        	Order_ID__c = orderItem2.OrderId,
			Project_ID__c = project1.Id,
			Order_Item_Id__c = orderItem2.Id
		);
        eventList.add(event2);
        
        Order_Association__e event3 = new Order_Association__e(
        	Order_ID__c = orderItem3.OrderId,
			Project_ID__c = project2.Id,
			Order_Item_Id__c = orderItem3.Id
		);
        eventList.add(event3);
        
        Order_Association__e event4 = new Order_Association__e(
        	Order_ID__c = oi.OrderId,
			Project_ID__c = project1.Id,
			Order_Item_Id__c = oi.Id
		);
        eventList.add(event4);
        
        Order_Association__e event5 = new Order_Association__e(
        	Order_ID__c = oi2.OrderId,
			Project_ID__c = project1.Id,
			Order_Item_Id__c = oi2.Id
		);
        eventList.add(event5);
		
        
        
        OrderAssociationDataContext context = new OrderAssociationDataContext(eventList);
        OrderAssociationTaskCreation.createTasks(context);
        Test.stopTest();

        // Project 1
        List<pse__Project_Task__c> projectTasksProject1 = [
            SELECT Id, Name, pse__Parent_Task__c, pse__Estimated_Hours__c
            FROM pse__Project_Task__c
            WHERE pse__Project__c = :project1.Id
        ];

        Map<String, pse__Project_Task__c> topTaskMapProject1 = new Map<String, pse__Project_Task__c>();
        Map<String, pse__Project_Task__c> childTaskMapProject1 = new Map<String, pse__Project_Task__c>();

        for(pse__Project_Task__c task: projectTasksProject1){
            if(task.pse__Parent_Task__c == null){
                topTaskMapProject1.put(task.Name, task);
            }
            else{
                childTaskMapProject1.put(task.Name, task);
            }
        }

        System.assertEquals(4, topTaskMapProject1.values().size(), 'It should have 4 top tasks for the first project');
        System.assert(topTaskMapProject1.get('Initiate') != null, 'It should a top task called Initiate in the first project');
        System.assert(topTaskMapProject1.get('Execute') != null, 'It should a top task called Execute in the first project');
        System.assert(topTaskMapProject1.get('Plan') != null, 'It should a top task called Plan in the first project');
        System.assert(topTaskMapProject1.get('Close') != null, 'It should a top task called Close in the first project');
       
        System.assertEquals(5, childTaskMapProject1.values().size(), 'It should have 5 child tasks for the first project');
        System.assertEquals(30, childTaskMapProject1.get('Configuration').pse__Estimated_Hours__c, 'It should have a child task called Configuration with 30 estimated hours for the first project');
        System.assertEquals(75, childTaskMapProject1.get('Scoping').pse__Estimated_Hours__c, 'It should have a child task called Scoping with 75 estimated hours for the first project');
        System.assertEquals(75, childTaskMapProject1.get('Planning').pse__Estimated_Hours__c, 'It should have a child task called Planning with 75 estimated hours for the first project');
        System.assertEquals(45, childTaskMapProject1.get('Physical Installation').pse__Estimated_Hours__c, 'It should have a child task called Physical Installation with 45 estimated hours for the first project');
        System.assertEquals(45, childTaskMapProject1.get('Delivery').pse__Estimated_Hours__c, 'It should have a child task called Delivery with 45 estimated hours for the first project');

        // Project 2
        List<pse__Project_Task__c> projectTasksProject2 = [
            SELECT Id, Name, pse__Parent_Task__c, pse__Estimated_Hours__c
            FROM pse__Project_Task__c
            WHERE pse__Project__c = :project2.Id
        ];

        Map<String, pse__Project_Task__c> topTaskMapProject2 = new Map<String, pse__Project_Task__c>();
        Map<String, pse__Project_Task__c> childTaskMapProject2 = new Map<String, pse__Project_Task__c>();

        for(pse__Project_Task__c task: projectTasksProject2){
            if(task.pse__Parent_Task__c == null){
                topTaskMapProject2.put(task.Name, task);
            }
            else{
                childTaskMapProject2.put(task.Name, task);
            }
        }

        System.assertEquals(3, topTaskMapProject2.values().size(), 'It should have 4 top tasks for the second project');
        System.assert(topTaskMapProject2.get('Initiate') != null, 'It should a top task called Initiate in the second project');
        System.assert(topTaskMapProject2.get('Execute') != null, 'It should a top task called Execute in the second project');
        System.assert(topTaskMapProject2.get('Plan') != null, 'It should a top task called Plan in the second project');
       
        System.assertEquals(3, childTaskMapProject2.values().size(), 'It should have 5 child tasks for the second project');
        System.assertEquals(30, childTaskMapProject2.get('Configuration').pse__Estimated_Hours__c, 'It should have a child task called Configuration with 30 estimated hours for the second project');
        System.assertEquals(30, childTaskMapProject2.get('Scoping').pse__Estimated_Hours__c, 'It should have a child task called Scoping with 75 estimated hours for the second project');
        System.assertEquals(30, childTaskMapProject2.get('Planning').pse__Estimated_Hours__c, 'It should have a child task called Planning with 75 estimated hours for the second project');
        
        // Project task skills
        List<Project_Task_Skill__c> projectTaskSkillsProject1 = [
            SELECT Id, Skill_Certification__r.Name, Project_Task__r.Name, Project_Task__r.pse__project__c, Project_Task__c, Skill_Certification__c
            FROM Project_Task_Skill__c
            WHERE Project_Task__c IN :childTaskMapProject1.values()
        ];
        System.assertEquals(10, projectTaskSkillsProject1.size(), 'It should have 10 project task skills for the first project');
        
        List<Project_Task_Skill__c> projectTaskSkillsProject2 = [
            SELECT Id
            FROM Project_Task_Skill__c
            WHERE Project_Task__c IN :childTaskMapProject2.values()
        ];
        System.assertEquals(6, projectTaskSkillsProject2.size(), 'It should have 6 project task skills for the second project');

        // Project Task Sku Effort Mapping entry
        List<Project_Task_SKU_Effort_Mapping_Entry__c> projecTaskSkuEntriesProject1 = [
            SELECT Id
            FROM Project_Task_SKU_Effort_Mapping_Entry__c
            WHERE Project_Task__c IN :childTaskMapProject1.values()
        ];
        System.assertEquals(10, projecTaskSkuEntriesProject1.size(), 'It should have 10 project task sku effort mappings for the first project');
        
        List<Project_Task_SKU_Effort_Mapping_Entry__c> projecTaskSkuEntriesProject2 = [
            SELECT Id
            FROM Project_Task_SKU_Effort_Mapping_Entry__c
            WHERE Project_Task__c IN :childTaskMapProject2.values()
        ];
        System.assertEquals(3, projecTaskSkuEntriesProject2.size(), 'It should have 3 project task sku effort mappings for the second project');
        
        // Order_Item_Sku_Effort_Map__c
        List<Order_Item_Sku_Effort_Map__c> orderItemSkuMap = [
            SELECT Id, Project_Task__c
            FROM Order_Item_Sku_Effort_Map__c
        ];
        System.assertEquals(16, orderItemSkuMap.size(), 'It should have 16 order item sku effort mappings');
    } */

    /**
    * @description It should create tasks for one project with existing task.
    * @author Leonardo Santos | 2/18/2020 
    * @return void 
    **/
    @isTest
    static void shouldCreateTasksWithExistingTasks(){
        
        //Login with Integration User Profile to create Account as a validation rule is in place to prevent Account creation by Other user in SFDC.
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){ 
            List<String> skuNumbersToMap1 = new List<String>{'111-1111', '222-2222'};
            Map<String, String> phaseByTask = new Map<String, String>();
            phaseByTask.put('Scoping', 'Initiate');
            phaseByTask.put('Configuration', 'Execute');
            phaseByTask.put('Planning', 'Plan');
            
            SKU_Effort_Map__c skuEffort1 = OPRTestFactory.createSkuEffortMap(skuNumbersToMap1, 10, false, phaseByTask);
            
            pse__Proj__c project1 = OPRTestFactory.createSimpleProject();
            Order order1 = OPRTestFactory.createSimpleOrder();
            
            OrderItem orderItem = [
                SELECT Id, SKU_Number__c, PriceBookEntryId, Item_Class_Description__c,OrderId
                FROM OrderItem
                WHERE OrderId = :order1.Id
                LIMIT 1
            ];
            orderItem.SKU_Number__c = '111-1111';
            update orderItem;
            
            /* Creating tasks */
            pse__Project_Task__c topTask = new pse__Project_Task__c();
            topTask.Name = 'Plan';
            topTask.pse__project__c = project1.Id;
            insert topTask;
            
            pse__Project_Task__c childTask = new pse__Project_Task__c();
            childTask.Name = 'Planning';
            childTask.pse__project__c = project1.Id;
            childTask.pse__Parent_Task__c = topTask.Id;
            childTask.pse__Estimated_Hours__c = 80;
            insert childTask;
            
            SKU_Effort_Map_Entry__c entry = [
                SELECT Id
                FROM SKU_Effort_Map_Entry__c
                WHERE SKU_Effort_Map__c = :skuEffort1.Id
                AND Name__c = 'Planning'
                LIMIT 1
            ];
            
            Skill_SKU_Effort_Map_Entry__c existingSkuSkill = [
                SELECT Id, Skill_Certification__c
                FROM Skill_SKU_Effort_Map_Entry__c
                WHERE SKU_Effort_Map_Entry__c = :entry.Id
                LIMIT 1
            ];
            
            Project_Task_SKU_Effort_Mapping_Entry__c taskSkuEntry = new Project_Task_SKU_Effort_Mapping_Entry__c();
            taskSkuEntry.SKU_Effort_Mapping_Entry__c = entry.Id;
            taskSkuEntry.Project_Task__c = childTask.Id;
            taskSkuEntry.SKU_Quantity__c = 1;
            insert taskSkuEntry;
            
            Project_Task_Skill__c projectTaskSkill = new Project_Task_Skill__c();
            projectTaskSkill.Project_Task__c = childTask.Id;
            projectTaskSkill.Skill_Certification__c = existingSkuSkill.Skill_Certification__c;
            projectTaskSkill.Minimum_Rate__c = '1';
            insert projectTaskSkill;
            
            Order_Item_Sku_Effort_Map__c orderItemSkuEffortMap = new Order_Item_Sku_Effort_Map__c();
            orderItemSkuEffortMap.Order_Product__c = orderItem.Id;
            orderItemSkuEffortMap.SKU_to_Effort_Mapping__c = skuEffort1.Id;
            orderItemSkuEffortMap.Project_Task__c = childTask.Id;
            insert orderItemSkuEffortMap;
            
            /*Map<Id, Id> orderToBeAssociated = new Map<Id, Id>();
orderToBeAssociated.put(order1.Id, project1.Id);



OrderAssociationDataContext context = new OrderAssociationDataContext(orderToBeAssociated);*/
            
            List<Order_Association__e> eventList = new List<Order_Association__e>();
            Order_Association__e event1 = new Order_Association__e(
                Order_ID__c = orderItem.OrderId,
                Project_ID__c = project1.Id,
                Order_Item_Id__c = orderItem.Id
            );
            eventList.add(event1);
            
            
            
            Test.startTest();
            OrderAssociationDataContext context = new OrderAssociationDataContext(eventList);
            OrderAssociationTaskCreation.createTasks(context);
            Test.stopTest();
            
            // Top tasks
            List<pse__Project_Task__c> projectTasks = [
                SELECT Id, Name, pse__Parent_Task__c, pse__Estimated_Hours__c
                FROM pse__Project_Task__c
                WHERE pse__Project__c = :project1.Id
            ];
            
            Map<String, pse__Project_Task__c> topTaskMap = new Map<String, pse__Project_Task__c>();
            Map<String, pse__Project_Task__c> childTaskMap = new Map<String, pse__Project_Task__c>();
            
            for(pse__Project_Task__c task: projectTasks){
                if(task.pse__Parent_Task__c == null){
                    topTaskMap.put(task.Name, task);
                }
                else{
                    childTaskMap.put(task.Name, task);
                }
            }
            
            System.assertEquals(3, topTaskMap.values().size(), 'It should have 3 top tasks');
            System.assert(topTaskMap.get('Initiate') != null, 'It should a top task called Initiate');
            System.assert(topTaskMap.get('Execute') != null, 'It should a top task called Execute');
            System.assert(topTaskMap.get('Plan') != null, 'It should a top task called Plan');
            
            System.assertEquals(3, childTaskMap.values().size(), 'It should have 3 child tasks');
            System.assertEquals(10, childTaskMap.get('Scoping').pse__Estimated_Hours__c, 'It should have a child task called Scoping with 20 estimated hours');
            System.assertEquals(10, childTaskMap.get('Configuration').pse__Estimated_Hours__c, 'It should have a child task called Configuration with 20 estimated hours');
            System.assertEquals(90, childTaskMap.get('Planning').pse__Estimated_Hours__c, 'It should have a child task called Planning with 90 estimated hours');
            
            // Project task skills
            List<Project_Task_Skill__c> projectTaskSkills = [
                SELECT Id
                FROM Project_Task_Skill__c
                WHERE Project_Task__c IN :childTaskMap.values()
            ];
            System.assertEquals(6, projectTaskSkills.size(), 'It should have 6 project tasks skills');
            
            // Project Task Sku Effort Mapping entry
            List<Project_Task_SKU_Effort_Mapping_Entry__c> projecTaskSkuEntries = [
                SELECT Id, SKU_Effort_Mapping_Entry__r.Name, Project_Task__r.Name
                FROM Project_Task_SKU_Effort_Mapping_Entry__c
                WHERE Project_Task__c IN :childTaskMap.values()
            ];
            System.assertEquals(4, projecTaskSkuEntries.size(), 'It should have 4 project task sku effort mapping entries');
            
            // Order_Item_Sku_Effort_Map__c
            List<Order_Item_Sku_Effort_Map__c> orderItemSkuMap = [
                SELECT Id
                FROM Order_Item_Sku_Effort_Map__c
                WHERE Project_Task__c IN :childTaskMap.values()
            ];
            System.assertEquals(4, orderItemSkuMap.size(), 'It should have 4 order item sku effort mappings'); 
        }
    }
}