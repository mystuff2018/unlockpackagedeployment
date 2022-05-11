@IsTest
public with sharing class ProjectBuidLocalChannelHandlerTest {
    @TestSetup
    static void setup() {
        //Login with Integration User Profile to create Account as a validation rule is in place to prevent Account creation by Other user in SFDC.
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){ 
            List<Account>accounts = new List<Account>();
            Account account = new Account(Name = 'Test account',
                                          BUID__c = '13',
                                          CCN__c = 'US-12');
            Account billingAccount = new Account(Name = 'Billing account',
                                                 BUID__c = '11',
                                                 CCN__c = 'US-11');
            accounts.add(account);
            accounts.add(billingAccount);
            insert accounts;
            pse__Proj__c projectTemplate = TestDataUtility.createProject(true);
            pse__Practice__c practice = new pse__Practice__c(Name = 'Global', Standard_Project_Template__c = projectTemplate.Id);
            insert practice;
            pse__Proj__c engagement = new pse__Proj__c(
                Name = 'Engagement',
                RecordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get('Parent_Project').getRecordTypeId()
            );
            insert engagement;
            pse__Proj__c project = new pse__Proj__c(
                Name = 'BUIDAndLocalChannelTest',
                pse__parent_project__c = engagement.Id,
                pse__practice__c = practice.Id,
                pse__End_Date__c = Date.Today().addDays(30),
                pse__Start_Date__c = Date.Today(),
                BUID__c = '12',
                Local_Channel__c = 'US-52',
                pse__Account__c = account.id
            );
            insert project;
            Order order = new Order(
                AccountId = account.Id,
                EffectiveDate = Date.today(),
                Status = 'BK',
                OrderNumber__c = '555666',
                BUID__c = '11',
                PriceBook2Id = Test.getStandardPricebookId(),
                Billing_Account__c = billingAccount.Id
            );
            insert order;
            Product2 product = new Product2();
            product.Name = 'Product Test';
            insert product;
            
            /*PricebookEntry pricebookEntry = [Select Id, Pricebook2Id, Product2Id FROM PricebookEntry
                                            WHERE Product2Id =:product.Id];*/
            //[Deloitte: Abhishek Kawle] - Commented this code as Product gets associated to Pricebook automatically.
           
            PricebookEntry pricebookEntry = new PricebookEntry();
            pricebookEntry.Pricebook2Id = Test.getStandardPricebookId();
            pricebookEntry.Product2Id = product.Id;
            pricebookEntry.UseStandardPrice = false;
            pricebookEntry.UnitPrice = 1;
            insert pricebookEntry; 
            
            OrderItem orderItem = new OrderItem(
                SKU_Description__c = 'SKU1',
                SKU_Number__c = '111-1111',
                Quantity = 1,
                Item_Class_Description__c = 'SVC EIS',
                OrderId = order.Id,
                PriceBookEntryId = priceBookEntry.Id,
                UnitPrice = 1
            );
            insert orderItem;
        }
    }
    @IsTest
    static void shouldInsertBuidAndLocalChannelFromAccount() {
        Test.startTest();
        pse__proj__c projeto = [select id,buid__c,local_channel__c, name from pse__proj__c where name like '%Test%' LIMIT 1];
        Test.stopTest();
        //System.assertEquals('13', projeto.buid__c);
        //System.assertEquals('US-12', projeto.local_channel__c);
    }

  /*  @IsTest
    static void shouldUpdateBuidAndLocalChannelWhenBillingAccountWasUpdated() {
        pse__proj__c project = [
                select id,buid__c,local_channel__c,Billing_Account__c,
                        name
                from pse__proj__c
                where name like '%Test%'
                LIMIT 1
        ];
        String beforeBuid = project.buid__c;
        String beforeLocalChannel = project.local_channel__c;
        Test.startTest();
        Account billing = [SELECT id from Account where name = 'Billing account' LIMIT 1];
        project.Billing_Account__c = billing.id;
        update project;
        pse__proj__c projectAfterUpdate = [
                select id,buid__c,local_channel__c,Billing_Account__c,
                        name
                from pse__proj__c
                where name like '%Test%'
                LIMIT 1
        ];
        Test.stopTest();
       // System.assertEquals('11', projectAfterUpdate.buid__c);
        System.assertEquals('US-11', projectAfterUpdate.local_channel__c);
        System.assertNotEquals(beforeBuid, projectAfterUpdate.buid__c);
        System.assertNotEquals(beforeLocalChannel, projectAfterUpdate.local_channel__c);
    }*/


    @IsTest
    static void shouldUpdateBuidAndLocalChannelIfOrderItemsWereAssociated() {
        //Login with Integration User Profile to create Account as a validation rule is in place to prevent Account creation by Other user in SFDC.
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){ 
            Order order1 = OPRTestFactory.createSimpleOrder();
            pse__proj__c project = [
                select id,buid__c,local_channel__c,Billing_Account__c,
                name
                from pse__proj__c
                where name like '%Test%'
                LIMIT 1
            ];
            System.debug('project before test' + project);
            project.Association_Flag__c = false;
            update project;
            order1.Billing_Account__c = [SELECT id from Account where name = 'Billing account' LIMIT 1].Id;
            update order1;
            Order order = [SELECT Id, (Select Id From OrderItems) FROM Order where Id = :order1.Id LIMIT 1];
            System.debug('project: projeto criado' + project.Id);
            System.debug('order' + order.Id);
            
            OrderItem item = order.OrderItems[0];
            Order_Association__e event = new Order_Association__e(
                Order_ID__c = order.Id,
                Project_ID__c = project.Id,
                Order_Item_Id__c = item.Id
            );
            
            List<Order_Association__e> listEvent = new List<Order_Association__e>();
            listEvent.add(event);
            OrderAssociationDataContext context = new OrderAssociationDataContext(listEvent);
            
            Test.startTest();
            ProjectBuidLocalChannelHandler.setBuidAndLocalChannelInProjectWhenOrderAssociated(context);
            upsert context.projectMap.values();
            Test.stopTest();
            pse__proj__c projectAfterUpdate = [
                SELECT Id,Buid__c,Local_channel__c,Billing_Account__c,
                name,Association_Flag__c
                FROM pse__proj__c
                WHERE Id = :project.Id
                LIMIT 1
            ];
            
            System.debug('project after update' + projectAfterUpdate);
            //System.assertEquals('11', projectAfterUpdate.Buid__c);
            //System.assertEquals('US-11', projectAfterUpdate.Local_channel__c);
            //System.assert(projectAfterUpdate.Association_Flag__c);
        }
    }
 }