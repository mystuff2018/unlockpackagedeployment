@isTest
 public class CandidateProjToAssocController_Test 
 {	
    @isTest
    public static void testGetProjectSuggestions() 
    {
        Id recordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get('Parent_Project').getRecordTypeId();

        pse__Proj__c engagement = new pse__Proj__c();
        engagement.Name = 'My Engagement';
        engagement.RecordTypeId = recordTypeId;
        engagement.Po_Number__c = '1700';
        engagement.Deal__c = '150';
        engagement.DP__c = '';
        insert engagement;

        Order order = OPRTestFactory.createSimpleOrder();
        order.PoNumber = '1800';
        order.Deal_ID__c = '150';
        order.DPID__c = '';
        update order;

        // Action
        Test.startTest();
        List<SuggestedProjectAssociation> listRecommendation = CandidateProjectsToAssociationController.getProjectSuggestions(order.Id);
        Test.stopTest();

        // Assertion
        System.assertEquals(1, listRecommendation.size());
        System.assertEquals(engagement.Id, listRecommendation.get(0).project.Id);
    }
    
    @isTest
    public static void testGetListViews()
    {
        List<ListView> listView = CandidateProjectsToAssociationController.getListViews();
		System.assert(!listView.isEmpty());
    }

    @isTest
    public static void disacossiation_success(){

        

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
        Test.startTest();
        List<String> result = CandidateProjectsToAssociationController.disassociationOrder(order1.Id);
        system.debug('result: '+result);
        Test.stopTest();
        System.assertEquals(result.size(), 0);
    }
    
    @isTest
    public static void createProjectSuccess(){
		Order order1 = OPRTestFactory.createSimpleOrder();
        
        List<String> skuNumbersToMap = new List<String>{'123-456','CUSTOM SKU'};
        Map<String, String> phaseByTask = new Map<String, String>();
        phaseByTask.put('Scoping', 'Initiate');
        phaseByTask.put('Configuration', 'Execute');
        phaseByTask.put('Planning', 'Plan');
        SKU_Effort_Map__c skuEffort2 = OPRTestFactory.createSkuEffortMap(skuNumbersToMap, 10, false, phaseByTask);

        List<OrderItem> lstOrdemItem = [SELECT Id FROM OrderItem];
        for(OrderItem item : lstOrdemItem){
            item.SKU_Number__c = '123-456';
        }
        update lstOrdemItem;

        Test.startTest();
        List<String> result = CandidateProjectsToAssociationController.createProject(order1.Id);
        system.debug('result: '+result);
        Test.stopTest();
        System.assertEquals(result.size(), 0);
    }
    
    @isTest
    public static void createProjectError(){
		Order order1 = OPRTestFactory.createSimpleOrder();
        Id orderId = order1.Id;
        delete order1;
        
        Test.startTest();
        List<String> result = CandidateProjectsToAssociationController.createProject(orderId);
        system.debug('result: '+result);
        Test.stopTest();
        System.assertEquals(result.size(), 1);
    }
}