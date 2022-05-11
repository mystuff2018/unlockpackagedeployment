/**
 * Created by Bruno_Frosi on 1/24/2020.
 */

@IsTest
private class CreateProjectDataContextTest {
   
    @IsTest
    static void shouldRefreshAndSaveContext() {

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Group g1 = new Group(Name='ISG_Test2_Projects', type='Queue');
            insert g1;
            QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'pse__Proj__c');
            insert q1;
        }
        

        pse__Region__c globalRegion = OPRTestFactory.newRegion('Global', null, true);
        INSERT globalRegion;

        pse__Region__c parentRegion = OPRTestFactory.newRegionWithParent('Test2', ' ', true, globalRegion.Id);
        INSERT parentRegion;
        
        pse__Region__c region = OPRTestFactory.newRegionWithParent('Test', 'US', true, parentRegion.Id);
        INSERT region;
        
        //[Deloitte : Abhishek Kawle] : Login with Integration User Profile to create Account
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){ 
            List<Account> listAcc = new List<Account>();
            listAcc.add(OPRTestFactory.newAccount('Account for testing', '111'));
            INSERT listAcc;
        }
        
        List<Account> accList = [SELECT Id FROM Account WHERE Name = 'Account for testing' LIMIT 1];

        Contact contact = OPRTestFactory.newContact('firstName','lastName','United States','Texas','1234567898');
        INSERT contact;

        Order order = new Order(
            OrderNumber__c = '123456789',
            AccountId = accList[0].Id,
            EffectiveDate = Date.today(),
            BUID__c = '11',
            Status = 'BK',
            Pricebook2Id = Test.getStandardPricebookId()
        );
        insert order;

        List<pse__Proj__c> projectList = new List<pse__Proj__c>(); 
        
		pse__Proj__c projectTemplate = new pse__Proj__c(
                Name='Phased Project Template - Custom - Global',
                pse__Is_Template__c = true,
                pse__Is_Active__c = true,
                pse__Start_Date__c = Date.today(),
                pse__Account__c = accList[0].Id,
               // pse__Practice__c = practice.Id,
                Po_Number__c = '54764648',
                Deal__c = '54764648',
                DP__c = '54764648'
        );
        projectList.add(projectTemplate);
            
        pse__Proj__c engagement = new pse__Proj__c(
            Name = 'Engagement Test ',
            RecordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get('Parent_Project').getRecordTypeId()
        );
        projectList.add(engagement);
        
        insert projectList;
        
        pse__Practice__c practice = new pse__Practice__c(Name = 'Global', Standard_Project_Template__c = projectList[0].Id);	
        insert practice;
        
        pse__Proj__c project = new pse__Proj__c(
            Name = 'project Test',
            pse__parent_project__c = engagement.Id,
            pse__practice__c = practice.Id,
            pse__End_Date__c = Date.Today().addDays(30),
            pse__Start_Date__c = Date.Today()
        );
        insert project;
        
        Product2 product = new Product2(Name='Product Test');
        insert product;
		
		//List<PricebookEntry> pbentry = [Select ID from PricebookEntry where Product2Id =:product.Id limit 1];
		//if(pbentry == null && pbentry.size() == 0){
			PricebookEntry pricebookEntry = new PricebookEntry(
				Pricebook2Id = Test.getStandardPricebookId(),
				Product2Id = product.Id,
				UseStandardPrice = false,
				UnitPrice = 1
			);
			insert pricebookEntry;
			//pbentry.add(priceBookEntry);
//}	

        OrderItem orderItem = new OrderItem(
            SKU_Description__c = 'SKU1',
            SKU_Number__c = '111-1111',
            Quantity = 1,
            Item_Class_Description__c = 'SVC EIS',
            OrderId = order.Id,
            PriceBookEntryId = pricebookEntry.Id,
            UnitPrice = 1
        );
        insert orderItem;

        Set<Id> orderIds = new Set<Id>();
        Map<Id, Id> orderItemToPracticeIds = new Map<Id, Id>();
        Map<Id, Id> orderItemToEngagementIds = new Map<Id, Id>();
        Map<Id, String> orderItemToGroupingKeyIds = new Map<Id, String>();
        
        orderIds.add(order.Id);
        orderItemToPracticeIds.put(orderItem.Id, practice.Id);     
        orderItemToEngagementIds.put(orderItem.Id, engagement.Id);
        orderItemToGroupingKeyIds.put(orderItem.Id, 'teste');
        
        
        
        CreateProjectDataContext context = new CreateProjectDataContext(orderIds, orderItemToPracticeIds, orderItemToEngagementIds, orderItemToGroupingKeyIds);
        
         Test.startTest();
        context.populateOrderItemsByProjectMap();
        context.Save();
        Test.stopTest();
       
        Set<Id> orderItems = context.listOfGroupedOrderItens.get('teste');
        Id firstOrderItemId = new List<Id> (orderItems)[0];
        
        System.assertEquals(1, context.groupingKeys.size());
        System.assertEquals(orderItem.Id, firstOrderItemId);

    }
}