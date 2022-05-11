@isTest
public class OrderAssociationDealTypeTest {
    
    @testSetup
    static void makeData(){
        //Login with Integration User Profile to create Account as a validation rule is in place to prevent Account creation by Other user in SFDC.
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){         
            List<Item_Class__c> itemClassList = new List<Item_Class__c>();
            pse__Proj__c projectTemplate = TestDataUtility.createProject(true);
            List<pse__Practice__c> practiceList = new List<pse__Practice__c>();
            
            pse__Practice__c practice1 = new pse__Practice__c();
            practice1.Name = 'Custom Practice Test';
            practice1.Order_Association_Approval_Phase__c = 'Execute';
            practice1.Standard_Project_Template__c = projectTemplate.Id;
            practiceList.add(practice1);
            
            pse__Practice__c practice2 = new pse__Practice__c();
            practice2.Name = 'Custom Practice Test2';
            practice2.Order_Association_Approval_Phase__c = 'Execute';
            practice2.Standard_Project_Template__c = projectTemplate.Id;
            practiceList.add(practice2);
            insert practiceList;
            
            Item_Class__c itemClass1 = new Item_Class__c();
            itemClass1.Item_Class_Description__c = 'SVC EDT INSTLN';
            itemClass1.Practice__c = practice1.Id;
            itemClass1.Key_Practice__c = true;
            itemClassList.add(itemClass1);
            
            Item_Class__c itemClass2 = new Item_Class__c();
            itemClass2.Item_Class_Description__c = 'SVC EIS SVCs';
            itemClass2.Practice__c = practice1.Id;
            itemClass2.Key_Practice__c = true;
            itemClassList.add(itemClass2);
            insert itemClassList;
            
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
            
            update skuEffortCustom;
        }
    }

    /**
    * @description If the project has just standard skus, deal type should be 'Standard'
    * @author Leonardo Santos & Magaiver Oliveira | 4/24/2020
    * @param  
    * @return void 
    **/
    @isTest
    static void projectShouldBeStandard(){
        //Login with Integration User Profile to create Account as a validation rule is in place to prevent Account creation by Other user in SFDC.
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){
            Test.startTest();
            //Create Project
            pse__Proj__c project1 = OPRTestFactory.createSimpleProject();
            
            //Create order
            Order order1 = OPRTestFactory.createSimpleOrder();
            
            //Create Order Items
            OrderItem orderItem = [
                SELECT Id, SKU_Number__c, PriceBookEntryId, Item_Class_Description__c
                FROM OrderItem
                WHERE OrderId = :order1.Id
                LIMIT 1
            ];
            orderItem.SKU_Number__c = '111-1111';
            orderItem.Item_Class_Description__c = 'SVC EIS SVCs';
            update orderItem;
            
            Order_Association__e event = new Order_Association__e(
                Order_ID__c = order1.Id,
                Project_ID__c = project1.Id,
                Order_Item_Id__c = orderItem.Id
            );
            
            List<Order_Association__e> eventList = new List<Order_Association__e>{event};
                OrderAssociationDataContext context = new OrderAssociationDataContext(eventList);
            
            
            OrderAssociationDealType.updateDealType(context);
            Test.stopTest();
            
            pse__Proj__c project = context.projectMap.get(project1.Id);
            System.assertEquals('Standard', project.Deal_Type__c, 'Deal type should be Standard'); 
        }
    }

    /**
    * @description If the project has at least one custom sku, deal type should be 'Custom'
    * @author Leonardo Santos & Magaiver Oliveira | 4/24/2020
    * @param  
    * @return void 
    **/
    @isTest
    static void projectShouldBeCustom(){
        //Login with Integration User Profile to create Account as a validation rule is in place to prevent Account creation by Other user in SFDC.
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){
            Test.startTest();
            //Create Project
            pse__Proj__c project1 = OPRTestFactory.createSimpleProject();
            
            //Create order
            Order order1 = OPRTestFactory.createSimpleOrder();
            
            //Create Order Items
            OrderItem orderItem = [
                SELECT Id, SKU_Number__c, PriceBookEntryId, Item_Class_Description__c
                FROM OrderItem
                WHERE OrderId = :order1.Id
                LIMIT 1
            ];
            orderItem.SKU_Number__c = '444-4444'; // Standard sku
            orderItem.Item_Class_Description__c = 'SVC EIS SVCs';
            update orderItem;
            
            OrderItem orderItemCustom = createOrderItem(order1.Id, project1.Id, '444-XXXX', 'SVC EIS SVCs'); // Custom Sku
            
            Order_Association__e eventSkuStandard = new Order_Association__e(
                Order_ID__c = order1.Id,
                Project_ID__c = project1.Id,
                Order_Item_Id__c = orderItem.Id
            );
            
            Order_Association__e eventSkuCustom = eventSkuStandard.clone(false, true, false, false);
            eventSkuCustom.Order_Item_Id__c = orderItemCustom.Id;
            
            List<Order_Association__e> eventList = new List<Order_Association__e>{eventSkuStandard, eventSkuCustom};
                OrderAssociationDataContext context = new OrderAssociationDataContext(eventList);
            
            
            OrderAssociationDealType.updateDealType(context);
            Test.stopTest();
            
            pse__Proj__c project = context.projectMap.get(project1.Id);
            System.assertEquals('Custom', project.Deal_Type__c, 'Deal type should be Custom');
        }
    }

    /**
    * @description If the project already has a order item tied and te project is standard, 
    *              when associate a custom sku the project should change the deal type do custom.
    * @author Leonardo Santos & Magaiver Oliveira | 4/24/2020
    * @param  
    * @return void 
    **/
    @isTest
    static void projectShouldChangeToCustom(){
        //Login with Integration User Profile to create Account as a validation rule is in place to prevent Account creation by Other user in SFDC.
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){
            Test.startTest();
        //Create Project
        pse__Proj__c project1 = OPRTestFactory.createSimpleProject();

        //Create order
        Order order1 = OPRTestFactory.createSimpleOrder();
        
        //Create Order Items
        OrderItem orderItem = [
            SELECT Id, SKU_Number__c, PriceBookEntryId, Item_Class_Description__c
            FROM OrderItem
            WHERE OrderId = :order1.Id
            LIMIT 1
        ];
        orderItem.SKU_Number__c = '444-4444'; // Standard sku
        orderItem.Item_Class_Description__c = 'SVC EIS SVCs';
        orderItem.Project__c = project1.Id;
        update orderItem;

        OrderItem orderItemCustom = createOrderItem(order1.Id, null, '444-XXXX', 'SVC EIS SVCs'); // Custom sku
               
        Order_Association__e event = new Order_Association__e(
            Order_ID__c = order1.Id,
            Project_ID__c = project1.Id,
            Order_Item_Id__c = orderItemCustom.Id
        );
        
        List<Order_Association__e> eventList = new List<Order_Association__e>{event};
        OrderAssociationDataContext context = new OrderAssociationDataContext(eventList);
        
        pse__Proj__c project = context.projectMap.get(project1.Id);
        System.assertEquals('Standard', project.Deal_Type__c, 'Deal type should be Standard');

        
        OrderAssociationDealType.updateDealType(context);
        Test.stopTest();
        
        System.assertEquals('Custom', project.Deal_Type__c, 'Deal type should be Custom');
        }
    }
    
    private static OrderItem createOrderItem(Id orderId, Id projectId, String skuNumber, String itemClassDesc) {        

        // Order Product
        Product2 product = new Product2();
        product.Name='Product Test';
        insert product;
		
		List<PricebookEntry> pbentry = [Select ID from PricebookEntry where Product2Id =:product.Id limit 1];
		if(pbentry == null || pbentry.size() == 0){
			PricebookEntry pricebookEntry = new PricebookEntry();
			pricebookEntry.Pricebook2Id = Test.getStandardPricebookId();
			pricebookEntry.Product2Id = product.Id;
			pricebookEntry.UseStandardPrice = false; 
			pricebookEntry.UnitPrice = 1;
			insert pricebookEntry;
			pbentry.add(pricebookEntry);
		}	

        // Order Item
        OrderItem oi = new OrderItem();
        oi.SKU_Description__c = itemClassDesc;
        oi.Item_Class_Description__c = itemClassDesc;
        oi.OrderId = orderId;
        oi.SKU_Number__c = skuNumber;
        oi.PriceBookEntryId = pbentry[0].Id;
        oi.Quantity = 1;
        oi.UnitPrice = 1;
        oi.Tie_Number__c = '1';
        oi.SKU_Cost__c = 1;
        oi.SKU_Cost_Local__c = 1;
        oi.SKU_Cost_USD__c = 1;
        oi.Unit_Selling_Price_Local__c = 1;
        oi.Unit_Selling_Price_USD__c = 1;
        oi.Project__c = projectId;
        insert oi;

        return oi;
    }
}