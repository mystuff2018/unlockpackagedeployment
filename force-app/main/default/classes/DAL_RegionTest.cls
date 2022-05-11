/**
 * Created by Bruno_Frosi on 1/24/2020.
 */

@IsTest
private class DAL_RegionTest {
    @IsTest
    static void testBehavior() {
        //[Deloitte : Abhishek Kawle] : Login with Integration User Profile to create Account
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){ 
            pse__Region__c region = OPRTestFactory.newRegion('Test', 'US', true);
            INSERT region;
            pse__Region__c inactiveRegion = OPRTestFactory.newRegion('Test2', 'BR', false);
            INSERT inactiveRegion;
            
            List<Account> listAcc = new List<Account>();
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '111', '11','12'));
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '123'));
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '234'));
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '345'));
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '456'));
            INSERT listAcc;
            
            Contact contact = OPRTestFactory.newContact('firstName','lastName','United States','Texas','1234567890');
            INSERT contact;
            
            Order ordr = OPRTestFactory.newOrderWithItem('123123', listAcc[0].Id, contact.Id, 'United States', 'Texas', 'United States', 'Texas', '111', '222', '333',
                                                         listAcc[1].Id,
                                                         listAcc[2].Id,
                                                         listAcc[3].Id,
                                                         listAcc[4].Id,
                                                         null, 'NOT IDS');
            
            Set<Id> setIdOrders = new Set<Id>();
            setIdOrders.add(ordr.Id);
            
            Test.startTest();
            Map<Id, Order> ordersMap = DAL_Order.getOrdersByIds(setIdOrders);
            Map<String,List<pse__Region__c>> regionMap = DAL_Region.getBuidToRegionMap(ordersMap);
            pse__Region__c globalRegion2 = DAL_Region.getGlobalRegion();
            pse__Region__c globalRegion = OPRTestFactory.newRegion('Global Region', null, true);
            INSERT globalRegion;
            pse__Region__c globalRegion3 = DAL_Region.getGlobalRegion();
            Test.stopTest();
            
            //system.assert(regionMap.size() > 0);
            system.assert(globalRegion2 == null);
            system.assert(globalRegion3 != null);
        }
    }
}