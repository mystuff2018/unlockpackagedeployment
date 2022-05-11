@isTest
public class DAL_OrderImportQueueTest {
    
     @TestSetup
    static void setup(){
        //Login with Integration User Profile to create Account
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){ 
            // Create Account
            Account account = new Account(Name = 'Create Account Test');
            insert account;
            
            // Create order
            Order order = new Order(
                OrderNumber__c = '6543200',
                EffectiveDate = Date.today(),
                AccountId = account.Id,
                CurrencyIsoCode = 'USD',
                BUID__c = '11',
                Status = 'BK',
                Order_Status__c = 'EC',
                Pricebook2Id = Test.getStandardPricebookId(),
                OCI_Order_Type__c = 'US Order',
                FF_Feed__c = true
            );
            
            insert order;
            
            
            // create project
            pse__Proj__c project = new pse__Proj__c(
                Name = 'Project Test',
                pse__Is_Active__c = true,
                //CreatedDate = Date.today().addDays(-11),
                pse__Start_Date__c = Date.today().addDays(-10),
                pse__End_Date__c = Date.today().addDays(60),
                Project_Complexity__c = 'Low'
            );
            
            insert project;
        }
    }
    
     @isTest
     static void getImportedOrdersById_WithoutOrderImportQueue() {
        
         // arrange
         Map<Id, Order> mapOrder = new Map<Id, Order>([SELECT Id, OrderNumber__c, BUID__c FROM Order]);
        
         // act
         Test.startTest();
         Map<String, Order_Import_Queue__c> result = DAL_OrderImportQueue.getImportedOrdersById(mapOrder);
         Test.stopTest();
        
         // assert
         System.assertEquals(0, result.size(), 'DAL_OrderImportQueue should return an empty map');
     }

     @isTest
     static void getImportedOrdersById_success() {
        
         // arrange
         Order order = [SELECT Id, OrderNumber__c, BUID__c FROM Order];
         pse__Proj__c project = [SELECT Id FROM pse__Proj__c];
        
         Order_Import_Queue__c orderImportQueue = OPRTestFactory.createOrderImportQueue(order, project);
        
         Map<Id, Order> mapOrder = new Map<Id, Order>{order.Id => order};
        
         // act
         Test.startTest();
         Map<String, Order_Import_Queue__c> result = DAL_OrderImportQueue.getImportedOrdersById(mapOrder);
         Test.stopTest();
        
         // assert
         System.assertNotEquals(result, null);
        
         String strKey = orderImportQueue.Order_Number__c + '|' + orderImportQueue.BUID__c;
         System.assert(result.get(strKey).Id == orderImportQueue.Id);

     }
}