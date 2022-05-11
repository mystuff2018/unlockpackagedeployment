@isTest
public  class OrderProcessSchedulerTest {
   
    @isTest
    static void orderProcessScheduler_Success(){

        FFProcessControlSettings__c executionControl =  new FFProcessControlSettings__c();
        executionControl.NextBatchExecution__c = 5;
        insert executionControl;
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]) {
            List<Account> listAcc = new List<Account>();
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '111', '11', '12'));
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '123'));
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '234'));
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '345'));
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '456'));
            INSERT listAcc;
    
            Contact contact = OPRTestFactory.newContact('firstName','lastName','United States','Texas','5555555555');
            INSERT contact;
    
            Order order = OPRTestFactory.newOrderWithItem('123123', listAcc[0].Id, contact.Id, 'United States', 'Texas', 'United States', 'Texas', '111', '222', '333',
                    listAcc[1].Id,
                    listAcc[2].Id,
                    listAcc[3].Id,
                    listAcc[4].Id
            );
            pse__Region__c region = OPRTestFactory.newRegion('United States', 'US', true);
            insert region;
            
            Test.startTest();
            Order_Processing__c orderProcessing = new Order_Processing__c(OrderId__c = order.Id, ProcessStatus__c = 'Pending');
            insert orderProcessing;
    
            String jobID = System.schedule('Order Process Scheduler Test', '0 00 * * * ?', new OrderProcessScheduler());
            
            Test.stopTest();
    
            System.assert(jobId != null);
        }
    }


}