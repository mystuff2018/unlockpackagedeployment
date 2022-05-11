@istest
public with sharing class OrderDisassociationDealTypeTest {
    // @testSetup
    // static void makeData(){
        
        // List<Item_Class__c> itemClassList = new List<Item_Class__c>();
        // List<pse__Practice__c> practiceList = new List<pse__Practice__c>();
        
        // pse__Practice__c practice1 = new pse__Practice__c();
        // practice1.Name = 'Custom Practice Test';
        // practice1.Order_Association_Approval_Phase__c = 'Execute';
        // practiceList.add(practice1);
        
        // pse__Practice__c practice2 = new pse__Practice__c();
        // practice2.Name = 'Custom Practice Test2';
        // practice2.Order_Association_Approval_Phase__c = 'Execute';
        // practiceList.add(practice2);
        // insert practiceList;
        
        // Item_Class__c itemClass1 = new Item_Class__c();
        // itemClass1.Item_Class_Description__c = 'SVC EDT INSTLN';
        // itemClass1.Practice__c = practice1.Id;
        // itemClass1.Key_Practice__c = true;
        // itemClassList.add(itemClass1);
        
        // Item_Class__c itemClass2 = new Item_Class__c();
        // itemClass2.Item_Class_Description__c = 'SVC EIS SVCs';
        // itemClass2.Practice__c = practice1.Id;
        // itemClass2.Key_Practice__c = true;
        // itemClassList.add(itemClass2);
        // insert itemClassList;
        
        // List<String> skuNumbersToMap1 = new List<String>{'111-1111', '222-2222'};
        // List<String> skuNumbersToMap2 = new List<String>{'333-3333'};
        // List<String> skuNumbersToMapCustom = new List<String>{'CUSTOM SKU'};
                
        // Map<String, String> phaseByTask = new Map<String, String>();
        // phaseByTask.put('Scoping', 'Initiate');
        // phaseByTask.put('Configuration', 'Execute');
        // phaseByTask.put('Planning', 'Plan');
        
        // Map<String, String> phaseByTaskCustom = new Map<String, String>();
        // phaseByTaskCustom.put('Scoping', 'Initiate');
        // phaseByTaskCustom.put('Physical Installation', 'Execute');
        // phaseByTaskCustom.put('Planning', 'Plan');
        // phaseByTaskCustom.put('Delivery', 'Close');
        
        // SKU_Effort_Map__c skuEffort1 = OPRTestFactory.createSkuEffortMap(skuNumbersToMap1, 10, false, phaseByTask);
        // SKU_Effort_Map__c skuEffort2 = OPRTestFactory.createSkuEffortMap(skuNumbersToMap2, 10, false, phaseByTask);
        // SKU_Effort_Map__c skuEffortCustom = OPRTestFactory.createSkuEffortMap(skuNumbersToMapCustom, 10, false, phaseByTaskCustom);

        // update skuEffortCustom;
    // }

    // /**
    // * @description If the project has just standard skus, deal type should be 'Standard'
    // * @author Filipe Hoffmeister | 4/29/2020
    // * @param  
    // * @return void 
    // **/
    // @isTest
    // static void projectShouldBeStandard(){
        // //Create Project
        // pse__Proj__c project1 = OPRTestFactory.createSimpleProject();
        
        // //Create order
        // Order order1 = OPRTestFactory.createSimpleOrder();
        
        // //Create order
        // Order order2 = OPRTestFactory.createSimpleOrder();
        
        // OrderItem orderItem1 = createOrderItem(order1.Id,project1.Id,'111-1111', 'SVC EIS SVCs');

        // OrderItem orderItem2 = createOrderItem(order2.Id,project1.Id,'111-1111', 'SVC EIS SVCs');
        
        // System.debug('orderItem2.Project__c: '+ orderItem2.Project__c);
               
        // Set<Id> orderIds = new Set<Id>();
        // orderIds.add(order2.Id);
        // System.debug('order2.Id: '+ order2.Id);
	
        // OrderDisassociationDataContext context = new OrderDisassociationDataContext(orderIds);
        // OrderDisassociationDealType.updateDealType(context);

        // pse__Proj__c project = context.projectMap.get(project1.Id);
        // System.assertEquals('Standard', project.Deal_Type__c, 'Deal type should be Standard'); 
    // }

    // /**
    // * @description If the project has at least one custom sku, deal type should be 'Custom'
    // * @author Filipe Hoffmeister | 4/29/2020
    // * @param  
    // * @return void 
    // **/
    // @isTest
    // static void projectShouldBeCustom(){
        // //Create Project
        // pse__Proj__c project1 = OPRTestFactory.createSimpleProject();
        
        // //Create order
        // Order order1 = OPRTestFactory.createSimpleOrder();
        
        // //Create order
        // Order order2 = OPRTestFactory.createSimpleOrder();
        
        // OrderItem orderItem = createOrderItem(order1.Id,project1.Id,'444-4444', 'SVC EIS SVCs');
        // OrderItem orderItemCustom = createOrderItem(order2.Id,project1.Id,'444-XXXX', 'SVC EIS SVCs');
              
	    // Set<Id> orderIds = new Set<Id>();
        // orderIds.add(order1.Id);        
        // OrderDisassociationDataContext context = new OrderDisassociationDataContext(orderIds);
        // OrderDisassociationDealType.updateDealType(context);
        
        // pse__Proj__c project = context.projectMap.get(project1.Id);
        // System.assertEquals('Custom', project.Deal_Type__c, 'Deal type should be Custom');

    // }

    // private static OrderItem createOrderItem(Id orderId, Id projectId, String skuNumber, String itemClassDesc) {        

        // // Order Product
        // Product2 product = new Product2();
        // product.Name='Product Test';
        // insert product;

        // PricebookEntry pricebookEntry = new PricebookEntry();
        // pricebookEntry.Pricebook2Id = Test.getStandardPricebookId();
        // pricebookEntry.Product2Id = product.Id;
        // pricebookEntry.UseStandardPrice = false; 
        // pricebookEntry.UnitPrice = 1;
        // insert pricebookEntry;

        // // Order Item
        // OrderItem oi = new OrderItem();
        // oi.SKU_Description__c = itemClassDesc;
        // oi.Item_Class_Description__c = itemClassDesc;
        // oi.OrderId = orderId;
        // oi.SKU_Number__c = skuNumber;
        // oi.PriceBookEntryId = priceBookEntry.Id;
        // oi.Quantity = 1;
        // oi.UnitPrice = 1;
        // oi.Tie_Number__c = '1';
        // oi.SKU_Cost__c = 1;
        // oi.SKU_Cost_Local__c = 1;
        // oi.SKU_Cost_USD__c = 1;
        // oi.Unit_Selling_Price_Local__c = 1;
        // oi.Unit_Selling_Price_USD__c = 1;
        // oi.Project__c = projectId;
        // insert oi;

        // return oi;
    // }
}