/*
 * @class OrderItemGroupingPracticeRules
 * @authors Christopher Michel and Pablo Dunke
 * @date 06/24/2020
 */

@IsTest
private class OrderItemGroupingDealTypeTest 
{
    @testSetup 
    public static void testSetup() 
    {
        //Login with Integration User Profile to create Account
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){ 
            
            pse__Proj__c projectTemplate = TestDataUtility.createProject(true);
            
            pse__Practice__c practice = new pse__Practice__c(Name = 'Custom 1', Order_Association_Approval_Phase__c = 'Execute', Standard_Project_Template__c = projectTemplate.Id);
            insert practice;
            
            List<Item_Class__c> listItemClass = new List<Item_Class__c>();
            listItemClass.add(new Item_Class__c(Item_Class_Description__c = 'SVC EIS SVCs', Practice__c = practice.Id, Key_Practice__c = true));
            listItemClass.add(new Item_Class__c(Item_Class_Description__c = 'SVC EDT CNSLT', Practice__c = practice.Id, Key_Practice__c = true));
            insert listItemClass;
            
            List<String> listSkuNumberToMap = new List<String>{'111-1111', '222-2222'};
                List<String> listCustomSkuNumberToMap = new List<String>{'CUSTOM SKU'};
                    
                    Map<String, String> listPhase = new Map<String, String>();
            listPhase.put('Scoping', 'Initiate');
            listPhase.put('Configuration', 'Execute');
            listPhase.put('Planning', 'Plan');
            
            Map<String, String> listCustomPhase = new Map<String, String>();
            listCustomPhase.put('Scoping', 'Initiate');
            listCustomPhase.put('Physical Installation', 'Execute');
            listCustomPhase.put('Planning', 'Plan');
            listCustomPhase.put('Delivery', 'Close');
            
            SKU_Effort_Map__c skuEffort1 = OPRTestFactory.createSkuEffortMap(listSkuNumberToMap, 10, false, listPhase);
            SKU_Effort_Map__c skuEffortCustom = OPRTestFactory.createSkuEffortMap(listCustomSkuNumberToMap, 10, false, listCustomPhase);
        }
    }

     @IsTest
    static void testStandardProjectCustomOrder() 
    {
        //Login with Integration User Profile to create Account
        Test.startTest();
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){ 
            // Create the data
            Order order1 = OPRTestFactory.createSimpleOrder();
            
            pse__Proj__c engagement = new pse__Proj__c();
            engagement.pse__Account__c = order1.AccountId;
            engagement.Deal__c = order1.Deal_ID__c;
            engagement.RecordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get('Parent_Project').getRecordTypeId();
            insert engagement;
            
            order1.Project__c = engagement.Id;
            update order1;
            
            pse__Practice__c practice = [SELECT Id FROM pse__Practice__c WHERE Name = 'Custom 1'];
            
            // Standard project
            pse__Proj__c project1 = new pse__Proj__c();
            project1.Name = 'Test Project';
            project1.pse__Account__c = order1.AccountId;
            project1.pse__Parent_Project__c = engagement.Id;
            project1.pse__Practice__c = practice.Id;
            project1.pse__Start_Date__c = Date.today();
            project1.Deal_Type__c = 'Standard';
            project1.pse__Is_Template__c = false;
            project1.pse__Is_Active__c = true;
            insert project1;
            
            OrderItem orderItem1 = [SELECT Id FROM OrderItem WHERE OrderId =: order1.Id].get(0);
            orderItem1.Project__c = project1.Id;
            orderItem1.SKU_Number__c = '111-1111';
            orderItem1.Item_Class_Description__c = 'SVC EIS SVCs';
            update orderItem1;
            
            Order order2 = new Order();
            order2.AccountId = order1.AccountId;
            order2.PoNumber = order1.PoNumber;
            order2.Deal_ID__c = order1.Deal_ID__c;
            order2.DPID__c = '700';
            order2.BUID__c = '12';
            order2.EffectiveDate = Date.today();
            order2.Status = 'BK';
            order2.PriceBook2Id = Test.getStandardPricebookId();
            order2.OrderNumber__c = '123668';
            insert order2;
            
            Product2 product = new Product2();
            product.Name = 'Product Test';
            insert product;
            
           /** PricebookEntry pricebookEntry = [Select Id, Pricebook2Id, Product2Id FROM PricebookEntry
                                             WHERE Product2Id =:product.Id]; **/
            //[Deloitte: Abhishek Kawle] - Commented this code as Product gets associated to Pricebook automatically.
            
            PricebookEntry pricebookEntry = new PricebookEntry();
            pricebookEntry.Pricebook2Id = Test.getStandardPricebookId();
            pricebookEntry.Product2Id = product.Id;
            pricebookEntry.UseStandardPrice = false;
            pricebookEntry.UnitPrice = 1;
            insert pricebookEntry;
            
            
            // Custom order item
            OrderItem orderItem2 = new OrderItem();
            orderItem2.OrderId = order2.Id;
            orderItem2.UnitPrice = 2;
            orderItem2.Quantity = 1;
            orderItem2.Item_Class_Description__c = 'SVC EDT CNSLT';
            orderItem2.SKU_Number__c = '111-XXXX';
            orderItem2.PriceBookEntryId = priceBookEntry.Id;
            insert orderItem2;
            
            // Action
            //Test.startTest();
            
            OrderItemGroupingDataContext context = new OrderItemGroupingDataContext(new Map<Id, Id>{order2.Id => engagement.Id});
            OrderItemGroupingPracticeRules.groupingOrderItemByPractice(context);
            
            Test.stopTest();
            
            // Assertion
            System.assertEquals(1, context.projectsToCreate.size());
            OrderItemGroupingCompositeKey compositeKey = new OrderItemGroupingCompositeKey(context.projectsToCreate.get(0).groupingkey);
            System.assertEquals('Custom', compositeKey.dealType);
           
        }
    }

     @IsTest
    static void testCustomProjectStandardOrder() 
    {
        //Login with Integration User Profile to create Account
        Test.startTest();
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){ 
            // Create the data
            Order order1 = OPRTestFactory.createSimpleOrder();
            
            pse__Proj__c engagement = new pse__Proj__c();
            engagement.pse__Account__c = order1.AccountId;
            engagement.Deal__c = order1.Deal_ID__c;
            engagement.RecordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get('Parent_Project').getRecordTypeId();
            insert engagement;
            
            order1.Project__c = engagement.Id;
            update order1;
            
            pse__Practice__c practice = [SELECT Id FROM pse__Practice__c WHERE Name = 'Custom 1'];
            
            // Custom project
            pse__Proj__c project1 = new pse__Proj__c();
            project1.Name = 'Test Project';
            project1.pse__Account__c = order1.AccountId;
            project1.pse__Parent_Project__c = engagement.Id;
            project1.pse__Practice__c = practice.Id;
            project1.pse__Start_Date__c = Date.today();
            project1.Deal_Type__c = 'Custom';
            project1.pse__Is_Template__c = false;
            project1.pse__Is_Active__c = true;
            insert project1;
            
            OrderItem orderItem1 = [SELECT Id FROM OrderItem WHERE OrderId =: order1.Id].get(0);
            orderItem1.Project__c = project1.Id;
            orderItem1.SKU_Number__c = '111-XXXX';
            orderItem1.Item_Class_Description__c = 'SVC EIS SVCs';
            update orderItem1;
            
            Order order2 = new Order();
            order2.AccountId = order1.AccountId;
            order2.PoNumber = order1.PoNumber;
            order2.Deal_ID__c = order1.Deal_ID__c;
            order2.DPID__c = '701';
            order2.BUID__c = '12';
            order2.EffectiveDate = Date.today();
            order2.Status = 'BK';
            order2.PriceBook2Id = Test.getStandardPricebookId();
            order2.OrderNumber__c = '123668';
            insert order2;
            
            Product2 product = new Product2();
            product.Name = 'Product Test';
            insert product;
            
           /** PricebookEntry pricebookEntry = [Select Id, Pricebook2Id, Product2Id FROM PricebookEntry
                                             WHERE Product2Id =:product.Id]; **/
            //[Deloitte: Abhishek Kawle] - Commented this code as Product gets associated to Pricebook automatically.
            
            PricebookEntry pricebookEntry = new PricebookEntry();
            pricebookEntry.Pricebook2Id = Test.getStandardPricebookId();
            pricebookEntry.Product2Id = product.Id;
            pricebookEntry.UseStandardPrice = false;
            pricebookEntry.UnitPrice = 1;
            insert pricebookEntry;
            
            
            // Standard order item
            OrderItem orderItem2 = new OrderItem();
            orderItem2.OrderId = order2.Id;
            orderItem2.UnitPrice = 2;
            orderItem2.Quantity = 1;
            orderItem2.Item_Class_Description__c = 'SVC EDT CNSLT';
            orderItem2.SKU_Number__c = '111-1111';
            orderItem2.PriceBookEntryId = priceBookEntry.Id;
            insert orderItem2;
            
            // Action
            //Test.startTest();
            
            OrderItemGroupingDataContext context = new OrderItemGroupingDataContext(new Map<Id, Id>{order2.Id => engagement.Id});
            OrderItemGroupingPracticeRules.groupingOrderItemByPractice(context);
            
            Test.stopTest();
            
            // Assertion
            System.assertEquals(1, context.projectsToCreate.size());
            OrderItemGroupingCompositeKey compositeKey = new OrderItemGroupingCompositeKey(context.projectsToCreate.get(0).groupingkey);
            System.assertEquals('Standard', compositeKey.dealType);
        }
    }

    @IsTest
    static void testStandardComboOrder() 
    {
        //Login with Integration User Profile to create Account
        Test.startTest();
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){ 
            // Create the data
            Order order1 = OPRTestFactory.createSimpleOrder();
            
            pse__Proj__c engagement = new pse__Proj__c();
            engagement.pse__Account__c = order1.AccountId;
            engagement.Deal__c = order1.Deal_ID__c;
            engagement.RecordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get('Parent_Project').getRecordTypeId();
            insert engagement;
            
            order1.Project__c = engagement.Id;
            update order1;
            
            pse__Practice__c practice = [SELECT Id FROM pse__Practice__c WHERE Name = 'Custom 1'];
            
            // Standard project
            pse__Proj__c project1 = new pse__Proj__c();
            project1.Name = 'Test Project';
            project1.pse__Account__c = order1.AccountId;
            project1.pse__Parent_Project__c = engagement.Id;
            project1.pse__Practice__c = practice.Id;
            project1.pse__Start_Date__c = Date.today();
            project1.Deal_Type__c = 'Standard';
            project1.pse__Is_Template__c = false;
            project1.pse__Is_Active__c = true;
            insert project1;
            
            OrderItem orderItem1 = [SELECT Id FROM OrderItem WHERE OrderId =: order1.Id].get(0);
            orderItem1.Project__c = project1.Id;
            orderItem1.SKU_Number__c = '111-1111';
            orderItem1.Item_Class_Description__c = 'SVC EIS SVCs';
            update orderItem1;
            
            Order order2 = new Order();
            order2.AccountId = order1.AccountId;
            order2.PoNumber = order1.PoNumber;
            order2.Deal_ID__c = order1.Deal_ID__c;
            order2.DPID__c = order1.DPID__c;
            order2.BUID__c = order1.BUID__c;
            order2.EffectiveDate = Date.today();
            order2.Status = 'BK';
            order2.PriceBook2Id = Test.getStandardPricebookId();
            order2.OrderNumber__c = '123668';
            insert order2;
            
            Product2 product = new Product2();
            product.Name = 'Product Test';
            insert product;
            
          /**  PricebookEntry pricebookEntry = [Select Id, Pricebook2Id, Product2Id FROM PricebookEntry
                                             WHERE Product2Id =:product.Id]; **/
            //[Deloitte: Abhishek Kawle] - Commented this code as Product gets associated to Pricebook automatically.
            
            PricebookEntry pricebookEntry = new PricebookEntry();
            pricebookEntry.Pricebook2Id = Test.getStandardPricebookId();
            pricebookEntry.Product2Id = product.Id;
            pricebookEntry.UseStandardPrice = false;
            pricebookEntry.UnitPrice = 1;
            insert pricebookEntry;
            
            
            // Custom order item
            OrderItem orderItem2 = new OrderItem();
            orderItem2.OrderId = order2.Id;
            orderItem2.UnitPrice = 2;
            orderItem2.Quantity = 1;
            orderItem2.Item_Class_Description__c = 'SVC EDT CNSLT';
            orderItem2.SKU_Number__c = '111-XXXX';
            orderItem2.PriceBookEntryId = priceBookEntry.Id;
            insert orderItem2;
            
            // Standard order item
            OrderItem orderItem3 = new OrderItem();
            orderItem3.OrderId = order2.Id;
            orderItem3.UnitPrice = 2;
            orderItem3.Quantity = 1;
            orderItem3.Item_Class_Description__c = 'SVC EIS SVCs';
            orderItem3.SKU_Number__c = '222-2222';
            orderItem3.PriceBookEntryId = priceBookEntry.Id;
            insert orderItem3;
            
            // Action
            //Test.startTest();
            
            OrderItemGroupingDataContext context = new OrderItemGroupingDataContext(new Map<Id, Id>{order2.Id => engagement.Id});
            OrderItemGroupingPracticeRules.groupingOrderItemByPractice(context);
            
            Test.stopTest();
            
            // Assertion
            OrderItemGroupingCompositeKey compositeKey = new OrderItemGroupingCompositeKey(context.projectsToCreate.get(0).groupingkey);
            System.assertEquals('Custom', compositeKey.dealType);
        }
    }

     @IsTest
    static void testCustomComboOrder() 
    {
        //Login with Integration User Profile to create Account
        Test.startTest();
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){ 
            // Create the data
            Order order1 = OPRTestFactory.createSimpleOrder();
            
            pse__Proj__c engagement = new pse__Proj__c();
            engagement.pse__Account__c = order1.AccountId;
            engagement.Deal__c = order1.Deal_ID__c;
            engagement.RecordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get('Parent_Project').getRecordTypeId();
            insert engagement;
            
            order1.Project__c = engagement.Id;
            update order1;
            
            pse__Practice__c practice = [SELECT Id,Name FROM pse__Practice__c WHERE Name = 'Custom 1'];
            
            // Custom project
            pse__Proj__c project1 = new pse__Proj__c();
            project1.Name = 'Test Project';
            project1.pse__Account__c = order1.AccountId;
            project1.pse__Parent_Project__c = engagement.Id;
            project1.pse__Practice__c = practice.Id;
            project1.pse__Start_Date__c = Date.today();
            project1.Deal_Type__c = 'Custom';
            project1.pse__Is_Template__c = false;
            project1.pse__Is_Active__c = true;
            insert project1;
            
            OrderItem orderItem1 = [SELECT Id FROM OrderItem WHERE OrderId =: order1.Id].get(0);
            orderItem1.Project__c = project1.Id;
            orderItem1.SKU_Number__c = '111-XXXX';
            orderItem1.Item_Class_Description__c = 'SVC EIS SVCs';
            update orderItem1;
            
            Order order2 = new Order();
            order2.AccountId = order1.AccountId;
            order2.PoNumber = order1.PoNumber;
            order2.Deal_ID__c = order1.Deal_ID__c;
            order2.DPID__c = order1.DPID__c;
            order2.BUID__c = order1.BUID__c;
            order2.EffectiveDate = Date.today();
            order2.Status = 'BK';
            order2.PriceBook2Id = Test.getStandardPricebookId();
            order2.OrderNumber__c = '123668';
            insert order2;
            
            Product2 product = new Product2();
            product.Name = 'Product Test';
            insert product;
            
           /** PricebookEntry pricebookEntry = [Select Id, Pricebook2Id, Product2Id FROM PricebookEntry
                                             WHERE Product2Id =:product.Id]; **/
            //[Deloitte: Abhishek Kawle] - Commented this code as Product gets associated to Pricebook automatically.
            
            PricebookEntry pricebookEntry = new PricebookEntry();
            pricebookEntry.Pricebook2Id = Test.getStandardPricebookId();
            pricebookEntry.Product2Id = product.Id;
            pricebookEntry.UseStandardPrice = false;
            pricebookEntry.UnitPrice = 1;
            insert pricebookEntry;
            
            
            // Standard order item
            OrderItem orderItem2 = new OrderItem();
            orderItem2.OrderId = order2.Id;
            orderItem2.UnitPrice = 7;
            orderItem2.Quantity = 1;
            orderItem2.Item_Class_Description__c = 'SVC EIS SVCs';
            orderItem2.SKU_Number__c = '222-2222';
            orderItem2.PriceBookEntryId = priceBookEntry.Id;
            insert orderItem2;
            
            // Custom order item
            OrderItem orderItem3 = new OrderItem();
            orderItem3.OrderId = order2.Id;
            orderItem3.UnitPrice = 5;
            orderItem3.Quantity = 1;
            orderItem3.Item_Class_Description__c = 'SVC EDT CNSLT';
            orderItem3.SKU_Number__c = '222-XXXX';
            orderItem3.PriceBookEntryId = priceBookEntry.Id;
            insert orderItem3;
            
            // Action
            //Test.startTest();
            
            OrderItemGroupingDataContext context = new OrderItemGroupingDataContext(new Map<Id, Id>{order2.Id => engagement.Id});
            OrderItemGroupingPracticeRules.groupingOrderItemByPractice(context);
            
            Test.stopTest();
            
            // Assertion
            OrderItemGroupingCompositeKey compositeKey = new OrderItemGroupingCompositeKey(context.projectsToCreate.get(0).groupingkey);
            System.assertEquals('Standard', compositeKey.dealType);
            OrderItemGroupingCompositeKey compositeKey2 = new OrderItemGroupingCompositeKey(practice.Id, project1);
            compositeKey.isKeyCompatible(compositeKey);
        }
    }
    
}