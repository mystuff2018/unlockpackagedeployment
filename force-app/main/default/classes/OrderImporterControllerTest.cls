@isTest
public class OrderImporterControllerTest {
    
    @testSetup
    static void setupData() {
        //[Deloitte : Abhishek Kawle] : Login with Integration User Profile to create Account
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){ 
        Account account = new Account(Name = 'Test account');
        
        insert(account);
        
        pse__Proj__c project1 = new pse__Proj__c(
            Name = 'Test Project',
            DP__c = '1',
            pse__Account__c = account.Id,
            pse__Is_Active__c = true  
        );
        
        insert(project1);
        
        pse__Proj__c project2 = new pse__Proj__c(
            Name = 'Test Project2',
            DP__c = '2',
            pse__Account__c = account.Id,
            pse__Is_Active__c = true 
        );
        
        insert(project2);
        
        Order order = new Order(
            AccountId = account.Id,
            EffectiveDate = Date.today(),
            Status = 'BK',
            OrderNumber__c = '555666',
            PriceBook2Id = Test.getStandardPricebookId(),
            Project__c = project1.Id,
            BUID__C = '11',
            FF_Feed__c = true
        );
        
        insert(order);
        }
    }
    
    @isTest
    static void getImportQueue_Should_Return_Single_Element() {
        pse__Proj__c proj = [SELECT ID FROM pse__Proj__c WHERE DP__c = '1'];
        
        Order_Import_Queue__c queue = new Order_Import_Queue__c();
        queue.BUID__c = '1';
        queue.Project__c = proj.Id;
        queue.Order_Number__c = '2';
        
        insert(queue);
        
        Test.startTest();
        
        List<Order_Import_Queue__c> importQueue = OrderImporterController.getImportQueue(proj.Id);
        
        Test.stopTest();
        
        System.assertEquals(1, importQueue.size());
        System.assertEquals('2', importQueue[0].Order_Number__c);
        System.assertEquals('1', importQueue[0].BUID__c);
    }
    
    @isTest
    static void validateImportOrder_Should_Return_Errors() {
        Order order = [SELECT OrderNumber__c, Project__c FROM Order];
        
        pse__Proj__c proj = [SELECT Id FROM pse__Proj__c WHERE DP__c = '2'];
        
        Order_Import_Queue__c queue = new Order_Import_Queue__c();
        queue.BUID__c = '11';
        queue.Project__c = proj.Id;
        queue.Order_Number__c = '6790';
        
        insert(queue);
        
        Test.startTest();
        
        OrderImporterController.ValidateResponse response = OrderImporterController.validateImportOrder('6790, 123, 456, 789, aaa, b123, ' + order.OrderNumber__c , '11', order.Project__c);
        
        Test.stopTest();
        
        system.assertNotEquals(null, response);
        system.assertNotEquals(null, response.ValidOrders);
        system.assertNotEquals(null, response.InvalidOrders);
        system.assertNotEquals(null, response.Errors);
        system.assertEquals(true, response.HasErrors);
        
        system.assert(response.ValidOrders.contains('123'));
        system.assert(response.ValidOrders.contains('456'));
        system.assert(response.ValidOrders.contains('789'));
        
        system.assert(response.InvalidOrders.contains('aaa'));
        system.assert(response.InvalidOrders.contains('b123'));
        system.assert(response.InvalidOrders.contains('555666'));
        system.assert(response.InvalidOrders.contains('6790'));
        
        system.assertEquals(3, response.Errors.size());
    }
    
    @isTest
    static void importOrder_Should_Create_Order_Import_Queue() {
        Order order = [SELECT OrderNumber__c, Project__c FROM Order];
        
        String[] ordersToImport = new String[] {'1', '2', '3'};
        
        //[Deloitte : Abhishek Kawle] - Commented following code as callouts are not being used in DFN. Boomi queue processes the requests.
        /*StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        
        mock.setStaticResource('OrderImportMockedResponse');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/text');

        Test.setMock(HttpCalloutMock.class, mock); */
        
        Test.startTest();
        
        OrderImporterController.importOrder(ordersToImport, '11', order.Project__c);
        
        Test.stopTest();
        
        List<Order_Import_Queue__c> queueItems = [SELECT   BUID__c, Project__c, Order_Number__c, Order_Import_Response_Status__c FROM Order_Import_Queue__c];
        
        system.assertNotEquals(null, queueItems);
        system.assertEquals(3, queueItems.size());
        
        //system.assertEquals('SUCCESS', queueItems[0].Order_Import_Response_Status__c);
        //system.assertEquals('SUCCESS', queueItems[1].Order_Import_Response_Status__c);
       //system.assertEquals('SUCCESS', queueItems[2].Order_Import_Response_Status__c);
    } 
}