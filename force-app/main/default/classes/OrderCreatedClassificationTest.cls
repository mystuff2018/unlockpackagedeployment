/**
 * Created by Romulo_Spier on 1/15/2020.
 */
@IsTest
public class OrderCreatedClassificationTest {
    @IsTest
    static void shouldNotCreateProject() {
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){
            List<Account> listAcc = new List<Account>();
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '111'));
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '123'));
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '234'));
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '345'));
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '456'));
            INSERT listAcc;
            Contact contact = OPRTestFactory.newContact('firstName','lastName','United States','Texas','5672673492');
            INSERT contact;
            Order order = OPRTestFactory.newOrderWithItem('123123', listAcc[0].Id, contact.Id, 'United States', 'Texas', 'United States', 'Texas', '111', '222', '333',
                    listAcc[1].Id,
                    listAcc[2].Id,
                    listAcc[3].Id,
                    listAcc[4].Id);
            order.Type = 'Order_Type_IDS';
    
            Item_Class__c itemClass = new Item_Class__c();
            itemClass.Item_Class_Description__c = 'SVC EDT INSTLN';
            itemClass.Key_Practice__c = true;
            insert itemClass;
    
            Set<Id> setIdOrders = new Set<Id>();
            setIdOrders.add(order.Id);
    
            OrderCreatedDataContext context = new OrderCreatedDataContext(setIdOrders);
    
            Test.startTest();
            OrderCreatedClassification.ClassificateOrders(context);
            Test.stopTest();
    
            System.assertEquals(0, context.orderMap.size(), 'Order map should have one order to create custom project');
            System.assertEquals(1, context.customOrdersToUpdate.size(), 'Custom order list should have one order to update as custom order');
        }
    }
    
    @IsTest
    static void shouldNotCreateEngagementForHardwareOnlyOrder() {
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){
            List<Account> listAcc = new List<Account>();
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '111'));
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '123'));
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '234'));
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '345'));
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '456'));
            INSERT listAcc;
            
            Contact contact = OPRTestFactory.newContact('firstName','lastName','United States','Texas','5672673495');
            INSERT contact;
            
            Order order = OPRTestFactory.newOrderWithItem('123123', listAcc[0].Id, contact.Id, 
            'United States', 'Texas', '', '', '111', '222', '333',
                    listAcc[1].Id,
                    listAcc[2].Id,
                    listAcc[3].Id,
                    listAcc[4].Id,
                    null, 'NOT IDS');
            order.Type = 'Order_Type_IDS';
            
            Set<Id> setIdOrders = new Set<Id>();
            setIdOrders.add(order.Id);
    
            OrderCreatedDataContext context = new OrderCreatedDataContext(setIdOrders);
    
            Test.startTest();
            OrderCreatedClassification.ClassificateOrders(context);
            Test.stopTest();
    
            System.assertEquals(1, context.hardwareOrders.size(), 'Order should be classificated as hardware');
        }            
    }

    @IsTest
    static void shouldDiscartNonFFOrder() {
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){
            Account account = MDF_AccountFactory.start().create();
        
            Contact contact = MDF_ContactFactory.start().create();
            
            Order order = MDF_OrderFactory.start(account).FFFeed(false).create();
            OrderItem orderItem = MDF_OrderItemFactory.start(order).create();
            
            Set<Id> setOrderIds = new Set<Id>{order.Id};
    
            OrderCreatedDataContext context = new OrderCreatedDataContext(setOrderIds);
    
            Test.startTest();
            OrderCreatedClassification.removeNonFFOrder(context);
            Test.stopTest();
    
            System.Assert(order.Project__c == null, 'Non-FF Orders shoul not have an engagement tied');
            System.assertEquals(1, context.exceptionLoggers.size(), 'Non-FF Orders Should create an exception log');      
        }
    }

    @IsTest
    static void shouldDiscartOrdersWithoutOrderItems() {
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){
            Account account = MDF_AccountFactory.start().create();
        
            Contact contact = MDF_ContactFactory.start().create();
            
            Order order = MDF_OrderFactory.start(account).FFFeed(true).create();
            
            Set<Id> setOrderIds = new Set<Id>{order.Id};
    
            OrderCreatedDataContext context = new OrderCreatedDataContext(setOrderIds);
    
            Test.startTest();
            OrderCreatedClassification.removeOrdersWithoutOrderItems(context);
            Test.stopTest();
    
            System.assert(context.orderMap.size() == 0);
            System.assertEquals(1, context.exceptionLoggers.size(), 'Orders withput Order Items Should create an exception log');   
        }
    }
    
    @isTest
    static void shouldCreateStandardProjectForNonIds(){

        List<String> skuNumbersToMap1 = new List<String>{'111-1111'};
        Map<String, String> phaseByTask = new Map<String, String>();
        phaseByTask.put('Scoping', 'Initiate');
        
        SKU_Effort_Map__c skuEffort1 = OPRTestFactory.createSkuEffortMap(skuNumbersToMap1, 10, false, phaseByTask);
        
        pse__Proj__c project1 = OPRTestFactory.createSimpleProject();
        update project1;

        Order order1 = OPRTestFactory.createSimpleOrder();
        order1.OCI_Order_Type__c = 'ALL';
        order1.Sales_Channel__c = 'ALL';
        update order1;

        OrderItem orderItem = [
            SELECT Id, SKU_Number__c, PriceBookEntryId, Item_Class_Description__c
            FROM OrderItem
            WHERE OrderId = :order1.Id
            LIMIT 1
        ];
        
        orderItem.Item_Class_Description__c = 'Non SVC EDT INSTLN Description';
        orderItem.SKU_Number__c = '111-1111';
        update orderItem;
        
        OPRTestFactory.createOrderImportQueue(order1, project1);

        Set<Id> setIdOrders = new Set<Id>();
        setIdOrders.add(order1.Id);

        OrderCreatedDataContext context = new OrderCreatedDataContext(setIdOrders);
        
        Test.startTest();
        OrderCreatedClassification.ClassificateOrders(context);
        Test.stopTest();

        System.assertEquals(1, context.orderMap.size(), 'Order map should have one order to create project');

    }

    @isTest
    static void shouldVerifyOrderAndCreateProject(){
        
        pse__Proj__c project1 = OPRTestFactory.createSimpleProject();
        update project1;

        Order order1 = OPRTestFactory.createSimpleOrder();
        order1.OCI_Order_Type__c = 'ALL';
        order1.Sales_Channel__c = 'ALL';
        update order1;
        
        OPRTestFactory.createOrderImportQueue(order1, project1);

        Set<Id> setIdOrders = new Set<Id>();
        setIdOrders.add(order1.Id);
        
        Order_Processing__c orderProcessing = new Order_Processing__c(OrderId__c = order1.Id, ProcessStatus__c = 'Pending');
        insert orderProcessing;

        OrderCreatedDataContext context = new OrderCreatedDataContext(setIdOrders);
        context.listOrderProcessing = new List<Order_Processing__c>{orderProcessing};
        
        Test.startTest();
        OrderCreatedClassification.verifyOrderImportQueue(context);
        context.save();
        Test.stopTest();

        System.assertEquals(project1.Id, context.orderToProjectAssociate.get(order1.Id), 'Order to project associate map should have order and project');
        System.assertEquals(null, context.orderMap.get(order1.Id), 'Order map should not have order');
        System.assertEquals(1, context.listUpdateImportQueue.size(), 'List update import queue should have one order import queue');

    }

    @isTest
    static void shouldVerifyOrderAndNotCreateProject(){
        
        pse__Proj__c project1 = OPRTestFactory.createSimpleProject();
        update project1;

        Order order1 = OPRTestFactory.createSimpleOrder();
        order1.OCI_Order_Type__c = 'FED';
        order1.Sales_Channel__c = 'ALL';
        update order1;
        
        OPRTestFactory.createOrderImportQueue(order1, project1);

        Set<Id> setIdOrders = new Set<Id>();
        setIdOrders.add(order1.Id);

        Order_Processing__c orderProcessing = new Order_Processing__c(OrderId__c = order1.Id, ProcessStatus__c = 'Pending');
        insert orderProcessing;
        
        OrderCreatedDataContext context = new OrderCreatedDataContext(setIdOrders);
        context.listOrderProcessing = new List<Order_Processing__c>{orderProcessing};
        
        Test.startTest();
        OrderCreatedClassification.verifyOrderImportQueue(context);
        context.save();
        Test.stopTest();

        System.assertEquals(null, context.orderToProjectAssociate.get(order1.Id), 'Order to project associate map should not have order and project');
        System.assertEquals(1, context.orderMap.values().size(), 'Order map should have the original order');
        System.assertEquals(0, context.listUpdateImportQueue.size(), 'List update import queue should not have an order import queue');

    }
}