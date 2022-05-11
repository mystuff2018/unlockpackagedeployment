@isTest
public class OrderItemGroupingPracticeRulesTest {
    
    @testSetup
    static void makeData(){
        //Login with Integration User Profile to create Test Data
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){
            Order_Grouping_Configuration__c orderGroupingConfiguration = new Order_Grouping_Configuration__c(
                Project_Phase__c = 'Setup',
                Practice_Level__c = 2
            );
            
            insert orderGroupingConfiguration;
            
            pse__Proj__c projectTemplate = TestDataUtility.createProject(true);
            
            List<pse__Practice__c> practiceList = new List<pse__Practice__c>();
            pse__Practice__c practice0 = new pse__Practice__c(Name = 'Global', Standard_Project_Template__c = projectTemplate.Id);
            practiceList.add(practice0);
            insert practiceList;
            
            
            pse__Practice__c practice1 = new pse__Practice__c(Name = 'Globals', pse__Parent_Practice__c = practice0.Id, Standard_Project_Template__c = projectTemplate.Id);
            practiceList.add(practice1);
            upsert practiceList;
            
            pse__Practice__c practice2 = new pse__Practice__c(Name = 'IDS', pse__Parent_Practice__c = practice1.Id, Order_Association_Approval_Phase__c = 'Execute', Standard_Project_Template__c = projectTemplate.Id);
            pse__Practice__c practice3 = new pse__Practice__c(Name = 'Consulting', pse__Parent_Practice__c = practice1.Id, Order_Association_Approval_Phase__c = 'Execute', Standard_Project_Template__c = projectTemplate.Id);
            pse__Practice__c practice4 = new pse__Practice__c(Name = 'HES', pse__Parent_Practice__c = practice1.Id, Order_Association_Approval_Phase__c = 'Execute', Standard_Project_Template__c = projectTemplate.Id);
            practiceList.add(practice2);
            practiceList.add(practice3);
            practiceList.add(practice4);
            upsert practiceList;
            
            pse__Practice__c practice5 = new pse__Practice__c(Name = 'EIS', pse__Parent_Practice__c = practice2.Id, Standard_Project_Template__c = projectTemplate.Id);
            pse__Practice__c practice6 = new pse__Practice__c(Name = 'Flex', pse__Parent_Practice__c = practice2.Id, Standard_Project_Template__c = projectTemplate.Id);
            practiceList.add(practice5);
            practiceList.add(practice6);
            upsert practiceList;
            
            // Create sku numbers and effort mappings
            List<String> skuNumbersToMap1 = new List<String>{'101-1010'};
                List<String> skuNumbersToMap2 = new List<String>{'CUSTOM SKU'};
                    Map<String, String> phaseByTask = new Map<String, String>();
            phaseByTask.put('Scoping', 'Initiate');
            
            SKU_Effort_Map__c skuEffort1 = OPRTestFactory.createSkuEffortMap(skuNumbersToMap1, 10, false, phaseByTask, true);
            SKU_Effort_Map__c skuEffort2 = OPRTestFactory.createSkuEffortMap(skuNumbersToMap2, 10, false, phaseByTask);
            
            // practiceList = new List<pse__Practice__c>();
            practice0.pse__Practice_ID_Chain__c = practice0.Id;
            practice1.pse__Practice_ID_Chain__c = practice1.Id + ',' + practice0.Id;
            practice2.pse__Practice_ID_Chain__c = practice2.Id + ',' + practice1.Id + ',' + practice0.Id;
            practice3.pse__Practice_ID_Chain__c = practice3.Id + ',' + practice1.Id + ',' + practice0.Id;
            practice4.pse__Practice_ID_Chain__c = practice4.Id + ',' + practice1.Id + ',' + practice0.Id;
            practice5.pse__Practice_ID_Chain__c = practice5.Id + ',' + practice2.Id + ',' + practice1.Id + ',' + practice0.Id;
            practice6.pse__Practice_ID_Chain__c = practice6.Id + ',' + practice2.Id + ',' + practice1.Id + ',' + practice0.Id;
            update practiceList;
            
            List<Item_Class__c> itemClasses = new List<Item_Class__c>();
            itemClasses.add(new Item_Class__c(Item_Class_Description__c = 'SVC IDS', Practice__c = practice2.Id, Key_Practice__c = true));
            itemClasses.add(new Item_Class__c(Item_Class_Description__c = 'SVC Consulting', Practice__c = practice3.Id, Key_Practice__c = true));
            itemClasses.add(new Item_Class__c(Item_Class_Description__c = 'SVC HES', Practice__c = practice4.Id, Key_Practice__c = true));
            itemClasses.add(new Item_Class__c(Item_Class_Description__c = 'SVC EIS', Practice__c = practice5.Id, Key_Practice__c = true));
            itemClasses.add(new Item_Class__c(Item_Class_Description__c = 'SVC Flex', Practice__c = practice6.Id, Key_Practice__c = true));
            insert itemClasses;
        }        
    }
    
    @isTest
    static void testWithFourOrders(){
        //Login with Integration User Profile to create Test Data
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){
            List<Account> accounts = new List<Account>();
            accounts.add(new Account(Name = 'Test1', BUID__c = '11', CCN__c = '	US_42'));//0
            accounts.add(new Account(Name = 'Test2', BUID__c = '11', CCN__c = '	US_43'));
            accounts.add(new Account(Name = 'Test3', BUID__c = '12', CCN__c = '	US_42'));
            accounts.add(new Account(Name = 'Test4', BUID__c = '13', CCN__c = '	US_44'));//3
            accounts.add(new Account(Name = 'Test5', BUID__c = '11', CCN__c = '	US_42'));
            accounts.add(new Account(Name = 'Test6', BUID__c = '11', CCN__c = '	US_42'));
            insert accounts;
            
            pse__Proj__c engagement1 = new pse__Proj__c(
                Name = 'Engagement Test 1',
                RecordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get('Parent_Project').getRecordTypeId()
            );
            pse__Proj__c engagement2 = new pse__Proj__c(
                Name = 'Engagement Test 2',
                RecordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get('Parent_Project').getRecordTypeId()
            );
            pse__Proj__c engagement3 = new pse__Proj__c(
                Name = 'Engagement Test 3',
                RecordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get('Parent_Project').getRecordTypeId()
            );
            insert new List<pse__Proj__c>{engagement1, engagement2, engagement3};
                
                Test.startTest();
            pse__Proj__c project2 = new pse__Proj__c(
                Name = 'Project Flex Engagement 2',
                pse__Project_Phase__c = 'Setup',
                pse__parent_project__c = engagement2.Id,
                pse__practice__c = [Select Id From pse__practice__c Where Name = 'HES'][0].Id,
                pse__End_Date__c = Date.Today().addDays(30),
                pse__Start_Date__c = Date.Today(),
                Billing_Account__c = accounts[0].Id,
                BUID__c = '11',
                Local_Channel__c = 'US_42',
                pse__Project_Type__c = 'Proof Of Concept Investment',
                Distinct_SKU_Effort_Mapping__c = [SELECT Id, Residency__c FROM SKU_Effort_Map__c WHERE Distinct_Project__c = true limit 1].Id
                
            );
            pse__Proj__c project3 = new pse__Proj__c(
                Name = 'Project IDS Engagement 3',
                pse__Project_Phase__c = 'Setup',
                pse__parent_project__c = engagement3.Id,
                pse__practice__c = [Select Id From pse__practice__c Where Name = 'IDS'][0].Id,
                pse__End_Date__c = Date.Today().addDays(30),
                pse__Start_Date__c = Date.Today(),
                Billing_Account__c = accounts[3].Id,
                BUID__c = '13',
                Local_Channel__c = 'US_44',
                pse__Project_Type__c = 'Proof Of Concept Investment',
                Distinct_SKU_Effort_Mapping__c = [SELECT Id,Residency__c FROM SKU_Effort_Map__c WHERE Distinct_Project__c = true limit 1].Id
            );
            insert new List<pse__Proj__c>{project2, project3};
                
                // Engagement 1
                List<Order> orderList = new List<Order>();
            Order order1 = new Order(
                OrderNumber__c = '1234567891',
                AccountId = accounts[0].Id,
                Billing_Account__c = accounts[0].Id,
                EffectiveDate = Date.today(),
                BUID__c = '11',
                Local_Channel__c = 'US_42',
                Status = 'BK',
                Order_Processing_Code__c = 'E',
                Pricebook2Id = Test.getStandardPricebookId()
            );
            
            Order order2 = new Order(
                OrderNumber__c = '1234567892',
                AccountId = accounts[0].Id,
                Billing_Account__c = accounts[1].Id,
                EffectiveDate = Date.today(),
                BUID__c = '11',
                Local_Channel__c = 'US_43',
                Status = 'BK',
                Order_Processing_Code__c = 'E',
                Pricebook2Id = Test.getStandardPricebookId()
            );
            
            Order order3 = new Order(
                OrderNumber__c = '1234567893',
                AccountId = accounts[0].Id,
                Billing_Account__c = accounts[2].Id,
                EffectiveDate = Date.today(),
                BUID__c = '12',
                Local_Channel__c = 'US_42',
                Status = 'BK',
                Order_Processing_Code__c = 'E',
                Pricebook2Id = Test.getStandardPricebookId()
            );
            
            Order order4 = new Order(
                OrderNumber__c = '1234567894',
                AccountId = accounts[0].Id,
                Billing_Account__c = accounts[3].Id,
                EffectiveDate = Date.today(),
                BUID__c = '13',
                Local_Channel__c = 'US_44',
                Status = 'BK',
                Order_Processing_Code__c = 'E',
                Pricebook2Id = Test.getStandardPricebookId()
            );
            
            Order order5 = new Order(
                OrderNumber__c = '1234567895',
                AccountId = accounts[0].Id,
                Billing_Account__c = accounts[4].Id,
                EffectiveDate = Date.today(),
                BUID__c = '11',
                Local_Channel__c = 'US_42',
                Status = 'BK',
                Order_Processing_Code__c = 'E',
                Pricebook2Id = Test.getStandardPricebookId()
            );
            
            Order order6 = new Order(
                OrderNumber__c = '1234567896',
                AccountId = accounts[0].Id,
                Billing_Account__c = accounts[5].Id,
                EffectiveDate = Date.today(),
                BUID__c = '11',
                Local_Channel__c = 'US_42',
                Status = 'BK',
                Order_Processing_Code__c = 'E',
                Pricebook2Id = Test.getStandardPricebookId()
            );
            
            Order order7 = new Order(
                OrderNumber__c = '1234567896',
                AccountId = accounts[0].Id,
                Billing_Account__c = accounts[5].Id,
                EffectiveDate = Date.today(),
                BUID__c = '11',
                Local_Channel__c = 'US_42',
                Status = 'BK',
                Order_Processing_Code__c = 'I',
                Pricebook2Id = Test.getStandardPricebookId()
            );
            insert new List<Order>{order1, order2, order3, order4, order5, order6, order7};
                
                Product2 product = new Product2(Name='Product Test');
            insert product;
            
           /** PricebookEntry pricebookEntry = [Select Id, Pricebook2Id, Product2Id FROM PricebookEntry
                                         WHERE Product2Id =:product.Id]; **/
            //[Deloitte: Abhishek Kawle] - Commented this code as Product gets associated to Pricebook automatically.
            PricebookEntry pricebookEntry = new PricebookEntry(
                Pricebook2Id = Test.getStandardPricebookId(),
                Product2Id = product.Id,
                UseStandardPrice = false,
                UnitPrice = 1
            );
            insert pricebookEntry; 
            
            List<OrderItem> orderItemList = new List<OrderItem>();
            OrderItem orderItem1 = new OrderItem(
                SKU_Description__c = 'SKU1',
                SKU_Number__c = '101-1010',
                Quantity = 1,
                Item_Class_Description__c = 'SVC EIS',
                OrderId = order1.Id,
                PriceBookEntryId = priceBookEntry.Id,
                UnitPrice = 1
            );
            
            OrderItem orderItem2 = new OrderItem(
                SKU_Description__c = 'SKU2',
                SKU_Number__c = '222-2222',
                Quantity = 1,
                Item_Class_Description__c = 'SVC EIS',
                OrderId = order2.Id,
                PriceBookEntryId = priceBookEntry.Id,
                UnitPrice = 1
            );
            
            OrderItem orderItem3 = new OrderItem(
                SKU_Description__c = 'SKU3',
                SKU_Number__c = '333-3333',
                Quantity = 1,
                Item_Class_Description__c = 'SVC IDS',
                OrderId = order2.Id,
                PriceBookEntryId = priceBookEntry.Id,
                UnitPrice = 1
            );
            
            OrderItem orderItem4 = new OrderItem(
                SKU_Description__c = 'SKU4',
                SKU_Number__c = '444-4444',
                Quantity = 1,
                Item_Class_Description__c = 'SVC IDS',
                OrderId = order3.Id,
                PriceBookEntryId = priceBookEntry.Id,
                UnitPrice = 1
            );
            
            OrderItem orderItem5 = new OrderItem(
                SKU_Description__c = 'SKU5',
                SKU_Number__c = '555-5555',
                Quantity = 1,
                Item_Class_Description__c = 'SVC IDS',
                OrderId = order4.Id,
                PriceBookEntryId = priceBookEntry.Id,
                UnitPrice = 1
            );
            
            OrderItem orderItem6 = new OrderItem(
                SKU_Description__c = 'SKU6',
                SKU_Number__c = '666-6666',
                Quantity = 1,
                Item_Class_Description__c = 'SVC Consulting',
                OrderId = order4.Id,
                PriceBookEntryId = priceBookEntry.Id,
                UnitPrice = 1
            );
            
            // Engagement 2
            OrderItem orderItem7 = new OrderItem(
                SKU_Description__c = 'SKU7',
                SKU_Number__c = '777-7777',
                Quantity = 1,
                Item_Class_Description__c = 'SVC HES',
                OrderId = order5.Id,
                PriceBookEntryId = priceBookEntry.Id,
                UnitPrice = 1
            );
            OrderItem orderItem8 = new OrderItem(
                SKU_Description__c = 'SKU8',
                SKU_Number__c = '101-1010',
                Quantity = 1,
                Item_Class_Description__c = 'SVC HES',
                OrderId = order5.Id,
                PriceBookEntryId = priceBookEntry.Id,
                UnitPrice = 1
            );
            
            // Engagement 3
            OrderItem orderItem9 = new OrderItem(
                SKU_Description__c = 'SKU9',
                SKU_Number__c = '999-9999',
                Quantity = 1,
                Item_Class_Description__c = 'SVC Flex',
                OrderId = order6.Id,
                PriceBookEntryId = priceBookEntry.Id,
                UnitPrice = 1
            );
            OrderItem orderItem10 = new OrderItem(
                SKU_Description__c = 'SKU10',
                SKU_Number__c = '101-1010',
                Quantity = 1,
                Item_Class_Description__c = 'SVC EIS',
                OrderId = order6.Id,
                PriceBookEntryId = priceBookEntry.Id,
                UnitPrice = 1
            );
            
            // Project type assertion (Concession delivery)
            OrderItem orderItem11 = new OrderItem(
                SKU_Description__c = 'SKU10',
                SKU_Number__c = '101-1010',
                Quantity = 1,
                Item_Class_Description__c = 'SVC EIS',
                OrderId = order7.Id,
                PriceBookEntryId = priceBookEntry.Id,
                UnitPrice = 1,
                Unit_Selling_Price_USD__c = 0
            );
            insert new List<OrderItem>{orderItem1, orderItem2, orderItem3, orderItem4, orderItem5, orderItem6, orderItem7, orderItem8, orderItem9, orderItem10, orderItem11};
                
                Map<Id,Id> ordersToEngagement = new Map<Id,Id>{
                    order1.Id => engagement1.Id,
                        order2.Id => engagement1.Id,
                        order3.Id => engagement1.Id,
                        order4.Id => engagement1.Id,
                        order5.Id => engagement2.Id,
                        order6.Id => engagement3.Id,
                        order7.Id => engagement1.Id
                        };
                            OrderItemGroupingDataContext context = new OrderItemGroupingDataContext(ordersToEngagement);
            
            OrderItemGroupingPracticeRules.groupingOrderItemByPractice(context);
            Test.stopTest();     
            
            System.assertEquals(10, context.projectsToCreate.size(), 'It should have 10 order items to create project.');
            System.assertEquals(1, context.orderItemToAssociate.size(), 'It should have 1 order item to associate.');
        }
    }
    
    @isTest
    static void testCompareChains(){
        
        //Login with Integration User Profile to create Test Data
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){
            String chainA =  'AA,BB,CC,DD,EE'; 
            String chainB =  'BB,CC,DD,EE';
            String chainC =  'AA,BB,DD,EE';
            
            Test.startTest();
            String result = OrderItemGroupingPracticeRules.compareChains(chainA, chainB);
            String nullResult = OrderItemGroupingPracticeRules.compareChains(chainB,chainC);
            Test.stopTest();
            
            System.assertEquals(chainB, result, 'Result shoub be equals chainB');
            System.assertEquals(null, nullResult, 'Result shoub be null');
        }
    }
    
    @isTest
    static void shouldCalculateProjectType(){
        
        //Login with Integration User Profile to create Test Data
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){
            Account account = new Account(Name = 'Test1', BUID__c = '11', CCN__c = 'US_42');
            insert account;
            
            Order order1 = new Order(
                OrderNumber__c = '1234567896',
                AccountId = account.Id,
                Billing_Account__c = account.Id,
                EffectiveDate = Date.today(),
                BUID__c = '11',
                Status = 'BK',
                Order_Processing_Code__c = 'I',
                Pricebook2Id = Test.getStandardPricebookId()
            );
            
            Order order2 = new Order(
                OrderNumber__c = '1234567897',
                AccountId = account.Id,
                Billing_Account__c = account.Id,
                EffectiveDate = Date.today(),
                BUID__c = '11',
                Status = 'BK',
                Order_Processing_Code__c = 'I',
                Pricebook2Id = Test.getStandardPricebookId()
            );
            
            Order order3 = new Order(
                OrderNumber__c = '1234567898',
                AccountId = account.Id,
                Billing_Account__c = account.Id,
                EffectiveDate = Date.today(),
                BUID__c = '11',
                Status = 'BK',
                Payment_Term__c = 'N',
                Order_Processing_Code__c = 'Any',
                Pricebook2Id = Test.getStandardPricebookId()
            );
            
            Order order4 = new Order(
                OrderNumber__c = '1234567899',
                AccountId = account.Id,
                Billing_Account__c = account.Id,
                EffectiveDate = Date.today(),
                BUID__c = '11',
                Status = 'BK',
                Order_Processing_Code__c = 'E',
                Pricebook2Id = Test.getStandardPricebookId()
            );
            
            Order order5 = new Order(
                OrderNumber__c = '1234567899',
                AccountId = account.Id,
                Billing_Account__c = account.Id,
                EffectiveDate = Date.today(),
                BUID__c = '11',
                Status = 'BK',
                Order_Processing_Code__c = 'Any',
                Pricebook2Id = Test.getStandardPricebookId()
            );
            insert new List<Order>{order1, order2, order3, order4, order5};
                
            Product2 product = new Product2(Name='Product Test');
            insert product;
            
           /** PricebookEntry pricebookEntry = [Select Id, Pricebook2Id, Product2Id FROM PricebookEntry
                                         WHERE Product2Id =:product.Id];**/
            //[Deloitte: Abhishek Kawle] - Commented this code as Product gets associated to Pricebook automatically.
            PricebookEntry pricebookEntry = new PricebookEntry(
                Pricebook2Id = Test.getStandardPricebookId(),
                Product2Id = product.Id,
                UseStandardPrice = false,
                UnitPrice = 1
            );
            insert pricebookEntry; 
            
            OrderItem orderItem1 = new OrderItem(
                SKU_Description__c = 'SKU1',
                SKU_Number__c = '101-1010',
                Quantity = 1,
                Item_Class_Description__c = 'SVC EIS',
                OrderId = order1.Id,
                PriceBookEntryId = priceBookEntry.Id,
                UnitPrice = 1,
                Unit_Selling_Price_USD__c = 0
            );
            
            OrderItem orderItem2 = new OrderItem(
                SKU_Description__c = 'SKU1',
                SKU_Number__c = '101-1010',
                Quantity = 1,
                Item_Class_Description__c = 'SVC EIS',
                OrderId = order1.Id,
                PriceBookEntryId = priceBookEntry.Id,
                UnitPrice = 1,
                Unit_Selling_Price_USD__c = 100
            );
            insert new List<OrderItem>{orderItem1, orderItem2};
                
                String projectTypeConcessionDelivery1 = OrderItemGroupingPracticeRules.calculateProjectType(order1, orderItem1);
            String projectTypeConcessionDelivery3 = OrderItemGroupingPracticeRules.calculateProjectType(order3, orderItem2);
            String projectTypeProofOfConceptInvestment = OrderItemGroupingPracticeRules.calculateProjectType(order4, orderItem2);
            String projectTypeRevenueGenerating1 = OrderItemGroupingPracticeRules.calculateProjectType(order2, orderItem2);
            String projectTypeRevenueGenerating2 = OrderItemGroupingPracticeRules.calculateProjectType(order5, orderItem2);
            
           // System.assertEquals('Concession Delivery', projectTypeConcessionDelivery1);
           // System.assertEquals('Concession Delivery', projectTypeConcessionDelivery3);
           // System.assertEquals('Proof Of Concept Investment', projectTypeProofOfConceptInvestment);
            System.assertEquals('Revenue Generating', projectTypeRevenueGenerating1);
            System.assertEquals('Revenue Generating', projectTypeRevenueGenerating2);
            
        }  
    }
    
    
}