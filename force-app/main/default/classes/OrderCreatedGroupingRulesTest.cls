@IsTest
public class OrderCreatedGroupingRulesTest {
    
    @IsTest
    static void associateOrderToEngagement_success(){
        //Login with Integration User Profile to create Account
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){ 

        Account account = OPRTestFactory.newAccount('Account for testing', '111', '11', '12');
        insert account;
        
        Contact contact = OPRTestFactory.newContact('firstName','lastName','United States','Texas','1234567890');
        insert contact;
        
        Order order1 = OPRTestFactory.newOrderWithItem('123123', account.Id, contact.Id, 'United States', 'Texas', 'United States', 'Texas', '111', '222', '333',
               account.Id, null, null, null, '12', 'NOT IDS');
        Order order2 = OPRTestFactory.newOrderWithItem('123123', account.Id, contact.Id, 'United States', 'Texas', 'United States', 'Texas', '111', '222', '333',
               null, account.Id, null, null, '12', 'NOT IDS');
        Order order3 = OPRTestFactory.newOrderWithItem('123123', account.Id, contact.Id, 'United States', 'Texas', 'United States', 'Texas', '111', '222', '334',
               null, null, account.Id, null, '12', 'NOT IDS');
        Order order4 = OPRTestFactory.newOrderWithItem('123123', account.Id, contact.Id, 'United States', 'Texas', 'United States', 'Texas', '111', '222', '335',
               null, null, null, account.Id, '12', 'NOT IDS');
        
        Id rtID = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get('Parent_Project').getRecordTypeId();
        
        
        pse__Proj__c project1 = OPRTestFactory.createProject(account.Id, '111', null, null);
        project1.recordTypeId = rtID;
        
        pse__Proj__c project2 = OPRTestFactory.createProject(account.Id, null, '222', null);
        project2.recordTypeId = rtID;
        
        pse__Proj__c project3 = OPRTestFactory.createProject(account.Id, null, null, '333');
        project3.recordTypeId = rtID;
        
        insert new list<pse__Proj__c>{project1,project2,project3};
        
        OrderCreatedDataContext context = new OrderCreatedDataContext(new set<Id>{order1.Id,order2.Id,order3.Id, order4.Id});
    Test.startTest();
          OrderCreatedGroupingRules.associateOrderToEngagement(context);
        Test.stopTest();
        system.assertEquals(context.orderToProjectAssociate.size(), 2);
        }
    }
}