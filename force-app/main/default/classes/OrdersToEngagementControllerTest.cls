@isTest
public class OrdersToEngagementControllerTest {
    @testSetup
    static void setup(){
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){
        // creating a test account
        Account account = new Account();
        account.Name = 'Test Account';
        insert account;

        // initializing a list of 10 orders
        List<Order> orders = new List<Order>();
        
        for(Integer i = 0; i < 10; i++)
        {
            Order order = new Order();
            order.OrderNumber__c = '0000' + i;
            order.EffectiveDate = Date.ValueOf('2018-08-10');
            order.AccountId = account.Id;
            order.CurrencyIsoCode = 'USD';
            order.Status = 'BK';
            order.BUID__c = '11';
            orders.add(order);
        }

        insert orders;
        }     
    }

    @isTest
    static void getOrdersTest(){
        //Arrange
        String orderNumbers = '00001,00002,00003';

        //Act
        Test.startTest();        
        List<Order> ordersList = OrdersToEngagementController.getOrders(orderNumbers);
        Test.stopTest();

        //Assert        
        System.assertEquals(3, ordersList.size(), 'The method should have returned 3 orders.');
    }

    @isTest
    static void getAccountNameByAccountIdMapTest(){
        //Arrange
        List<Order> orders = [SELECT Id, AccountId FROM Order WHERE OrderNumber__c in ('00001','00002')];
        Set<Id> accountIdSet = new Set<Id>();
        for(Order order : orders){
            accountIdSet.add(order.AccountId);
        }
        List<Account> accounts = [SELECT Id, Name FROM Account WHERE Id = :accountIdSet];
        string accountsId = accounts[0].Id + ',' + accounts[0].Id;

        //Act
        Test.startTest();
        Map<String, String> mapAccountsNameById = OrdersToEngagementController.getAccountNameByAccountIdMap(accountsId);
        Test.stopTest();

        //Assert
        System.assert(mapAccountsNameById.containsKey(accounts[0].Id));
    }

    @isTest
    static void associateOrdersToEngagementTest(){
        //Arrange
        Id recordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get('Parent_Project').getRecordTypeId();

        pse__Proj__c engagement = new pse__Proj__c();
        engagement.Name = 'My Engagement';
        engagement.RecordTypeId = recordTypeId;
        engagement.Po_Number__c = '1700';
        engagement.Deal__c = '150';
        engagement.DP__c = '';
        insert engagement;

        Order order = OPRTestFactory.createSimpleOrder();
        order.PoNumber = '1800';
        order.Deal_ID__c = '150';
        order.DPID__c = '';
        update order;

        List<String> orders = new List<String>();
        orders.add(order.Id);

        //Act
        Test.startTest();
        OrdersToEngagementController.associateOrdersToEngagement(orders, engagement.Id);
        Test.stopTest();

        Order result = [SELECT Id, Project__c FROM Order WHERE Id = :orders[0]];

        //Assert
        System.assertEquals(engagement.Id, result.Project__c);
    }
}