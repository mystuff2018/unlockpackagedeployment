@isTest
public class OrderDisassociationProjectComplexityTest {
    
    @isTest
    static void calculateProjectComplexity_success(){
        
        // setup Project Complexity Mapping
        List<Project_Complexity_Mapping__c> projComplexityMappings = new List<Project_Complexity_Mapping__c>();

        projComplexityMappings.add(new Project_Complexity_Mapping__c (
            Overall_Project_Complexity__c = 'Low',
            PM_Complexity__c = 'Low',
            Revenue_Threshold__c = 'Low'
        )); 

        projComplexityMappings.add(new Project_Complexity_Mapping__c (
            Overall_Project_Complexity__c = 'Medium',
            PM_Complexity__c = 'Medium',
            Revenue_Threshold__c = 'Medium'
        ));

        projComplexityMappings.add(new Project_Complexity_Mapping__c (
            Overall_Project_Complexity__c = 'High',
            PM_Complexity__c = 'High',
            Revenue_Threshold__c = 'High'
        ));

        projComplexityMappings.add(new Project_Complexity_Mapping__c (
            Overall_Project_Complexity__c = 'High',
            PM_Complexity__c = 'High',
            Revenue_Threshold__c = 'Medium'
        ));
        
        insert projComplexityMappings;

        pse__Proj__c engagement = new pse__Proj__c();
        engagement.Name = 'My Engagement';
        engagement.RecordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get('Parent_Project').getRecordTypeId();
        engagement.Po_Number__c = '1700';
        engagement.Deal__c = '150';
        engagement.DP__c = '';
        insert engagement;

        pse__Proj__c project = OPRTestFactory.createSimpleProject();
        project.pse__Parent_Project__c = engagement.Id;
        update project;

		Order order1 = OPRTestFactory.createSimpleOrder();
		Order order2 = OPRTestFactory.createSimpleOrder();
        List<String> skuNumbersToMap = new List<String>{'123-456','CUSTOM SKU'};
        Map<String, String> phaseByTask = new Map<String, String>();
        phaseByTask.put('Scoping', 'Initiate');
        phaseByTask.put('Configuration', 'Execute');
        phaseByTask.put('Planning', 'Plan');
        SKU_Effort_Map__c skuEffort2 = OPRTestFactory.createSkuEffortMap(skuNumbersToMap, 10, false, phaseByTask);

        // Setup Project Complexity Threshold
        List<Project_Complexity_Threshold__c> projComplexities = new List<Project_Complexity_Threshold__c>();

        projComplexities.add(new Project_Complexity_Threshold__c (
            Name = 'US',
            Low_Threshold__c = 3500,
            High_Threshold__c = 11500
        ));

        insert projComplexities;   

		List<Contact> lstContact = new List<Contact>();
		for(Contact contact :[SELECT Id, Mailing_Country__c From Contact]){
			contact.MailingCountry = contact.Mailing_Country__c;
			lstContact.add(contact);
		}
        update lstContact;
        
        List<OrderItem> lstOrdemItem = [SELECT Id FROM OrderItem];
        for(OrderItem item : lstOrdemItem){
            item.project__c = project.Id;
            item.SKU_Number__c = '123-456';
        }
        update lstOrdemItem;

        pse__Budget__c budget1 = new pse__Budget__c(
            Name = 'Budget from Order 1',
            Order__c = order1.Id,
            Pse__Project__c = project.Id,
            Pse__Amount__c = 200,
            Amount_USD__c = 199,
            CurrencyIsoCode = 'USD',
            Pse__Status__c = 'Approved',
            Pse__Include_In_Financials__c = true,
            Pse__Type__c = 'Customer Purchase Order'
        );
        
        pse__Budget__c budget2 = new pse__Budget__c(
            Name = 'Internal Budget from Order 1',
            Order__c = order1.Id,
            Pse__Project__c = project.Id,
            Pse__Amount__c = 200,
            Amount_USD__c = 199,
            CurrencyIsoCode = 'USD',
            Pse__Status__c = 'Approved',
            Pse__Include_In_Financials__c = true,
            Pse__Type__c = 'Internal Budget'
        );

        pse__Budget__c budget3 = new pse__Budget__c(
            Name = 'Budget from Order 2',
            Order__c = order2.Id,
            Pse__Project__c = project.Id,
            Pse__Amount__c = 200,
            Amount_USD__c = 199,
            CurrencyIsoCode = 'USD',
            Pse__Status__c = 'Approved',
            Pse__Include_In_Financials__c = true,
            Pse__Type__c = 'Customer Purchase Order'
        );
        
        pse__Budget__c budget4 = new pse__Budget__c(
            Name = 'Internal Budget from Order 2',
            Order__c = order2.Id,
            Pse__Project__c = project.Id,
            Pse__Amount__c = 200,
            Amount_USD__c = 199,
            CurrencyIsoCode = 'USD',
            Pse__Status__c = 'Approved',
            Pse__Include_In_Financials__c = true,
            Pse__Type__c = 'Internal Budget'
        );

        insert new List<pse__Budget__c>{budget1, budget2,budget3,budget4};
        Set<Id> orderIds = new Set<Id>();
        orderIds.add(order1.Id);
        OrderDisassociationDataContext context = new OrderDisassociationDataContext(orderIds);

        // Act
        Test.startTest();
        OrderDisassociationProjectComplexity.calculateProjectComplexity(context);
        Test.stopTest();

        System.assertEquals('Low', context.projectMap.get(project.Id).Project_Complexity__c, 'It should be a Project Complexity Low.');

    }
}