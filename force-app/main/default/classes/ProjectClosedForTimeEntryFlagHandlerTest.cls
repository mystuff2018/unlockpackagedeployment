@IsTest
public with sharing class ProjectClosedForTimeEntryFlagHandlerTest {
	public RecordType testRecordType;
    @TestSetup
    static void setup() {
		List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){
        

        Account account = new Account();
            account.Name = 'Test Account';
            insert account;
            
		Id recordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get('Small Project Tier').getRecordTypeId();
            
        pse__Proj__c projectTemplate = new pse__Proj__c(
                Name = 'Phased Project Template - Custom - Global',
           		RecordTypeId = recordTypeId,
                pse__Project_Type__c = 'Concession Delivery',
                pse__Is_Template__c = true,
                pse__Is_Active__c = true,
                pse__Start_Date__c = Date.today(),
                pse__Account__c = account.Id,
                //pse__Practice__c = practice2.Id,
                Po_Number__c = '54764648',
                Deal__c = '54764648',
            	pse__Closed_For_Time_Entry__c = true,
                DP__c = '54764648'
        );
        insert projectTemplate;

       /* pse__Practice__c practice = new pse__Practice__c(Name = 'Global');
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
                pse__Account__c = account.id,
                Buid__c = '11',
                Local_Channel__c = 'US_42',
                Accounting_acknowledgement_status__c = 'PROCESSED'

        );
        insert project;


        Order order = new Order(
                AccountId = account.Id,
                EffectiveDate = Date.today(),
                Status = 'BK',
                OrderNumber__c = '555666',
                Local_Channel__c = 'US-14',
                BUID__c = '11',
                PriceBook2Id = Test.getStandardPricebookId(),
                Billing_Account__c = billingAccount.Id
        );
        insert order;

        Product2 product = new Product2();
        product.Name = 'Product Test';
        insert product;

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
    static void shouldCheckClosedForTimeEntryFlag() {
        Order order1 = OPRTestFactory.createSimpleOrder();

        pse__proj__c project = [
                select id,buid__c,local_channel__c,Billing_Account__c,
                        name
                from pse__proj__c
                where name like '%Test%'
                LIMIT 1
        ];

        System.debug('project before test' + project);

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
        ProjectClosedForTimeEntryFlagHandler.setProjectCloseForTimeEntryFlag(context);
        upsert context.projectMap.values();
        Test.stopTest();

        pse__proj__c projectAfterUpdate = [
                SELECT Id,pse__Closed_For_Time_Entry__c
                FROM pse__proj__c
                WHERE Id = :project.Id
                LIMIT 1
        ];

        System.debug('project after update' + projectAfterUpdate);
        System.assert(projectAfterUpdate.pse__Closed_For_Time_Entry__c);
    
    }*/
        }
    }
}