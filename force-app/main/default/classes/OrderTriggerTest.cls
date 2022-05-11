/**
* Created by Willian_Paulo on 1/30/2019.
*/

@IsTest
private class OrderTriggerTest {
    @isTest
    static void testFFOrders() {
        //Login with Integration User Profile to create Account
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){
            Account account = new Account(Name = 'Test account');
            insert account;
            
            Order order = new Order(
                AccountId = account.Id,
                EffectiveDate = Date.today(),
                Status = 'BK',
                Order_Status__c = 'BK',
                PoNumber = '888999',
                FF_Feed__c = true,
                Deal_ID__c = '000111',
                OrderNumber__c = '555666',
                PriceBook2Id = Test.getStandardPricebookId(),
                BUID__c = '11'
            );
            
            Database.SaveResult result = Database.insert(order, true);
            
            System.assert(result.isSuccess());
        }
    }
}