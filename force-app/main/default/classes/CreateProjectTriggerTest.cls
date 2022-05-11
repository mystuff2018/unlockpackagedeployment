@isTest
public class CreateProjectTriggerTest {
    @isTest              
    static void CreateProject_PublishEvent() {
        //Login with Integration User Profile to create Account
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){       
            Order order = OPRTestFactory.createSimpleOrder();
            
            List<OrderItem> orderItems = [
                SELECT Id
                FROM OrderItem
                WHERE OrderId = :order.Id
            ];
            
            Create_Project__e event = new Create_Project__e();
            event.Order_ID__c = String.valueOf(order.Id);
            event.OrderItemList__c = String.valueOf(orderItems[0].Id);
            event.Engagement_ID__c = '98789123451235123';
            
            // Act
            Test.startTest();
            
            // Publish event
            Database.SaveResult sr = Eventbus.publish(event);
            
            Test.stopTest();
            
            // Assert
            // Verify that the publish was successful
            System.assertEquals(true, sr.isSuccess());
        }
    }
}