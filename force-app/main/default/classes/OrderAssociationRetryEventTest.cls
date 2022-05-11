@isTest
public class OrderAssociationRetryEventTest {
    
    @isTest
    static void validateCloneTaskJob(){
        //[Deloitte : Abhishek Kawle] : Login with Integration User Profile to create Account
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){ 
            SKU_Effort_Map__c skuEffortMap = new SKU_Effort_Map__c(
                Active__c = true,
                Description__c = 'ProDeploy Dell Storage SC Series vXXXX SAN - Deployment Verification',
                X30_Day_Support__c = true
            );
            insert skuEffortMap;
            
            SKU_Number__c skuNumber1 = new SKU_Number__c();
            skuNumber1.SKU_Number__c = '777-1000';
            skuNumber1.SKU_to_Effort_Mapping__c = skuEffortMap.Id;
            insert skuNumber1;
            
            pse__Proj__c project1 = OPRTestFactory.createSimpleProject();
            pse__Proj__c project2 = OPRTestFactory.createSimpleProject();
            
            Order order1 = OPRTestFactory.createSimpleOrder();
            Order order2 = OPRTestFactory.createSimpleOrder();
            
            List<Contact> lstContact = new List<Contact>();
            for(Contact contact :[SELECT Id, Mailing_Country__c From Contact]){
                contact.MailingCountry = contact.Mailing_Country__c;
                lstContact.add(contact);
            }
            update lstContact;
            
            String jobId = System.enqueueJob(new OrderAssociationRetryEvent.OrderAssociationRetryEventMock());
            
            Clone_Project_Info__c info = new Clone_Project_Info__c(
                Order__c = order1.Id,
                Project__c = project1.Id,
                Queued_Job_Id__c = jobId
            );
            insert info;
            
            List<Order>  lstOrders = [SELECT Id, (Select Id From OrderItems) FROM Order];
            
            Order_Association__e event1 = new Order_Association__e(
                Order_ID__c = order1.Id,
                Project_ID__c = project1.Id,
                Order_Item_Id__c = lstOrders[0].OrderItems[0].Id
            );
            
            Order_Association__e event2 = new Order_Association__e(
                Order_ID__c = order2.Id,
                Project_ID__c = project2.Id,
                Order_Item_Id__c = lstOrders[1].OrderItems[0].Id
            );
            
            List<Order_Association__e> eventList = new List<Order_Association__e>{event1, event2};
                
                
                Test.startTest();
            List<Order_Association__e> eventsToBeProcessed = OrderAssociationRetryEvent.validateCloneTaskJob(eventList);
            Test.stopTest();
            
            System.assertEquals(eventsToBeProcessed.size(), 1);
            System.assertEquals(eventsToBeProcessed[0].Order_ID__c, order2.Id);
            
        }
    }
}