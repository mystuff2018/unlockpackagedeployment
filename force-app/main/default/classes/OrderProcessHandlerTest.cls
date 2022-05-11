@isTest
public class OrderProcessHandlerTest {
    @isTest
    static void shouldPublishEventSuccesfully() {

        FFProcessControlSettings__c executionSettings = new FFProcessControlSettings__c();
        executionSettings.NumberOfRetries__c = 3;
        insert executionSettings;
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]) {
            List<Account> listAcc = new List<Account>();
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '111', '11', '12'));
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '123'));
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '234'));
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '345'));
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '456'));
            INSERT listAcc;
    
            Contact contact = OPRTestFactory.newContact('firstName','lastName','United States','Texas','1235671007');
            INSERT contact;
    
            Order ordr = OPRTestFactory.newOrderWithItem('123123', listAcc[0].Id, contact.Id, 'United States', 'Texas', 'United States', 'Texas', '111', '222', '333',
                    listAcc[1].Id,
                    listAcc[2].Id,
                    listAcc[3].Id,
                    listAcc[4].Id,
                    null, 'NOT IDS');
    
            pse__Region__c region = OPRTestFactory.newRegion('United States', 'US', true);
            insert region;
    
            Set<Id> setIdOrders = new Set<Id>();
            setIdOrders.add(ordr.Id);
    
            Order_Processing__c orderProcessing = new Order_Processing__c(OrderId__c = ordr.Id, ProcessStatus__c = 'Pending');
            insert orderProcessing;
    
            Test.startTest();
            // OrderProcessHandler.run(setIdOrders, new List<Order_Processing__c>{orderProcessing});
            Database.executeBatch(new OrderProcessHandler(), 50);
            Test.stopTest();
    
            orderProcessing = [
                SELECT Id, ProcessStatus__c
                FROM Order_Processing__c
                WHERE Id = :orderProcessing.Id
            ];
    
            System.assertEquals('Processed', orderProcessing.ProcessStatus__c);
        }
        
    }

}