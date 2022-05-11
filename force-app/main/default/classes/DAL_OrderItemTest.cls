@isTest
public class DAL_OrderItemTest {
    
    @testSetup
    static void setup(){
        Boolean isInsert =True;
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        pse__Proj__c projectTemplate = new pse__Proj__c(
            Name='Phased Project Template - Custom - Global',
            pse__Is_Template__c = true,
            pse__Is_Active__c = true,
            // CreatedDate = System.Today().addDays(-90),
            pse__Start_Date__c = Date.today()
        );
        
        insert projectTemplate;
        
        // pse__Practice__c practice = new pse__Practice__c(Name = 'Global', Standard_Project_Template__c = projectTemplate.Id);
        
        // insert practice;
        pse__Practice__c practice = new pse__Practice__c(
            Name = 'Custom Practice Test',
            Order_Association_Approval_Phase__c = 'Execute',
            Standard_Project_Template__c = projectTemplate.Id
        );
        insert practice;
        
        Contact contact = OPRTestFactory.newContact('firstName','lastName','United States','Texas','1234567898');
        contact.pse__Salesforce_User__c = UserInfo.getUserId();
        
        INSERT contact;
        
        pse__Proj__c project = new pse__Proj__c(
            Name = 'project Test IDS',
            pse__Project_Manager__c = contact.Id,
            pse__practice__c = practice.Id,
            pse__End_Date__c = Date.Today().addDays(30),
            pse__Start_Date__c = Date.Today()
        );
        
        insert project;
        
        OrderItemToProjectApproval__c orderItemToProjectApproval = new OrderItemToProjectApproval__c(
            Approver__c = project.pse__Project_Manager__r.pse__Salesforce_User__c,
            Project__c = project.Id
        );
        
        insert orderItemToProjectApproval;
        
        Account account = new Account(Name = 'Test');
        if(isInsert){
            system.runAs(loginUser[0])
            {
                insert account;
            }
        }
        
        Order order = new Order(
            OrderNumber__c = '123456789',
            AccountId = account.Id,
            EffectiveDate = Date.today(),
            BUID__c = '11',
            Status = 'BK',
            Pricebook2Id = Test.getStandardPricebookId()
        );
        insert order;
        
        Product2 product = new Product2(Name='Product Test');
        insert product;
        
        PricebookEntry pricebookEntry = new PricebookEntry();
        pricebookEntry.Pricebook2Id = Test.getStandardPricebookId();
        pricebookEntry.Product2Id = product.Id;
        pricebookEntry.UseStandardPrice = false;
        pricebookEntry.UnitPrice = 1;
        insert pricebookEntry;
        
        List<OrderItem> orderItemList = new List<OrderItem>();
        OrderItem orderItem1 = new OrderItem(
            SKU_Description__c = 'SKU1',
            SKU_Number__c = '111-1111',
            Quantity = 1,
            Item_Class_Description__c = 'SVC EIS',
            OrderId = order.Id,
            PriceBookEntryId = priceBookEntry.Id,
            UnitPrice = 1,
            OrderItemToProjectApproval__c = orderItemToProjectApproval.Id
        );
        orderItemList.add(orderItem1);
        
        insert orderItemList; 
    }
    
    @isTest
    static void shouldGetOrderItemByOrderId(){
        Boolean isInsert =True;
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        
        Account account = new Account(Name = 'Test');
        if(isInsert){
            system.runAs(loginUser[0])
            {
                insert account;
            }
        }
        
        Order order = new Order(
            OrderNumber__c = '123456789',
            AccountId = account.Id,
            EffectiveDate = Date.today(),
            BUID__c = '11',
            Status = 'BK',
            Pricebook2Id = Test.getStandardPricebookId()
        );
        insert order;
        
        Product2 product = new Product2(Name='Product Test');
        insert product;
        
        PricebookEntry pricebookEntry = new PricebookEntry();
        pricebookEntry.Pricebook2Id = Test.getStandardPricebookId();
        pricebookEntry.Product2Id = product.Id;
        pricebookEntry.UseStandardPrice = false;
        pricebookEntry.UnitPrice = 1;
        insert pricebookEntry;
        
        List<OrderItem> orderItemList = new List<OrderItem>();
        OrderItem orderItem1 = new OrderItem(
            SKU_Description__c = 'SKU1',
            SKU_Number__c = '111-1111',
            Quantity = 1,
            Item_Class_Description__c = 'SVC EIS',
            OrderId = order.Id,
            PriceBookEntryId = priceBookEntry.Id,
            UnitPrice = 1
        );
        orderItemList.add(orderItem1);
        
        OrderItem orderItem2 = new OrderItem(
            SKU_Description__c = 'SKU2',
            SKU_Number__c = '222-2222',
            Quantity = 1,
            Item_Class_Description__c = 'SVC Flex',
            OrderId = order.Id,
            PriceBookEntryId = priceBookEntry.Id,
            UnitPrice = 1
        );
        orderItemList.add(orderItem2);
        insert orderItemList;
        
        Test.startTest();
        Map<Id, List<OrderItem>> result = DAL_OrderItem.getOrderItemByOrderId(new Set<Id>{order.Id});
        Test.stopTest();
        
        System.assertEquals(2, result.get(order.Id).size(), 'Should return two order items.');   
    }
    
