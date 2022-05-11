@isTest
public with sharing class OrderDisassociationHandlerTest {
    @TestSetup
    static void setup(){
        //Login with Integration User Profile to create Account as a validation rule is in place to prevent Account creation by Other user in SFDC.
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
            
            List<String> skuNumbersToMapCustom = new List<String>{'CUSTOM SKU'};
            Map<String, String> phaseByTaskCustom = new Map<String, String>();
            phaseByTaskCustom.put('Scoping', 'Initiate');
            phaseByTaskCustom.put('Physical Installation', 'Execute');
            phaseByTaskCustom.put('Planning', 'Plan');
            phaseByTaskCustom.put('Delivery', 'Close');    
            SKU_Effort_Map__c skuEffortCustom = OPRTestFactory.createSkuEffortMap(skuNumbersToMapCustom, 10, false, phaseByTaskCustom);
           
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
        OrderAssociationDataContext context = new OrderAssociationDataContext(eventList);
        context.save();
        
        // act
        Test.startTest();
        //OrderDisassociationDataContext disassociationContext = new OrderDisassociationDataContext((new Map<Id, Order>(orders)).keySet());
        
        OrderDisassociationHandler orderDisassociation = new OrderDisassociationHandler((new Map<Id, Order>(orders)).keySet());
        orderDisassociation.run();
        
        Test.stopTest();
        
        // assert
        System.assertEquals(2, context.orderMap.size(), 'orderMap size should be 2.');
        System.assertEquals(1, context.projectMap.size(), 'projectMap size should be 1.');
        System.assertEquals(1, context.projectWithOrdersMap.size(), 'projectWithOrdersMap size should be 1.');
        System.assertEquals(2, context.projectWithOrdersMap.get(project.Id).size(), 'projectWithOrdersMap value size should be 2.');
    }
    
    @isTest 
    static void testCancelProjectsWithoutOrderItems() {
        // arrange
        List<Order> orders = [SELECT Id, (Select Id From OrderItems) FROM Order];
        pse__Proj__c project = [SELECT Id, pse__Parent_Project__c FROM pse__Proj__c LIMIT 1];
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
        OrderAssociationDataContext context = new OrderAssociationDataContext(eventList);
        context.save();
        
        // act
        Test.startTest();
        //OrderDisassociationDataContext disassociationContext = new OrderDisassociationDataContext((new Map<Id, Order>(orders)).keySet());
        
        OrderDisassociationHandler orderDisassociation = new OrderDisassociationHandler((new Map<Id, Order>(orders)).keySet());
        orderDisassociation.run();
        
        Test.stopTest();
        
        pse__Proj__c projectAfterDissociation = [SELECT Id, pse__Stage__c FROM pse__Proj__c LIMIT 1];
        
        // assert
        System.assertEquals('Cancelled', projectAfterDissociation.pse__Stage__c , 'Project Should be Cancelled.');
    }
    
    @isTest 
    static void testNoShouldCancelProject() {
        // arrange
        List<Order> orders = [SELECT Id, (Select Id From OrderItems) FROM Order];
        pse__Proj__c project = [SELECT Id, pse__Parent_Project__c FROM pse__Proj__c LIMIT 1];
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
        OrderAssociationDataContext context = new OrderAssociationDataContext(eventList);
        context.save();
        
        // act
        Test.startTest();
        Set<Id> orderId = new Set<Id>();
        orderId.add(orders[0].Id);
        OrderDisassociationHandler orderDisassociation = new OrderDisassociationHandler(orderId);
        orderDisassociation.run();
        pse__Proj__c projectAfterDissociation1 = [SELECT Id, pse__Stage__c FROM pse__Proj__c LIMIT 1];
        Test.stopTest();
        
        // Don't change Project to cancelled because has one more Order Item.
        System.assertEquals('Draft', projectAfterDissociation1.pse__Stage__c , 'Project Should be Draft.');
    }
    @isTest 
    static void testsendnotification() {
        // arrange
        List<Order> orders = [SELECT Id, (Select Id From OrderItems) FROM Order];
        //List<pse__Proj__c> project = [SELECT Id, pse__Parent_Project__c,OwnerId FROM pse__Proj__c LIMIT 1];
        pse__Proj__c project = new pse__Proj__c();
        project.Name = 'Test';
        project.pse__Is_Template__c = true;
        insert project;
        Profile p = [SELECT Id FROM Profile WHERE Name='PSA Project Manager']; 
        User u = new User(Alias = 'standt', Email='standarduser@dell.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='testuer@ab.com.augdev' , CommunityNickname  = 'testUser' ,
                          OSP__c = 'No' , FederationIdentifier= '123', Organization__c = 'testOrg', Dell_NTUserID__c = '1234', 
                          File_Source__c = 'WorkDay', Service_User_Type__c='Admin',EmployeeNumber='123456');
        insert u;
  
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
        OrderAssociationDataContext context = new OrderAssociationDataContext(eventList);
        context.save();
        Test.startTest();  
        project.OwnerId = u.id;
        Update project;
       for(Order ord : orders){
            ord.status ='CL';
        }
        Update orders;

        Set<Id> orderId = new Set<Id>();
        orderId.add(orders[0].Id);
        OrderDisassociationHandler orderDisassociation = new OrderDisassociationHandler(orderId);
        orderDisassociation.run();
        test.stopTest();
    }

    @isTest
	static void shouldRemoveApprovalProcess() {
		// ARRANGE
		Boolean isInsert =True;
		List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
		//Account account = MDF_AccountFactory.start().create();
		Account account = new Account(
            Name = 'Test account',
            Site_Access_Required__c = 'Yes'
    		);
	 	if(isInsert){
            system.runAs(loginUser[0])
   			 {
             insert account;
    		}
        }
		Order order = MDF_OrderFactory.start(account).create();

		OrderItemToProjectApproval__c orita = MDF_OrderItemToProjectApprovalFactory.start()
												.approver(UserInfo.getUserId())
												.create();

		OrderItem orderitem = MDF_OrderItemFactory.start(order)
								.orderItemToProjectApproval(orita)
								.create();

		createApprovalProcess(orita);

		// ACT
		Test.startTest();

		OrderDisassociationHandler handler = new OrderDisassociationHandler(new Set<Id> {order.Id});
		handler.run();

		Test.stopTest();

		// ASSERT
		System.assert(handler.context.orderItemToProjectApprovalToRemove.size() > 0, 'The orderItemToProjectApprovalToRemove should have value.');
		System.assertEquals(handler.context.orderItemToProjectApprovalToRemove[0].Id, orita.Id);

		OrderItem orderItemResult = [SELECT Id, OrderItemToProjectApproval__c FROM OrderItem WHERE Id = :orderItem.Id];
		System.assertEquals(orderItemResult.OrderItemToProjectApproval__c, null, 'The Order Item should not have an orita.');

		List<OrderItemToProjectApproval__c> oritaResult = [SELECT Id FROM OrderItemToProjectApproval__c WHERE Id = :orita.Id];
		System.assertEquals(oritaResult.size(), 0, 'The orita should be deleted.');
	}

	private static void createApprovalProcess(OrderItemToProjectApproval__c orita) {
		List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
 
		Approval.ProcessSubmitRequest orderItemToApprovalProcess = new Approval.ProcessSubmitRequest();
		orderItemToApprovalProcess.setComments('Test Approval Process Created');
		orderItemToApprovalProcess.setNextApproverIds(new Id[] {UserInfo.getUserId()});
		orderItemToApprovalProcess.setObjectId(orita.Id);
		// Submit the record to specific process
		orderItemToApprovalProcess.setProcessDefinitionNameOrId('Order_Item_Association_Approval_Process');
		requests.add(orderItemToApprovalProcess);

        Approval.ProcessResult[] processResults = Approval.process(requests, true);
	}
}