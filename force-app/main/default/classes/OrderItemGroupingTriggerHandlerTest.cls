@IsTest
public class OrderItemGroupingTriggerHandlerTest {

    @testSetup
    static void makeData(){
        //Login with Integration User Profile to setup Data
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){
            
            pse__Proj__c projectTemplate = TestDataUtility.createProject(true);
            
            List<pse__Practice__c> practiceList = new List<pse__Practice__c>();
            pse__Practice__c practice1 = new pse__Practice__c(Name = 'Global', Standard_Project_Template__c = projectTemplate.Id);
            practiceList.add(practice1);
            insert practiceList;
            
            pse__Practice__c practice2 = new pse__Practice__c(Name = 'IDS', pse__Parent_Practice__c = practice1.Id, Standard_Project_Template__c = projectTemplate.Id);
            pse__Practice__c practice3 = new pse__Practice__c(Name = 'Consulting', pse__Parent_Practice__c = practice1.Id, Standard_Project_Template__c = projectTemplate.Id);
            pse__Practice__c practice4 = new pse__Practice__c(Name = 'HES', pse__Parent_Practice__c = practice1.Id, Standard_Project_Template__c = projectTemplate.Id);
            practiceList.add(practice2);
            practiceList.add(practice3);
            practiceList.add(practice4);
            upsert practiceList;
            
            pse__Practice__c practice5 = new pse__Practice__c(Name = 'EIS', pse__Parent_Practice__c = practice2.Id, Standard_Project_Template__c = projectTemplate.Id);
            pse__Practice__c practice6 = new pse__Practice__c(Name = 'Flex', pse__Parent_Practice__c = practice2.Id, Standard_Project_Template__c = projectTemplate.Id);
            practiceList.add(practice5);
            practiceList.add(practice6);
            upsert practiceList;
            
            // practiceList = new List<pse__Practice__c>();
            practice1.pse__Practice_ID_Chain__c = practice1.Id;
            practice2.pse__Practice_ID_Chain__c = practice2.Id + ',' + practice1.Id;
            practice3.pse__Practice_ID_Chain__c = practice3.Id + ',' + practice1.Id;
            practice4.pse__Practice_ID_Chain__c = practice4.Id + ',' + practice1.Id;
            practice5.pse__Practice_ID_Chain__c = practice5.Id + ',' + practice2.Id + ',' + practice1.Id;
            practice6.pse__Practice_ID_Chain__c = practice6.Id + ',' + practice2.Id + ',' + practice1.Id;
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
    static void shouldPublishEventSuccesfully() {
        //Login with Integration User Profile to setup Data
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){
            pse__Proj__c engagement = new pse__Proj__c(
                Name = 'Engagement Test',
                RecordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get('Parent_Project').getRecordTypeId()
            );
            insert engagement;
            
            pse__Proj__c project = new pse__Proj__c(
                Name = 'project Test IDS',
                pse__parent_project__c = engagement.Id,
                pse__practice__c = [Select Id From pse__practice__c Where Name = 'IDS'][0].Id,
                pse__End_Date__c = Date.Today().addDays(30),
                pse__Start_Date__c = Date.Today()
            );
            insert project;
            
            Account account = new Account(Name = 'Test');
            insert account;
            
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
            
            /*PricebookEntry pricebookEntry = [Select Id, Pricebook2Id, Product2Id FROM PricebookEntry
                                             WHERE Product2Id =:product.Id];**/
            //[Deloitte: Abhishek Kawle] - Commented this code as Product gets associated to Pricebook automatically.
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
            
            Order_Item_Grouping__e event = new Order_Item_Grouping__e();
            event.Order_ID__c = String.valueOf(order.Id);
            event.Engagement_ID__c = String.valueOf(engagement.Id);
            
            Test.startTest();
            Database.SaveResult sr = Eventbus.publish(event);
            Test.stopTest();
            
            System.assertEquals(true, sr.isSuccess(), 'Event result should be "success"');
        }
    }
    
    @isTest
    static void shouldTestCatchStatement(){
        /* Should test the catch statement of trigger sending a event with missing
		data */
        //Login with Integration User Profile to setup Data
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){
            
            Order_Item_Grouping__e event = new Order_Item_Grouping__e();
            event.Order_ID__c = String.valueOf('21312412412');
            
            Test.startTest();
            Database.SaveResult sr = Eventbus.publish(event);
            Test.stopTest();
            
            System.assertEquals(true, sr.isSuccess(), 'Event result should be "success"');
            
            List<ExceptionLogger__c> exceptionLoggers = [
                SELECT Id
                FROM ExceptionLogger__c
            ];
            
            // Assert
            // Verify if any exception logger was created
            System.assertEquals(2, exceptionLoggers.size(), 'Trigger should create two exception loggers record');
        }
    }
}