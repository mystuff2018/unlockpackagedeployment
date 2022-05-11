/**
 * Created by Bruno_Frosi on 1/24/2020.
 */

@IsTest
private class DAL_AccountTest {
    @IsTest
    static void testBehavior() {
        //[Deloitte : Abhishek Kawle] : Login with Integration User Profile to create Account
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){ 
            Set<Id> accIds = new Set<Id>();
            Account acc1 = OPRTestFactory.newAccount('Account for testing', '123');
            INSERT acc1;
            accIds.add(acc1.Id);
            
            Test.startTest();
            Map<Id, Account> mapAccIds = DAL_Account.getAccountsByIds(accIds);
            Test.stopTest();
            
            system.assert(mapAccIds.size() > 0);
        }
    }
    @IsTest
    static void testBehavior2() {
        Set<Id> accIds = new Set<Id>();
        Test.startTest();
        Map<Id, Account> mapAccIds = DAL_Account.getAccountsByIds(accIds);
        Test.stopTest();

        system.assert(mapAccIds == null);
    }
    @IsTest
    static void testBehavior3() {
        Test.startTest();
        Map<Id, Account> accIds = DAL_Account.getAccountsByIds(null);
        Test.stopTest();

        system.assert(accIds == null);
    }
}