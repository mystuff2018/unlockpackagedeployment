@isTest
public class OrderAssociationDataContextTest {
    
    @TestSetup
    static void setup(){
        //Login with Integration User Profile to create Account
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
            pse__Proj__c project = OPRTestFactory.createSimpleProject();
            Order order1 = OPRTestFactory.createSimpleOrder();
            Order order2 = OPRTestFactory.createSimpleOrder();
            
            List<Contact> lstContact = new List<Contact>();
            for(Contact contact :[SELECT Id, Mailing_Country__c From Contact]){
                contact.MailingCountry = contact.Mailing_Country__c;
                lstContact.add(contact);
            }
            update lstContact;
        }
    }

	@isTest 
	static void shouldInitiateDataContextProperties() {
		// arrange
		List<Order> orders = [SELECT Id, (Select Id From OrderItems) FROM Order];
		pse__Proj__c project = [SELECT Id FROM pse__Proj__c LIMIT 1];
		List<Order_Association__e> eventList = new List<Order_Association__e>();
		for(Order ord: orders){
			OrderItem item = ord.OrderItems[0];
			Order_Association__e event = new Order_Association__e(
				Order_ID__c = ord.Id,
				Project_ID__c = project.Id,
				Order_Item_Id__c = item.Id
			);
				
			eventList.add(event);
		}		

		// act
		Test.startTest();
		OrderAssociationDataContext context = new OrderAssociationDataContext(eventList);
		context.save();
		Test.stopTest();

		// assert
		System.assertEquals(2, context.orderMap.size(), 'orderMap size should be 2.');
		System.assertEquals(1, context.projectMap.size(), 'projectMap size should be 1.');
		System.assertEquals(1, context.projectWithOrdersMap.size(), 'projectWithOrdersMap size should be 1.');
		System.assertEquals(2, context.projectWithOrdersMap.get(project.Id).size(), 'projectWithOrdersMap value size should be 2.');
	}
}