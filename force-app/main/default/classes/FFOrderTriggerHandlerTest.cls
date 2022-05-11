@isTest
public class FFOrderTriggerHandlerTest {
    @TestSetup
    private static void setupTestData() {
        
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){
            Account account = new Account(Name = 'Test account');
            insert account;
        }
        
    }
    
    @isTest
    static void shouldChangeStatusToFFNewOrder(){
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){
            Account account = [SELECT Id, Name FROM Account WHERE Name = 'Test account'];
            
            Product2 product = new Product2(Name='Product Test');
            insert product;
            
            PricebookEntry pricebookEntry = new PricebookEntry(Pricebook2Id=Test.getStandardPricebookId(), Product2Id=product.Id,  UseStandardPrice=false, UnitPrice=1);
            insert pricebookEntry;
            
            Test.startTest();
            
            Order order = new Order(
                AccountId = account.Id,
                EffectiveDate = Date.today(),
                PoNumber = '888999',
                Deal_ID__c = '000111',
                OrderNumber__c = '555666',
                PriceBook2Id = Test.getStandardPricebookId(),
                BUID__c = '11',
                FF_Feed__c = true,
                Status = 'BK',
                Order_Status__c = 'CLD'
            );
            insert order;
            
            OrderItem orderItem = new OrderItem(
                SKU_Number__c = '444-999', 
                Quantity = 1, 
                OrderId = order.Id, 
                PricebookEntryId = pricebookEntry.Id, 
                UnitPrice = 1
            );
            insert orderItem;
            
            Order orderAfterInsert = [
                SELECT Id, Order_Status__c
                FROM Order
                WHERE Id = :order.Id
                LIMIT 1
            ];
            
            System.assertEquals('CD', orderAfterInsert.Order_Status__c);
            
            order.Status = 'CL';
            order.Order_Status__c = 'CL';
            update order;
            
            Order orderAfterUpdate = [
                SELECT Id, Status
                FROM Order
                WHERE Id = :order.Id
                LIMIT 1
            ];
            System.assertEquals('CL', orderAfterUpdate.Status);
            
            Test.stopTest();
        }
    }
    
    @isTest
    static void shouldSetSAPRecordType(){
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){
            Account account = [SELECT Id, Name FROM Account WHERE Name = 'Test account'];
            
            Product2 product = new Product2(Name='Product Test');
            insert product;
            
            PricebookEntry pricebookEntry = new PricebookEntry(Pricebook2Id=Test.getStandardPricebookId(), Product2Id=product.Id,  UseStandardPrice=false, UnitPrice=1);
            insert pricebookEntry;
            
            Test.startTest();
            
            Order order = new Order(
                AccountId = account.Id,
                EffectiveDate = Date.today(),
                PoNumber = '888999',
                Deal_ID__c = '000111',
                OrderNumber__c = '555666',
                PriceBook2Id = Test.getStandardPricebookId(),
                BUID__c = '99901',
                FF_Feed__c = true,
                Status = 'BK',
                Order_Status__c = 'CLD'
            );
            insert order;
            
            OrderItem orderItem = new OrderItem(
                SKU_Number__c = '444-999', 
                Quantity = 1, 
                OrderId = order.Id, 
                PricebookEntryId = pricebookEntry.Id, 
                UnitPrice = 1
            );
            insert orderItem;
            
            Order orderAfterInsert = [
                SELECT Id, Order_Status__c
                FROM Order
                WHERE Id = :order.Id
                LIMIT 1
            ];
            
            System.assertEquals('CD', orderAfterInsert.Order_Status__c);
            
            order.Status = 'CL';
            order.Order_Status__c = 'CL';
            update order;
            
            Order orderAfterUpdate = [
                SELECT Id, Status
                FROM Order
                WHERE Id = :order.Id
                LIMIT 1
            ];
            System.assertEquals('CL', orderAfterUpdate.Status);
            
            Test.stopTest();
        }
    }
}