    @isTest
    static void shouldGetOrderItemById(){
        
        Boolean isInsert =True;
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        
        Account account = new Account(Name = 'Test');
        if(isInsert){
            system.runAs(loginUser[0])
            {
                insert account;
            }
        }
        
        Order order = new Order(
            OrderNumber__c = '123456789',
            AccountId = account.Id,
            EffectiveDate = Date.today(),
            BUID__c = '11',
            Status = 'BK',
            Pricebook2Id = Test.getStandardPricebookId()
        );
        insert order;
        
        Product2 product = new Product2(Name='Product Test');
        insert product;
        
        PricebookEntry pricebookEntry = new PricebookEntry();
        pricebookEntry.Pricebook2Id = Test.getStandardPricebookId();
        pricebookEntry.Product2Id = product.Id;
        pricebookEntry.UseStandardPrice = false;
        pricebookEntry.UnitPrice = 1;
        insert pricebookEntry;
        
        List<OrderItem> orderItemList = new List<OrderItem>();
        OrderItem orderItem1 = new OrderItem(
            SKU_Description__c = 'SKU1',
            SKU_Number__c = '111-1111',
            Quantity = 1,
            Item_Class_Description__c = 'SVC EIS',
            OrderId = order.Id,
            PriceBookEntryId = priceBookEntry.Id,
            UnitPrice = 1
        );
        orderItemList.add(orderItem1);
        
        OrderItem orderItem2 = new OrderItem(
            SKU_Description__c = 'SKU2',
            SKU_Number__c = '222-2222',
            Quantity = 1,
            Item_Class_Description__c = 'SVC Flex',
            OrderId = order.Id,
            PriceBookEntryId = priceBookEntry.Id,
            UnitPrice = 1
        );
        orderItemList.add(orderItem2);
        insert orderItemList;
        
        Set<Id> orderItem = new Set<Id>();
        for (OrderItem orderItemId : orderItemList) {
            orderItem.add(orderItemId.Id);
        }
        
        Test.startTest();
        Map<Id, OrderItem> result = DAL_OrderItem.getOrderItensByIds(orderItem);
        Test.stopTest();
        
        System.assertEquals(2, result.size(), 'Should return two order items.');
        
        
    }
    
    @isTest
    static void getOrderItemsByApprovalProcessTest(){
        orderItemToProjectApproval__c projectApproval = [SELECT Id FROM orderItemToProjectApproval__c LIMIT 1];
        
        Test.startTest();
        Set<id> orderItemToProjectApprovalId = new Set<Id>();
        orderItemToProjectApprovalId.add(projectApproval.Id);
        
        Map<Id, List<OrderItem>> result = DAL_OrderItem.getOrderItemsByApprovalProcess(orderItemToProjectApprovalId);
        Test.stopTest();
    }
    
    
    @isTest
    static void getOrderItemsByOrderIdRejectedProjects(){
        //Account account = MDF_AccountFactory.start().create();
        Boolean isInsert =True;
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        
        Account account = new Account(Name = 'Test');
        if(isInsert){
            system.runAs(loginUser[0])
            {
                insert account;
            }
        }
        Order order = MDF_OrderFactory.start(account).create();
        Product2 product = new Product2(Name='Product Test');
        insert product;
        
        PricebookEntry pricebookEntry = new PricebookEntry();
        pricebookEntry.Pricebook2Id = Test.getStandardPricebookId();
        pricebookEntry.Product2Id = product.Id;
        pricebookEntry.UseStandardPrice = false;
        pricebookEntry.UnitPrice = 1;
        insert pricebookEntry;
        
        OrderItem orderItem1 = new OrderItem(
            SKU_Description__c = 'SKU1',
            SKU_Number__c = '111-1111',
            Quantity = 1,
            Item_Class_Description__c = 'SVC EIS',
            OrderId = order.Id,
            PriceBookEntryId = priceBookEntry.Id,
            UnitPrice = 1
        );
        
        insert orderItem1;
        
        OrderItemToProjectApproval__c orderItemToProjectApproval = new OrderItemToProjectApproval__c(Approval_Status__c = 'Rejected');
        insert orderItemToProjectApproval;
        
        orderItem1.OrderItemToProjectApproval__c = orderItemToProjectApproval.Id;
        update orderItem1;
        
        Test.startTest();
        List<OrderItem> result = DAL_OrderItem.getOrderItensByOderIdForRejectedProjects(new Set<Id>{order.Id});
        Test.stopTest();
        
        System.assertEquals(1, result.size(), 'Should return one order item.');
        
    }
    
    @isTest
    static void getOrderItemsByProjectId(){
        //Account account = MDF_AccountFactory.start().create();
        Boolean isInsert =True;
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        
        Account account = new Account(Name = 'Test');
        if(isInsert){
            system.runAs(loginUser[0])
            {
                insert account;
            }
        }
        Order order = MDF_OrderFactory.start(account).create();
        Product2 product = new Product2(Name='Product Test');
        insert product;
        pse__proj__c project = [SELECT Id FROM pse__proj__c WHERE name = 'project Test IDS'];
        
        PricebookEntry pricebookEntry = new PricebookEntry();
        pricebookEntry.Pricebook2Id = Test.getStandardPricebookId();
        pricebookEntry.Product2Id = product.Id;
        pricebookEntry.UseStandardPrice = false;
        pricebookEntry.UnitPrice = 1;
        insert pricebookEntry;
        
        OrderItem orderItem1 = new OrderItem(
            SKU_Description__c = 'SKU1',
            SKU_Number__c = '111-1111',
            Quantity = 1,
            Item_Class_Description__c = 'SVC EIS',
            OrderId = order.Id,
            PriceBookEntryId = priceBookEntry.Id,
            UnitPrice = 1,
            Project__c = project.Id
        );
        
        insert orderItem1;
        
        Test.startTest();
        Map<Id, List<OrderItem>> result = DAL_OrderItem.getOrderItensByProjectIds(new Set<Id>{project.Id});
        Test.stopTest();
        
        System.assertEquals(1, result.get(project.Id).size(), 'Should return one order item.');
        
    }
}