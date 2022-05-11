/**
 * Created by Bruno_Frosi on 1/15/2020.
 */
@IsTest
private class OrderCreatedRegionManagerTest {
    @IsTest
    static void testBehavior() {
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]) {
            List<Account> listAcc = new List<Account>();
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '111'));
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '123'));
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '234'));
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '345'));
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '456'));
            INSERT listAcc;
            Contact contact = OPRTestFactory.newContact('firstName','lastName','United States','Texas','5555555555');
            INSERT contact;
            Order ordr = OPRTestFactory.newOrderWithItem('123123', listAcc[0].Id, contact.Id, 'United States', 'Texas', 'United States', 'Texas', '111', '222', '333',
                    listAcc[1].Id,
                    listAcc[2].Id,
                    listAcc[3].Id,
                    listAcc[4].Id);
    
            pse__Region__c region = OPRTestFactory.newRegion('Region', 'US', true);
            INSERT region;
    
            Set<Id> setIdOrders = new Set<Id>();
            setIdOrders.add(ordr.Id);
            OrderCreatedDataContext context = new OrderCreatedDataContext(setIdOrders);
    
            Test.startTest();
            OrderCreatedRegionManager.removeOrdersByRegion(context);
            Test.stopTest();
    
            //system.assert(context.orderMap.size() > 0);
    }
    }

    @IsTest
    static void testBehavior2() {
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]) {
        List<Account> listAcc = new List<Account>();
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '111'));
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '123'));
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '234'));
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '345'));
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '456'));
            INSERT listAcc;
            Contact contact = OPRTestFactory.newContact('firstName','lastName','United States','Texas','5555555555');
            INSERT contact;
            Order ordr = OPRTestFactory.newOrderWithItem('123123', listAcc[0].Id, contact.Id, 'United States', 'Texas', 'United States', 'Texas', '111', '222', '333',
                    listAcc[1].Id,
                    listAcc[2].Id,
                    listAcc[3].Id,
                    listAcc[4].Id);
    
            pse__Region__c region = OPRTestFactory.newRegion('Region', 'US', false);
            INSERT region;
    
            Set<Id> setIdOrders = new Set<Id>();
            setIdOrders.add(ordr.Id);
            OrderCreatedDataContext context = new OrderCreatedDataContext(setIdOrders);
    
            Test.startTest();
            OrderCreatedRegionManager.removeOrdersByRegion(context);
            Test.stopTest();
    
            system.assert(context.orderMap.size() == 0);
        }
    }

    @IsTest
    static void testBehavior3() {
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]) {
            List<Account> listAcc = new List<Account>();
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '111'));
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '123'));
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '234'));
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '345'));
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '456'));
            INSERT listAcc;
            Contact contact = OPRTestFactory.newContact('firstName','lastName','United States','Texas','5555555555');
            INSERT contact;
            Order ordr = OPRTestFactory.newOrderWithItem('123123', listAcc[0].Id, contact.Id, 'United States', 'Texas', 'United States', 'Texas', '111', '222', '333',
                    listAcc[1].Id,
                    listAcc[2].Id,
                    listAcc[3].Id,
                    listAcc[0].Id);
    
            Set<Id> setIdOrders = new Set<Id>();
            setIdOrders.add(ordr.Id);
            OrderCreatedDataContext context = new OrderCreatedDataContext(setIdOrders);
    
            Test.startTest();
            OrderCreatedRegionManager.removeOrdersByRegion(context);
            Test.stopTest();
    
            system.assert(context.orderMap.size() == 0);
        }
    }
}