/**
* Created by Bruno_Frosi on 1/27/2020.
*/

@IsTest
public class CreateProjectTriggerHandlerTest {
    
    @isTest
    static void shouldPublishEventCreateProjectSuccesfully() {
        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Group g1 = new Group(Name='ISG_Test2_Projects', type='Queue');
            insert g1;
            QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'pse__Proj__c');
            insert q1;
        }
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){
            pse__Region__c globalRegion = OPRTestFactory.newRegion('Global', null, true);
            INSERT globalRegion;
            
            pse__Region__c parentRegion = OPRTestFactory.newRegionWithParent('Test2', ' ', true, globalRegion.Id);
            INSERT parentRegion;
            
            pse__Region__c region = OPRTestFactory.newRegionWithParent('Test', 'US', true, parentRegion.Id);
            INSERT region;
            
            Account account = new Account(Name = 'Test');
            insert account;
            
            
            
            List<pse__Proj__c> projectList = new List<pse__Proj__c>();
            
            
            pse__Proj__c projectTemplate = new pse__Proj__c(
                Name='Phased Project Template - Custom - Global',
                pse__Project_Type__c = 'Concession Delivery',
                pse__Is_Template__c = true,
                pse__Is_Active__c = true,
                pse__Start_Date__c = Date.today(),
                pse__Account__c = account.Id,
                //pse__Practice__c = practice2.Id,
                Po_Number__c = '54764648',
                Deal__c = '54764648',
                DP__c = '54764648'
            );
            projectList.add(projectTemplate);
            
            pse__Proj__c engagement = new pse__Proj__c(
                Name = 'Engagement Test',
                RecordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get('Parent_Project').getRecordTypeId()
            );
            projectList.add(engagement);
            
            insert projectList;
            
            List<pse__Practice__c> practiceList = new List<pse__Practice__c>();
            pse__Practice__c practice1 = new pse__Practice__c(Name = 'Global', Standard_Project_Template__c = projectList[0].Id);
            
            practiceList.add(practice1);
            insert practiceList;
            
            pse__Practice__c practice2 = new pse__Practice__c(Name = 'IDS', Standard_Project_Template__c = projectList[0].Id);
            upsert practice2;
            
            Item_Class__c item = MDF_ItemClassFactory.start().itemClassDescription('SVC EIS').relatedPractice(practice2).keyPractice(true).tower('ISG').create();																																					 
            
            pse__Proj__c project = new pse__Proj__c(
                Name = 'project Test IDS',
                pse__parent_project__c = engagement.Id,
                pse__practice__c = practice2.Id,
                pse__End_Date__c = Date.Today().addDays(30),
                pse__Start_Date__c = Date.Today()
            );
            projectList.add(project);
            
            
            
            Order order = new Order(
                OrderNumber__c = '123456789',
                AccountId = account.Id,
                Shipping_Account__c = account.Id,
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
            
            OrderItemGroupingCompositeKey groupingKey = new OrderItemGroupingCompositeKey(
                String.valueOf(practice2.Id), order, 
                null, String.valueOf(engagement.Id), 'Concession Delivery', 'Standard', false
            );
            
            Create_Project__e event = new Create_Project__e();
            event.Order_ID__c = String.valueOf(order.Id);
            event.OrderItemList__c = String.valueOf(orderItem1.Id);
            event.Grouping_key__c = groupingKey.toString();
            event.Practice_Id__c = String.valueOf(practice2.Id);
            event.Engagement_ID__c = String.valueOf(engagement.Id);
            
            Test.startTest();
            Database.SaveResult sr = Eventbus.publish(event);
            Test.stopTest();
            
            System.assertEquals(true, sr.isSuccess(), 'Event result should be "success"');
        }
    }
}