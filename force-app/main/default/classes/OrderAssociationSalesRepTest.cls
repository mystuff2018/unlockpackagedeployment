/*
* @class OrderAssociationSalesRep
* @authors Pablo Dunke and Christopher Michel
* @date 01/31/2020
* @Modification Log  : Version 1.0 - [Abhishek Kawle] : Updated script to test OrderAssociationSalesRep class. Feature #7865383
*/

@isTest
private class OrderAssociationSalesRepTest 
{
     @IsTest
     static void testSetProjectSalesRep() 
     {
         List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
         system.runAs(loginUser[0]){ 
             List<Account> accountList = FBE_Test_Utility.createAccount(1);
             accountList[0].Name = System.label.FBE_Order_Interlock_Sales_Rep_Account;
             insert accountList;
             
             // Create the data
             pse__Proj__c project = OPRTestFactory.createProject();
             
             //Setup Contact with Badge Id
             String badgeOne = '456789';
             Contact salesRep = OPRTestFactory.createSimpleContact();
             salesRep.Badge_ID__c = badgeOne;
             salesRep.AccountId = accountList[0].Id;
             update salesRep;
             
             Order order = OPRTestFactory.newOrderWithItem('123123', accountList[0].Id, salesRep.Id, 'United States', 'Texas', 'United States', 'Texas', '111', '222', '333',
                                                           accountList[0].Id, null, null, null, '12', 'NOT IDS');
             
             //Order order = OPRTestFactory.createOrderStateCountry(null, null, null, null, 'United States', 'Texas');
             order.FBE_Sales_Rep_Badge_Id__c = badgeOne;
             order.FBE_Sales_Rep_Email__c = 'testone@test.com';
             order.Sales_Rep_Name__c = 'Test Contact One';
             order.FBE_Sales_Rep_Phone__c = '9876541231';
             //order.Sales_Rep__c = salesRep.Id;
             update order;
             
             // Order Product
            /* Product2 product = new Product2();
             product.Name='Product Test2';
             insert product;
             
             PricebookEntry pricebookEntry = [Select Id, Pricebook2Id, Product2Id FROM PricebookEntry
                                              WHERE Product2Id =:product.Id]; */
             
             /* PricebookEntry pricebookEntry = new PricebookEntry();
            pricebookEntry.Pricebook2Id = Test.getStandardPricebookId();
            pricebookEntry.Product2Id = product.Id;
            pricebookEntry.UseStandardPrice = false; 
            pricebookEntry.UnitPrice = 1;
            insert pricebookEntry; */
             
             // Order Item
            /* OrderItem oi = new OrderItem();
             oi.SKU_Description__c = 'SKU Desc 1';
             oi.SKU_Number__c = '777-1000';
             oi.Quantity = 1;
             oi.UnitPrice = 1;
             oi.Item_Class_Description__c = 'SVC EDT INSTLN';
             oi.Tie_Number__c = '1';
             oi.OrderId = order.Id;
             oi.PriceBookEntryId = priceBookEntry.Id;
             oi.SKU_Cost__c = 1;
             oi.Unit_Selling_Price_USD__c = 1;
             oi.SKU_Cost_USD__c = 1;
             insert oi; */
             
            Order order1 = [SELECT Id, (select Id, OrderId, Project__c from OrderItems) FROM Order WHERE Id = :order.Id LIMIT 1];
            Order_Association__e event = new Order_Association__e(
                Order_ID__c = order.Id,
                Project_ID__c = project.Id,
                Order_Item_Id__c = order1.OrderItems[0].Id
            );
             
             List<Order_Association__e> eventList = new List<Order_Association__e>{event};
                 OrderAssociationDataContext context = new OrderAssociationDataContext(eventList);
             
             // Action
             Test.startTest();
             OrderAssociationSalesRep.setProjectSalesRep(context);
             upsert context.projectMap.values();
             Test.stopTest();
             
             // Assertion
             pse__Proj__c result = [SELECT Id, Sales_Rep__c FROM pse__Proj__c WHERE Id =: project.Id LIMIT 1];
             Order createdOrder = [SELECT Id, Sales_Rep__c FROM Order Where Id =:order.Id];
             
             System.assertEquals(result.Sales_Rep__c, createdOrder.Sales_Rep__c);
             System.assertEquals(salesRep.Id, createdOrder.Sales_Rep__c);
        }
     }
    
