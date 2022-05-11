@isTest
public class AssociateOrderControllerTest
{
    @isTest static void AssociateOrderController()
    {
        //Login with Integration User Profile to create Account
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){
            // Arrange
            List<Order> orders = CreateOrders();
            
            // Act
            Test.startTest();
            Test.setCurrentPage(Page.AssociateOrder);
            ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(orders);
            stdSetController.setSelected(orders);
            AssociateOrderController ssc = new AssociateOrderController(stdSetController);
            Test.stopTest();
            
            // Assert
            System.assert(ssc.getOrders().size() > 0);
        } 
    }
    
    static List<Order> CreateOrders()
    {
        // creating a test account
        Account account = new Account();
        account.Name = 'Test Account';
        account.BUID__c = '11';
        account.CCN__c = 'US_42';
        insert account;

        // initializing a list of 10 orders
        List<Order> orders = new List<Order>();
        
        for(Integer i = 0; i < 10; i++)
        {
            Order order = new Order();
            order.OrderNumber__c = '0000' + i;
            order.EffectiveDate = Date.ValueOf('2018-08-10');
            order.AccountId = account.Id;
            order.CurrencyIsoCode = 'USD';
            order.Status = 'BK';
            order.BUID__c = '11';
            orders.add(order);
        }

        insert orders;
        return orders;
    }
}