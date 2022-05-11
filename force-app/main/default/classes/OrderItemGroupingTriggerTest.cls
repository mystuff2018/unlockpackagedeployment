@isTest
public class OrderItemGroupingTriggerTest {
    
     @isTest              
     static void OrderItemGrouping_PublishEvent() {
         //Login with Integration User Profile to create Account
         List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
         system.runAs(loginUser[0]){       
             // Create Account
             Account account = new Account();
             account.Name = 'Create Account Test';
             insert account;
             pse__Proj__c projectTemplate = TestDataUtility.createProject(true);
             // Create Practice
             pse__Practice__c practice1 = new pse__Practice__c(Name = 'Global', Standard_Project_Template__c = projectTemplate.Id);
             insert practice1;
             pse__Practice__c practice2 = new pse__Practice__c(Name = 'Dell Services', pse__Parent_Practice__c = practice1.Id, Standard_Project_Template__c = projectTemplate.Id);
             insert practice2;
             pse__Practice__c practice3 = new pse__Practice__c(Name = 'IDS', pse__Parent_Practice__c = practice2.Id, Standard_Project_Template__c = projectTemplate.Id);
             insert practice3;
             
             practice1.pse__Practice_ID_Chain__c = practice1.Id;
             practice2.pse__Practice_ID_Chain__c = practice2.Id + ',' + practice1.Id;
             practice3.pse__Practice_ID_Chain__c = practice3.Id + ',' + practice2.Id + ',' + practice1.Id;
             
             update new List<pse__Practice__c>{practice1, practice2, practice3};
                 
                 // Create Item Class
                 Item_Class__c itemClass = new Item_Class__c(Item_Class_Description__c = 'SVC IDS', Practice__c = practice2.Id, Key_Practice__c = true);
             insert itemClass;
             
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
             
             PricebookEntry testPricebookEntry = new PricebookEntry();
             testPricebookEntry.Pricebook2Id =  order.Pricebook2Id;
             testPricebookEntry.Product2Id = product.id;
             testPricebookEntry.UnitPrice = 100;
             insert testPricebookEntry;
             
             PricebookEntry pricebookEntry = [Select Id, Pricebook2Id, Product2Id FROM PricebookEntry
                                              WHERE Product2Id =:product.Id];
             //[Deloitte: Abhishek Kawle] - Commented this code as Product gets associated to Pricebook automatically.
             /*
             PricebookEntry pricebookEntry = new PricebookEntry();
             pricebookEntry.Pricebook2Id = Test.getStandardPricebookId();
             pricebookEntry.Product2Id = product.Id;
             pricebookEntry.UseStandardPrice = false; 
             pricebookEntry.UnitPrice = 1;
             insert pricebookEntry;
			 */
             
             // Order Item
             OrderItem oi = new OrderItem();
             oi.SKU_Description__c = 'SKU Desc 1';
             oi.SKU_Number__c = '777-1000';
             oi.Quantity = 1;
             oi.UnitPrice = 2;
             oi.Item_Class_Description__c = 'SVC IDS';
             oi.Tie_Number__c = '1';
             oi.OrderId = order.Id;
             oi.PriceBookEntryId = priceBookEntry.Id;
             insert oi;
             
             
             
             pse__Proj__c engagement1 = new pse__Proj__c(
                 Name = 'Engagement Test 1',
                 RecordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get('Parent_Project').getRecordTypeId()
             );
             insert engagement1;
             // Create OrderCreated Platform Event
             Order_Item_Grouping__e event = new Order_Item_Grouping__e();
             event.Order_ID__c = order.Id;
             event.Engagement_ID__c = engagement1.Id;
             
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
}