    //New method to test new contact record gets created when Sales Rep record with Badge Id doesnt exist.
    @IsTest
    static void testNewSalesRepCreation() {
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){ 
            List<Account> accountList = FBE_Test_Utility.createAccount(1);
            accountList[0].Name = System.label.FBE_Order_Interlock_Sales_Rep_Account;
            insert accountList;
            // Create the data
            String badgeTwo = '456790';
            pse__Proj__c project = OPRTestFactory.createProject();
            
            //Order order = OPRTestFactory.createOrderStateCountry(null, null, null, null, 'United States', 'Texas');
            Contact contact = OPRTestFactory.newContact('firstName','lastName','United States','Texas','2345768933');
            //contact.Phone = '2345768933';
            insert contact;
            //List<Order> orders = new List<Order>();
            Order order = OPRTestFactory.newOrderWithItem('123123', accountList[0].Id, contact.Id, 'United States', 'Texas', 'United States', 'Texas', '111', '222', '333',
                                                           accountList[0].Id, null, null, null, '12', 'NOT IDS');
            order.FBE_Sales_Rep_Badge_Id__c = badgeTwo;
            order.FBE_Sales_Rep_Email__c = 'testtwo@test.com';
            order.Sales_Rep_Name__c = 'Test Contact Two';
            order.FBE_Sales_Rep_Phone__c = '9876541232';
            //order.Sales_Rep__c = salesRep.Id;
            update order;
            
            // Order Product
            /*Product2 product = new Product2();
            product.Name='Product Test3';
            insert product;
            
            PricebookEntry pricebookEntry = [Select Id, Pricebook2Id, Product2Id FROM PricebookEntry
                                             WHERE Product2Id =:product.Id]; */
            /*PricebookEntry pricebookEntry = new PricebookEntry();
            pricebookEntry.Pricebook2Id = Test.getStandardPricebookId();
            pricebookEntry.Product2Id = product.Id;
            pricebookEntry.UseStandardPrice = false; 
            pricebookEntry.UnitPrice = 10;
            insert pricebookEntry; */
            
            // Order Item
           /* OrderItem oi = new OrderItem();
            oi.SKU_Description__c = 'SKU Desc 1';
            oi.SKU_Number__c = '777-1000';
            oi.Quantity = 1;
            oi.UnitPrice = 1;
            oi.Item_Class_Description__c = 'SVC EDT INSTLN';
            oi.Tie_Number__c = '1';
            oi.OrderId = order.Id;
            oi.PriceBookEntryId = priceBookEntry.Id;
            oi.SKU_Cost__c = 1;
            oi.Unit_Selling_Price_USD__c = 1;
            oi.SKU_Cost_USD__c = 1;
            insert oi; */
            
            Order order1 = [SELECT Id, (select Id, OrderId, Project__c from OrderItems) FROM Order WHERE Id = :order.Id LIMIT 1];
            System.debug('Order Item: '+order1.OrderItems[0]);
            Order_Association__e event = new Order_Association__e(
                Order_ID__c = order.Id,
                Project_ID__c = project.Id,
                Order_Item_Id__c = order1.OrderItems[0].Id
            );
            
            List<Order_Association__e> eventList = new List<Order_Association__e>{event};
                OrderAssociationDataContext context = new OrderAssociationDataContext(eventList);
            
            // Action
            Test.startTest();
            OrderAssociationSalesRep.setProjectSalesRep(context);
            upsert context.projectMap.values();
            Test.stopTest();
            
            Order createdOrder2 = [SELECT Id, Sales_Rep__c, Sales_Rep__r.Name FROM Order Where Id =:order.Id];
            System.assertEquals('Test Contact Two', createdOrder2.Sales_Rep__r.Name);
        }
    }
}