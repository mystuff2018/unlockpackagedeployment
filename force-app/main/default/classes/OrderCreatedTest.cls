@isTest
public class OrderCreatedTest {
    @isTest              
    static void order_should_enable_process() {
        //Login with Integration User Profile to create Account
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){
            // Create Account
            Account account = new Account();
            account.Name = 'Create Account Test';
            insert account;
            
            // Create Order
            Order order = new Order();
            order.OrderNumber__c = '123456';
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
            
            PricebookEntry pricebookEntry = new PricebookEntry();
            pricebookEntry.Pricebook2Id = Test.getStandardPricebookId();
            pricebookEntry.Product2Id = product.Id;
            pricebookEntry.UseStandardPrice = false; 
            pricebookEntry.UnitPrice = 1;
            insert pricebookEntry; 
            
            
            PricebookEntry pricebookEntry2 = [Select Id, Pricebook2Id, Product2Id FROM PricebookEntry
                                             WHERE Product2Id =:product.Id];
            //[Deloitte: Abhishek Kawle] - Commented this code as Product gets associated to Pricebook automatically.
            
          
            // Order Item
            OrderItem oi = new OrderItem();
            oi.SKU_Description__c = 'SKU Desc 1';
            oi.SKU_Number__c = '777-1000';
            oi.Quantity = 1;
            oi.UnitPrice = 2;
            oi.Item_Class_Description__c = 'SVC EDT INSTLN';
            oi.Tie_Number__c = '1';
            oi.OrderId = order.Id;
            oi.PriceBookEntryId = priceBookEntry.Id;
            insert oi;
            
            // Create OrderCreated Platform Event
            Order_Created__e event = new Order_Created__e();
            event.Order_ID__c = String.valueOf(order.Id);
            event.Is_Event_Reprocessing__c = true;
            
            // create Skills
            List<pse__Skill__c> skills = new List<pse__Skill__c>();
            skills.add(new pse__Skill__c(Name = 'Project Management (Low)', pse__External_Id__c='9321'));
            skills.add(new pse__Skill__c(Name = 'Project Management (Medium)', pse__External_Id__c='9322'));
            skills.add(new pse__Skill__c(Name = 'Project Management (High)', pse__External_Id__c='9323'));
            
            insert skills;
            
            // Act
            
            Test.startTest();
            
            // Publish event
            Database.SaveResult sr = Eventbus.publish(event);
            
            Test.stopTest();
            
            // Assert
            // Verify that the publish was successful
            System.assertEquals(true, sr.isSuccess());
        }
    }

//    @isTest()
//    static void should_log_failedEvent_to_reprocess() {
//        // Arrange
//        Order_Created__e event = new Order_Created__e();
//        event.Order_ID__c = 'aaa';
//
//        // Act
//        Test.startTest();
//        Database.SaveResult sr = Eventbus.publish(event);
//        Test.stopTest();
//
//        // Assert
//        Platform_Event_Reprocessing__c logFailedEvent = [SELECT Id, Object_Id__c, Event__c, Event_Body__c FROM Platform_Event_Reprocessing__c];
//
//        System.assert(logFailedEvent != null);
//        System.assert(String.isNotEmpty(logFailedEvent.Event_Body__c));
//        System.assertEquals('aaa', logFailedEvent.Object_Id__c);
//        System.assertEquals('Order_Created', logFailedEvent.Event__c);
//    }
}