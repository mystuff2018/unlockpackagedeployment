@isTest()
public with sharing class OrderAssociationProjectComplexityTest {

    @TestSetup
    static void setup(){
        //Login with Integration User Profile to create Account as a validation rule is in place to prevent Account creation by Other user in SFDC.
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){ 
            // setup Project Complexity Mapping
            List<Project_Complexity_Mapping__c> projComplexityMappings = new List<Project_Complexity_Mapping__c>();
            
            projComplexityMappings.add(new Project_Complexity_Mapping__c (
                Overall_Project_Complexity__c = 'Low',
                PM_Complexity__c = 'Low',
                Revenue_Threshold__c = 'Low'
            )); 
            
            projComplexityMappings.add(new Project_Complexity_Mapping__c (
                Overall_Project_Complexity__c = 'Medium',
                PM_Complexity__c = 'Medium',
                Revenue_Threshold__c = 'Medium'
            ));
            
            projComplexityMappings.add(new Project_Complexity_Mapping__c (
                Overall_Project_Complexity__c = 'High',
                PM_Complexity__c = 'High',
                Revenue_Threshold__c = 'High'
            ));
            
            projComplexityMappings.add(new Project_Complexity_Mapping__c (
                Overall_Project_Complexity__c = 'High',
                PM_Complexity__c = 'High',
                Revenue_Threshold__c = 'Medium'
            ));
            
            insert projComplexityMappings;
            
            List<String> skuNumbersToMap = new List<String>{'123-456'};
                Map<String, String> phaseByTask = new Map<String, String>();
            phaseByTask.put('Scoping', 'Initiate');
            phaseByTask.put('Configuration', 'Execute');
            phaseByTask.put('Planning', 'Plan');
            SKU_Effort_Map__c skuEffort2 = OPRTestFactory.createSkuEffortMap(skuNumbersToMap, 10, false, phaseByTask);
            
            // Setup Project Complexity Threshold
            List<Project_Complexity_Threshold__c> projComplexities = new List<Project_Complexity_Threshold__c>();
            
            projComplexities.add(new Project_Complexity_Threshold__c (
                Name = 'US',
                Low_Threshold__c = 3500,
                High_Threshold__c = 11500
            ));
            
            insert projComplexities;       
            
            // Create Order
            createOrderWithOrderItemSkuCost('6543200', 0);
            createOrderWithOrderItemSkuCost('6543210', 1000);
            createOrderWithOrderItemSkuCost('6543211', 1500);
            createOrderWithOrderItemSkuCost('6543212', 10000);
        }
    }
    
    @isTest              
    static void shouldCalculateProjectComplexityAsLow() {
        //Login with Integration User Profile to create Account as a validation rule is in place to prevent Account creation by Other user in SFDC.
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){ 
            // Arrange
            pse__Proj__c project = createProject(null, null);
            List<Order> orders = [SELECT Id, (Select Id From OrderItems) FROM Order WHERE OrderNumber__c IN ('6543210', '6543211')];
            
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
            
            // Act
            Test.startTest();
            // the project complexity needs to run after the project budget;
            OrderAssociationBudget.createProjectBudget(context);
            OrderAssociationProjectComplexity.calculateProjectComplexity(context);
            Test.stopTest();
            
            // Assert
            System.assertEquals('Low', context.projectMap.get(project.Id).Project_Complexity__c, 'It should be a Project Complexity Low.');
        }
    }
    
    @isTest              
    static void shouldCalculateProjectComplexityAsMediumWithExistentBudgets() {
        //Login with Integration User Profile to create Account as a validation rule is in place to prevent Account creation by Other user in SFDC.
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){ 
            // Arrange
            pse__Proj__c project = createProject(null, null);
            List<Order> orders = [SELECT Id, (Select Id From OrderItems) FROM Order WHERE OrderNumber__c IN ('6543210', '6543211')];
            
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
            
            List<SKU_Effort_Map_Entry__c> listEntries = new List<SKU_Effort_Map_Entry__c>();
            for (SKU_Effort_Map_Entry__c entry : [SELECT id, Project_Complexity_Tier__c from SKU_Effort_Map_Entry__c where SKU_Effort_Map__c in (Select SKU_to_Effort_Mapping__c from Sku_number__c where Sku_number__c = '123-456')]) {
                entry.Project_Complexity_Tier__c = 'Medium';
                listEntries.add(entry);
            }
            if (listEntries.size()>0) {
                update listEntries;
            }
            
            OrderAssociationDataContext context = new OrderAssociationDataContext(eventList);
            
            // Act
            Test.startTest();
            // the project complexity needs to run after the project budget;
            OrderAssociationBudget.createProjectBudget(context);
            OrderAssociationProjectComplexity.calculateProjectComplexity(context);
            context.save();
            
            OrderAssociationDataContext context2 = new OrderAssociationDataContext(eventList);
            OrderAssociationBudget.createProjectBudget(context2);
            OrderAssociationProjectComplexity.calculateProjectComplexity(context2);
            Test.stopTest();
            
            
            
            // Assert
            System.assertEquals('Medium', context2.projectMap.get(project.Id).Project_Complexity__c, 'It should be a Project Complexity Medium.');
        }
    }
    
    @isTest              
    static void shouldCalculateProjectComplexityAsLowInCustomProject() {
        //Login with Integration User Profile to create Account as a validation rule is in place to prevent Account creation by Other user in SFDC.
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){ 
            // Arrange
            pse__Proj__c project = createProject(null, 'Custom');
            List<Order> orders = [SELECT Id, (Select Id From OrderItems) FROM Order WHERE OrderNumber__c IN ('6543210', '6543211')];
            
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
            
            // Act
            Test.startTest();
            // the project complexity needs to run after the project budget;
            OrderAssociationBudget.createProjectBudget(context);
            OrderAssociationProjectComplexity.calculateProjectComplexity(context);
            Test.stopTest();
            
            // Assert
            System.assertEquals('Low', context.projectMap.get(project.Id).Project_Complexity__c, 'It should be a Project Complexity Low In a Custom Project.');
        }
    }
    
    @isTest              
    static void shouldCalculateProjectComplexityAsHigh() {
        //Login with Integration User Profile to create Account as a validation rule is in place to prevent Account creation by Other user in SFDC.
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){ 
            // Arrange
            
            pse__Proj__c project = createProject(null, null);
            List<Order> orders = [SELECT Id, (Select Id From OrderItems) FROM Order WHERE OrderNumber__c IN ('6543211', '6543212')];
            
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
            
            List<SKU_Effort_Map_Entry__c> listEntries = new List<SKU_Effort_Map_Entry__c>();
            for (SKU_Effort_Map_Entry__c entry : [SELECT id, Project_Complexity_Tier__c from SKU_Effort_Map_Entry__c where SKU_Effort_Map__c in (Select SKU_to_Effort_Mapping__c from Sku_number__c where Sku_number__c = '123-456')]) {
                entry.Project_Complexity_Tier__c = 'High';
                listEntries.add(entry);
            }
            if (listEntries.size()>0) {
                update listEntries;
            }
            
            OrderAssociationDataContext context = new OrderAssociationDataContext(eventList);
            
            // Act
            Test.startTest();
            // the project complexity needs to run after the project budget;
            OrderAssociationBudget.createProjectBudget(context);
            OrderAssociationProjectComplexity.calculateProjectComplexity(context);
            Test.stopTest();
            
            System.debug('context.projectMap: ' + context.projectMap);
            // Assert
            System.assertEquals('High', context.projectMap.get(project.Id).Project_Complexity__c, 'It should be a Project Complexity High.');
        }
    }
    
    @isTest              
    static void shouldCalculateProjectComplexityAsMedium() {
        //Login with Integration User Profile to create Account as a validation rule is in place to prevent Account creation by Other user in SFDC.
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){ 
            // Arrange
            
            pse__Proj__c project = createProject(null, null);
            List<Order> orders = [SELECT Id, (Select Id From OrderItems) FROM Order WHERE OrderNumber__c IN ('6543210', '6543212')];
            
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
            
            List<SKU_Effort_Map_Entry__c> listEntries = new List<SKU_Effort_Map_Entry__c>();
            for (SKU_Effort_Map_Entry__c entry : [SELECT id, Project_Complexity_Tier__c from SKU_Effort_Map_Entry__c where SKU_Effort_Map__c in (Select SKU_to_Effort_Mapping__c from Sku_number__c where Sku_number__c = '123-456')]) {
                entry.Project_Complexity_Tier__c = 'Medium';
                listEntries.add(entry);
            }
            if (listEntries.size()>0) {
                update listEntries;
            }
            
            OrderAssociationDataContext context = new OrderAssociationDataContext(eventList);
            
            // Act
            Test.startTest();
            // the project complexity needs to run after the project budget;
            OrderAssociationBudget.createProjectBudget(context);
            OrderAssociationProjectComplexity.calculateProjectComplexity(context);
            Test.stopTest();
            
            // Assert
            System.assertEquals('Medium', context.projectMap.get(project.Id).Project_Complexity__c, 'It should be a Project Complexity Medium.');
        }
    }
    
    @isTest              
    static void shouldCalculateProjectComplexityFromPMComplexity() {
        //Login with Integration User Profile to create Account as a validation rule is in place to prevent Account creation by Other user in SFDC.
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){ 
            // Arrange
            
            pse__Proj__c project = createProject('High', null);
            List<Order> orders = [SELECT Id, (Select Id From OrderItems) FROM Order WHERE OrderNumber__c IN ('6543210', '6543212')];
            
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
            
            List<SKU_Effort_Map_Entry__c> listEntries = new List<SKU_Effort_Map_Entry__c>();
            for (SKU_Effort_Map_Entry__c entry : [SELECT id, Project_Complexity_Tier__c from SKU_Effort_Map_Entry__c where SKU_Effort_Map__c in (Select SKU_to_Effort_Mapping__c from Sku_number__c where Sku_number__c = '123-456')]) {
                entry.Project_Complexity_Tier__c = 'High';
                listEntries.add(entry);
            }
            if (listEntries.size()>0) {
                update listEntries;
            }
            
            OrderAssociationDataContext context = new OrderAssociationDataContext(eventList);
            
            // Act
            Test.startTest();
            // the project complexity needs to run after the project budget;
            OrderAssociationBudget.createProjectBudget(context);
            OrderAssociationProjectComplexity.calculateProjectComplexity(context);
            Test.stopTest();
            
            // Assert
            System.assertEquals('High', context.projectMap.get(project.Id).Project_Complexity__c, 'It should be a Project Complexity High.');
        }
    }

    private static pse__Proj__c createProject(string pmComplexity, string projectType) {
        Account account = new Account(Name = 'Test account');        
        insert(account);

        pse__Region__c region = new pse__Region__c(
                Name = 'United States',
                Active__c = true,
                ISO_Country_Code__c = 'US'
        );

        insert(region);

        pse__Proj__c project = new pse__Proj__c(Name='Test Project', pse__Is_Template__c = false, pse__Is_Active__c = true, 
                                                pse__Start_Date__c = Date.today(), pse__Account__c=account.Id, pse__Region__c = region.Id,
                                                PM_Complexity__c = pmComplexity, pse__Project_Type__c = projectType, Deal_Type__c = projectType);
        insert project;

        return project;
    }

    private static void createOrderWithOrderItemSkuCost(string orderNumber, decimal skuCost) {
         // Create Account
         Account account = new Account();
         account.Name = 'Create Account Test';
         insert account;

        // create order
        Order order = new Order();
        order.OrderNumber__c = orderNumber;
        order.EffectiveDate = Date.today();
        order.AccountId = account.Id;
        order.CurrencyIsoCode = 'USD';
        order.BUID__c = '11';
        order.Status = 'BK';
        order.Order_Status__c = 'EC';
        order.Pricebook2Id = Test.getStandardPricebookId();
        order.OCI_Order_Type__c = 'US Order';
        order.FF_Feed__c = true;
        insert order;

        // Order Product
        Product2 product = new Product2();
        product.Name='Product Test';
        insert product;

		//List<PricebookEntry> pbentry = [Select ID from PricebookEntry where Product2Id =:product.Id limit 1];
		//if(pbentry == null && pbentry.size() == 0){
			PricebookEntry pricebookEntry = new PricebookEntry();
			pricebookEntry.Pricebook2Id = Test.getStandardPricebookId();
			pricebookEntry.Product2Id = product.Id;
			pricebookEntry.UseStandardPrice = false; 
			pricebookEntry.UnitPrice = 1;
			insert pricebookEntry;
			//pbentry.add(pricebookEntry);
		//}

        // Order Item
        OrderItem oi = new OrderItem();
        oi.SKU_Description__c = 'SKU Desc 1';
        oi.Quantity = 1;
        oi.UnitPrice = 1;
        oi.Item_Class_Description__c = 'SVC EDT INSTLN';
        oi.Tie_Number__c = '1';
        oi.OrderId = order.Id;
       // oi.PriceBookEntryId = pbentry[0].Id;
        oi.PriceBookEntryId = pricebookEntry.Id;
        oi.SKU_Cost__c = skuCost;
        oi.SKU_Cost_Local__c = skuCost;
        oi.Sku_Number__c = '123-456';
        oi.Unit_Selling_Price_USD__c = skuCost;
        oi.Unit_Selling_Price_Local__c = skuCost;
        oi.SKU_Cost_USD__c = skuCost;
        insert oi;
    }
}