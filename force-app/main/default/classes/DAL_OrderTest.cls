/**
 * Created by Bruno_Frosi on 1/13/2020.
 * @Modification Log : [Deloitte - Abhishek Kawle] : Added code to test DAL_Order > getAllOrderForGrouping
 */

@IsTest
private class DAL_OrderTest {
     @IsTest
     static void testBehavior() {
         List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
         system.runAs(loginUser[0]){ 
         Account acc = OPRTestFactory.newAccount('Account for testing', '111');
         INSERT acc;
         Contact contact = OPRTestFactory.newContact('firstName','lastName','United States','Texas','1234567898');
         INSERT contact;
         Order ordr = OPRTestFactory.newOrderWithItem('123123', acc.Id, contact.Id, 'United States', 'Texas', 'United States', 'Texas', '111', '222', '333',
                 OPRTestFactory.newAccount('Account for testing', '123').Id,
                 OPRTestFactory.newAccount('Account for testing', '234').Id,
                 OPRTestFactory.newAccount('Account for testing', '345').Id,
                 OPRTestFactory.newAccount('Account for testing', '456').Id);

         Set<Id> setIdOrders = new Set<Id>();
         setIdOrders.add(ordr.Id);

         Test.startTest();
         Map<Id, Order> ordersMap = DAL_Order.getOrdersByIds(setIdOrders);
         Test.stopTest();

         System.assert(ordersMap.size() > 0);
         }
     }
     @IsTest
     static void testBehavior2() {
         Set<Id> setIdOrders = new Set<Id>();

         Test.startTest();
         Map<Id, Order> ordersMap = DAL_Order.getOrdersByIds(setIdOrders);
         Test.stopTest();

         System.assert(ordersMap == null);
     }
    
     @isTest
     static void shouldGetMapOrderWithProjectBySetId(){
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];

        system.runAs(loginUser[0]){ 
         Account acc = OPRTestFactory.newAccount('Account for testing', '111');
         INSERT acc;
         Contact contact = OPRTestFactory.newContact('firstName','lastName','United States','Texas','1234567898');
         INSERT contact;
         Order ordr = OPRTestFactory.newOrderWithItem('123123', acc.Id, contact.Id, 'United States', 'Texas', 'United States', 'Texas', '111', '222', '333',
                 OPRTestFactory.newAccount('Account for testing', '123').Id,
                 OPRTestFactory.newAccount('Account for testing', '234').Id,
                 OPRTestFactory.newAccount('Account for testing', '345').Id,
                 OPRTestFactory.newAccount('Account for testing', '456').Id);

         Set<Id> setIdOrders = new Set<Id>();
         setIdOrders.add(ordr.Id);

         Test.startTest();
         Map<Id, Order> ordersMap = DAL_Order.getMapOrderWithProjectBySetId(setIdOrders);
         Test.stopTest();
     
         System.assert(ordersMap.size() > 0);  
        }
     }
    
     @isTest              
     static void shouldGetOrderWithOutProject() {
         // Arrange
         List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
         system.runAs(loginUser[0]){ 
         Order order1 = OPRTestFactory.createSimpleOrder();

         pse__Proj__c project = OPRTestFactory.createProject();
         Order order2 = OPRTestFactory.createSimpleOrder();
         order2.Project__c = project.Id;
         update order2;

         Set<Id> orderIds = new Set<Id>();
         orderIds.add(order1.Id);
         orderIds.add(order2.Id);
         // Act
         Test.startTest();
         Map<Id, Order> result = DAL_Order.getOrderWithoutProjectByIds(orderIds);
         Test.stopTest();
    
         // Assert
         System.assertNotEquals(null, result, 'The result should not be null.');
         System.assertEquals(1, result.size(), 'The result should has only one order.');
         System.assertEquals(true, result.containsKey(order1.Id), 'The result should contains the first order.');
         System.assertEquals(false, result.containsKey(order2.Id), 'The result should not contains the first order.');
     }
     }
    
    @isTest
    static void testgetAllOrderForGrouping(){
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){ 
        Account acc = OPRTestFactory.newAccount('Account for testing', '111');
         INSERT acc;
         Contact contact = OPRTestFactory.newContact('firstName','lastName','United States','Texas','1234567898');
         INSERT contact;
         Order ordr = OPRTestFactory.newOrderWithItem('123123', acc.Id, contact.Id, 'United States', 'Texas', 'United States', 'Texas', '111', '222', '333',
                 OPRTestFactory.newAccount('Account for testing', '123').Id,
                 OPRTestFactory.newAccount('Account for testing', '234').Id,
                 OPRTestFactory.newAccount('Account for testing', '345').Id,
                 OPRTestFactory.newAccount('Account for testing', '456').Id);
        
        pse__Proj__c project = OPRTestFactory.createProject();
        ordr.Project__c = project.Id;
         update ordr;
        Set<String> poNumbers = new Set<String>();
        poNumbers.add('333');
        
        Set<String> poNumbers2 = new Set<String>();
        poNumbers2.add('111');
        
        Test.startTest();
        Map<Id, Order> ordersMap = DAL_Order.getAllOrderForGrouping(poNumbers);
        System.assert(ordersMap == null);
        
        Map<Id, Order> ordersMap2 = DAL_Order.getAllOrderForGrouping(poNumbers2);
        System.assert(ordersMap2.size() > 0);
        
        Test.stopTest();
        }
    }
}