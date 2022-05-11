@isTest
public  class OrderDisassociationBudgetTest {
    // @isTest
    // static void deleteProjectBudgetTest() {

        // pse__Proj__c project = OPRTestFactory.createSimpleProject();
		// Order order1 = OPRTestFactory.createSimpleOrder();
		// Order order2 = OPRTestFactory.createSimpleOrder();

		// List<Contact> lstContact = new List<Contact>();
		// for(Contact contact :[SELECT Id, Mailing_Country__c From Contact]){
			// contact.MailingCountry = contact.Mailing_Country__c;
			// lstContact.add(contact);
		// }
        // update lstContact;
        
        // List<OrderItem> lstOrdemItem = [SELECT Id FROM OrderItem];
        // for(OrderItem item : lstOrdemItem){
            // item.project__c = project.Id;
        // }
        // update lstOrdemItem;

        // pse__Budget__c budget1 = new pse__Budget__c(
            // Name = 'Budget from Order 1',
            // Order__c = order1.Id,
            // Pse__Project__c = project.Id,
            // Pse__Amount__c = 200,
            // Amount_USD__c = 199,
            // CurrencyIsoCode = 'USD',
            // Pse__Status__c = 'Approved',
            // Pse__Include_In_Financials__c = true,
            // Pse__Type__c = 'Customer Purchase Order'
        // );
        
        // pse__Budget__c budget2 = new pse__Budget__c(
            // Name = 'Internal Budget from Order 1',
            // Order__c = order1.Id,
            // Pse__Project__c = project.Id,
            // Pse__Amount__c = 200,
            // Amount_USD__c = 199,
            // CurrencyIsoCode = 'USD',
            // Pse__Status__c = 'Approved',
            // Pse__Include_In_Financials__c = true,
            // Pse__Type__c = 'Internal Budget'
        // );

        // pse__Budget__c budget3 = new pse__Budget__c(
            // Name = 'Budget from Order 2',
            // Order__c = order2.Id,
            // Pse__Project__c = project.Id,
            // Pse__Amount__c = 200,
            // Amount_USD__c = 199,
            // CurrencyIsoCode = 'USD',
            // Pse__Status__c = 'Approved',
            // Pse__Include_In_Financials__c = true,
            // Pse__Type__c = 'Customer Purchase Order'
        // );
        
        // pse__Budget__c budget4 = new pse__Budget__c(
            // Name = 'Internal Budget from Order 2',
            // Order__c = order2.Id,
            // Pse__Project__c = project.Id,
            // Pse__Amount__c = 200,
            // Amount_USD__c = 199,
            // CurrencyIsoCode = 'USD',
            // Pse__Status__c = 'Approved',
            // Pse__Include_In_Financials__c = true,
            // Pse__Type__c = 'Internal Budget'
        // );

        // insert new List<pse__Budget__c>{budget1, budget2,budget3,budget4};


        // OrderDisassociationDataContext context = new OrderDisassociationDataContext(new Set<Id>{order1.Id}); 
        // Test.startTest();
        // OrderDisassociationBudget.deleteProjectBudget(context);
        // Test.stopTest();
        // System.assertEquals(2, context.mapBudgetToDelete.size());
        
        

    // }
}