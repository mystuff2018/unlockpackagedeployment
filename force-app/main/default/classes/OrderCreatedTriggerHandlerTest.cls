/**
 * Created by Bruno_Frosi on 1/13/2020.
 */

@IsTest
private class OrderCreatedTriggerHandlerTest {

    @isTest
    static void shouldPublishEventSuccesfully() {
        //Login with Integration User Profile to create Account
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){ 
            List<Account> listAcc = new List<Account>();
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '111', '11', '12'));
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '123'));
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '234'));
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '345'));
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '456'));
            INSERT listAcc;
            
            Contact contact = OPRTestFactory.newContact('firstName','lastName','United States','Texas', '1235671007');
            INSERT contact;
            
            Order ordr = OPRTestFactory.newOrderWithItem('123123', listAcc[0].Id, contact.Id, 'United States', 'Texas', 'United States', 'Texas', '111', '222', '333',
                                                         listAcc[1].Id,
                                                         listAcc[2].Id,
                                                         listAcc[3].Id,
                                                         listAcc[4].Id,
                                                         null, 'NOT IDS');
            
            Order ordr2 = OPRTestFactory.newOrderWithItem('123124', listAcc[0].Id, contact.Id, 'United States', 'Texas', 'United States', 'Texas', '111', '222', '333',
                                                         listAcc[1].Id,
                                                         listAcc[2].Id,
                                                         listAcc[3].Id,
                                                         listAcc[4].Id,
                                                         null, 'NOT IDS');
            
            pse__Region__c region = OPRTestFactory.newRegion('United States', 'US', true);
            insert region;
            
            Set<Id> setIdOrders = new Set<Id>();
            setIdOrders.add(ordr.Id);
            setIdOrders.add(ordr2.Id);
            
            List<Order_Created__e> eventList = new List<Order_Created__e>();
            Order_Created__e event = new Order_Created__e();
            event.Order_ID__c = String.valueOf(ordr.Id);
            event.Is_Event_Reprocessing__c = true;
            eventList.add(event);
            
            Order_Created__e event2 = new Order_Created__e();
            event2.Order_ID__c = String.valueOf(ordr2.Id);
            event2.Is_Event_Reprocessing__c = true;
            eventList.add(event2);
            
            Order_Processing__c op = new Order_Processing__c();
            op.OrderId__c = String.valueOf(ordr2.Id);
            op.ProcessStatus__c = 'Processed';
            op.RetryCount__c =  0;
            
            insert op;
            
            Test.startTest();
            List<Database.SaveResult> eventPublishResults = Eventbus.publish(eventList);
            //Database.SaveResult sr = Eventbus.publish(event);
            Test.stopTest();
            
            System.assertEquals(true, eventPublishResults[0].isSuccess(), 'Event result should be "success"');
        }
    }

    @isTest
    static void shouldTestCatchStatement(){
        // Should test the catch statement of trigger sending a event with missing data

        Order_Created__e event = new Order_Created__e();
        event.Order_ID__c = '123412';

        Test.startTest();
        Database.SaveResult sr = Eventbus.publish(event);
        Test.stopTest();

        System.assertEquals(true, sr.isSuccess(), 'Event result should be "success"');

        List<ExceptionLogger__c> exceptionLoggers = [
                SELECT Id
                FROM ExceptionLogger__c
        ];

        // Assert
        // Verify if any exception logger was created
        System.assertEquals(1, exceptionLoggers.size(), 'Trigger should create one exception loggers record');
    }
}