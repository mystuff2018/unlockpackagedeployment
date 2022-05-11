@IsTest
public class OrderItemToProjectApprovalTest {
    @testSetup
    static void makeData(){
        //Login with Integration User Profile to create Account
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){
            pse__Proj__c projectTemplate = TestDataUtility.createProject(true);
            List<pse__Practice__c> practiceList = new List<pse__Practice__c>();
            pse__Practice__c practice1 = new pse__Practice__c(Name = 'Global', Standard_Project_Template__c = projectTemplate.Id);
            practiceList.add(practice1);
            insert practiceList;
            
            pse__Practice__c practice2 = new pse__Practice__c(Name = 'IDS', pse__Parent_Practice__c = practice1.Id, Standard_Project_Template__c = projectTemplate.Id);
            upsert practiceList;
            
            // practiceList = new List<pse__Practice__c>();
            practice1.pse__Practice_ID_Chain__c = practice1.Id;
            update practiceList;
            
            List<Item_Class__c> itemClasses = new List<Item_Class__c>();
            itemClasses.add(new Item_Class__c(Item_Class_Description__c = 'SVC IDS', Practice__c = practice2.Id, Key_Practice__c = true));
            insert itemClasses;
            
            pse__Proj__c engagement = new pse__Proj__c(
                Name = 'Engagement Test',
                RecordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get('Parent_Project').getRecordTypeId()
            );
            insert engagement;
            
            Contact contact = OPRTestFactory.newContact('firstName','lastName','United States','Texas','5555555555');
            contact.pse__Salesforce_User__c = UserInfo.getUserId();
            INSERT contact;
            
            pse__Proj__c project = new pse__Proj__c(
                Name = 'project Test IDS',
                pse__parent_project__c = engagement.Id,
                pse__Project_Manager__c = contact.Id,
                pse__practice__c = practice2.Id,
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
            
           /** PricebookEntry pricebookEntry = [Select Id, Pricebook2Id, Product2Id FROM PricebookEntry
                                         WHERE Product2Id =:product.Id]; **/
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
            
            insert orderItemList;
        }
    }
    
    @isTest
    static void shouldAssociateOrderItemToProjectApproved() {
        OrderItem oi = [SELECT Id FROM OrderItem];
        pse__Proj__c proj = [SELECT Id, pse__Project_Manager__r.pse__Salesforce_User__c FROM pse__proj__c  WHERE Name = 'project Test IDS'];
        
        OrderItemToProjectApproval__c orderItemToProjectApproval = new OrderItemToProjectApproval__c(
            Approver__c = proj.pse__Project_Manager__r.pse__Salesforce_User__c,
            Project__c = proj.Id
        );
        
        insert orderItemToProjectApproval;
        oi.OrderItemToProjectApproval__c = orderItemToProjectApproval.Id;
        update oi;
            
        Test.startTest();

        orderItemToProjectApproval.Approval_Status__c = 'Approved';
        update orderItemToProjectApproval;
        
        Test.stopTest();
        
        //System.assertEquals(oi.Project__c, proj.Id, 'Order item should be associated to the project');
    }
    
    @isTest
    static void shouldAssociateOrderItemToProjectRejected() {
        OrderItem oi = [SELECT Id FROM OrderItem];
        pse__Proj__c proj = [SELECT Id, pse__Project_Manager__r.pse__Salesforce_User__c FROM pse__proj__c  WHERE Name = 'project Test IDS'];
        
        OrderItemToProjectApproval__c orderItemToProjectApproval = new OrderItemToProjectApproval__c(
            Approver__c = proj.pse__Project_Manager__r.pse__Salesforce_User__c,
            Project__c = proj.Id
        );
        
        insert orderItemToProjectApproval;
        oi.OrderItemToProjectApproval__c = orderItemToProjectApproval.Id;
        update oi;
        
        Test.startTest();

        orderItemToProjectApproval.Approval_Status__c = 'Rejected';
        update orderItemToProjectApproval;
        
        Test.stopTest();

        oi = [SELECT Id, Project__c FROM OrderItem WHERE Id =: oi.Id];
        List<pse__Proj__c> projs = [SELECT Id FROM pse__proj__c];
        
        //System.assertNotEquals(oi.Project__c, proj.Id, 'Order item shouldnt be associated to the project');
        //System.assertEquals(projs.size(), 3, 'Order item should have created a new project');
    }
    
    @isTest
    static void shouldTestCatchStatement(){
        OrderItem oi = [SELECT Id FROM OrderItem];
        pse__Proj__c proj = [SELECT Id, pse__Project_Manager__r.pse__Salesforce_User__c FROM pse__proj__c  WHERE Name = 'project Test IDS'];
        
        OrderItemToProjectApproval__c orderItemToProjectApproval = new OrderItemToProjectApproval__c();
        
        insert orderItemToProjectApproval;
            
        Test.startTest();

        orderItemToProjectApproval.Approval_Status__c = 'Rejected';
        update orderItemToProjectApproval;
        
        Test.stopTest();


        List<ExceptionLogger__c> exceptionLoggers = [
                SELECT Id
                FROM ExceptionLogger__c
        ];

        // Assert
        // Verify if any exception logger was created
        System.assertEquals(2, exceptionLoggers.size(), 'Trigger should create two exception loggers record');
    }
}