@isTest 
public with sharing class OrderAssociationBudgetTest {

     @testSetup
     static void makeData(){
         
          pse__Proj__c projectTemplate = TestDataUtility.createProject(true);

         List<pse__Practice__c> practiceList = new List<pse__Practice__c>();
         pse__Practice__c practice1 = new pse__Practice__c(Name = 'IDS', Standard_Project_Template__c = projectTemplate.Id);
         pse__Practice__c practice2 = new pse__Practice__c(Name = 'Consulting', Standard_Project_Template__c = projectTemplate.Id);
         practiceList.add(practice1);
         practiceList.add(practice2);
         upsert practiceList;
        
         List<Item_Class__c> itemClasses = new List<Item_Class__c>();
         itemClasses.add(new Item_Class__c(Item_Class_Description__c = 'SVC EDT INSTLN', Practice__c = practice1.Id, Key_Practice__c = true));
         itemClasses.add(new Item_Class__c(Item_Class_Description__c = 'SVC EDT CNSLT', Practice__c = practice2.Id, Key_Practice__c = true));

         insert itemClasses;
        
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

     @isTest
     static void shouldCreateBudget(){

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

	 	Test.startTest();      
         OrderAssociationBudget.createProjectBudget(context);
         Test.stopTest();
        
         System.assertEquals(4, context.projectIdToBudgetListMap.get(project.Id).size(), 'It should have four budgets into context');
        
     }  

     @isTest
     static void shouldNotCalculateBudgetAmount(){

         List<OrderItem> orderItems = [
             SELECT Id, Item_Class_Description__c, OrderId
             FROM orderItem
         ];

         orderItems[0].Quantity = 1;
         orderItems[0].Unit_Selling_Price_Local__c  = 0;
         orderItems[0].Unit_Selling_Price_USD__c  = 0;
         orderItems[0].SKU_Cost_Local__c  = 0;
         orderItems[0].SKU_Cost_USD__c  = 0;
         update orderItems;

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

	 	Test.startTest();
         OrderAssociationBudget.createProjectBudget(context);
         Test.stopTest();

         for(pse__Budget__c budget: context.projectIdToBudgetListMap.get(project.Id)){

             if(budget.Order__c == orderItems[0].OrderId){
                 System.assert(budget.Pse__Amount__c == 0, 'Budget should have zero amount');
            }
             else{
                 System.assert(budget.Pse__Amount__c > 0, 'Budget should have amount');
             }
         }

     }

    // /*
    // @isTest
    // static void shouldNotCalculateBudget(){

    //     List<OrderItem> orderItems = [
    //         SELECT Id, Item_Class_Description__c
    //         FROM orderItem
    //     ];

    //     for(OrderItem oi: orderItems){
    //         oi.Item_Class_Description__c = 'Bse HW Dell Syst';
    //     }

    //     update orderItems;

    //     List<Order> orders = [SELECT Id, (Select Id From OrderItems) FROM Order];
	// 	pse__Proj__c project = [SELECT Id FROM pse__Proj__c LIMIT 1];
	// 	List<Order_Association__e> eventList = new List<Order_Association__e>();
	// 	for(Order ord: orders){
	// 		OrderItem item = ord.OrderItems[0];
	// 		Order_Association__e event = new Order_Association__e(
	// 			Order_ID__c = ord.Id,
	// 			Project_ID__c = project.Id,
	// 			Order_Item_Id__c = item.Id
	// 		);
				
	// 		eventList.add(event);
	// 	}		
    //     OrderAssociationDataContext context = new OrderAssociationDataContext(eventList);

	// 	Test.startTest();      
    //     OrderAssociationBudget.createProjectBudget(context);
    //     Test.stopTest();
        
    //     System.assertEquals(0, context.projectIdToBudgetListMap.get(project.Id)[0].Pse__Amount__c, 'Budget should have zero amount');
    // }
    // */
    
     @isTest              
     static void shouldCreateBudgetToMultiTowerProjects() {
         List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
          system.runAs(loginUser[0]){
         // Arrange        
         pse__Proj__c projectIds = OPRTestFactory.createSimpleProject();
         pse__Proj__c projectConsulting = OPRTestFactory.createSimpleProject();
        
         Order firstOrder = createOrder('1234');
              
              Set<Id> orderId = new Set<Id>();
              PageReference pgRef = new PageReference('/apex/Order'); 
              Test.setCurrentPage(pgRef); 
              id ordId = ApexPages.currentPage().getParameters().put('id', firstOrder.id);
              orderId.add(ordId);
              OrderItem firstOrderItem = createOrderItem(firstOrder.Id, projectIds.Id, '9876-123', 'SVC EDT INSTLN', 3, 10, 5);
              OrderItem secondOrderItem = createOrderItem(firstOrder.Id, projectConsulting.Id, '5432-123', 'SVC EDT CNSLT', 2, 4, 3);
              
              Order secondOrder = createOrder('4321');
              OrderItem thirdOrderItem = createOrderItem(secondOrder.Id, projectIds.Id, '9876-456', 'SVC EDT INSTLN', 1, 10, 5);
              
              List<Order_Association__e> eventList = new List<Order_Association__e>();
              
              eventList.add(new Order_Association__e(
                  Order_ID__c = firstOrder.Id, Project_ID__c = projectIds.Id, Order_Item_Id__c = firstOrderItem.Id));
              eventList.add(new Order_Association__e(
                  Order_ID__c = secondOrder.Id, Project_ID__c = projectIds.Id, Order_Item_Id__c = thirdOrderItem.Id));
              eventList.add(new Order_Association__e(
                  Order_ID__c = firstOrder.Id, Project_ID__c = projectConsulting.Id, Order_Item_Id__c = secondOrderItem.Id));
              
              OrderAssociationDataContext context = new OrderAssociationDataContext(eventList);
              
         // Act
         Test.startTest();      
         OrderAssociationBudget.createProjectBudget(context);
         Test.stopTest();
    
         // Assert
         System.assertEquals(2, context.projectIdToBudgetListMap.size(), 'It should have two projects');

         // - IDS Project
         System.assertEquals(4, context.projectIdToBudgetListMap.get(projectIds.Id).size(), 'It should have four budgets');
         System.assertEquals(15, context.projectIdToBudgetListMap.get(projectIds.Id)[0].Pse__Amount__c, 'The Amount should be 15');
         System.assertEquals(30, context.projectIdToBudgetListMap.get(projectIds.Id)[1].Pse__Amount__c, 'The Amount should be 30');       
         System.assertEquals(5, context.projectIdToBudgetListMap.get(projectIds.Id)[2].Pse__Amount__c, 'The Amount should be 5');
         System.assertEquals(10, context.projectIdToBudgetListMap.get(projectIds.Id)[3].Pse__Amount__c, 'The Amount should be 10');       
        
         // - Consulting Project
         System.assertEquals(2, context.projectIdToBudgetListMap.get(projectConsulting.Id).size(), 'It should have two budgets');
         System.assertEquals(6, context.projectIdToBudgetListMap.get(projectConsulting.Id)[0].Pse__Amount__c, 'The Amount should be 6');
         System.assertEquals(8, context.projectIdToBudgetListMap.get(projectConsulting.Id)[1].Pse__Amount__c, 'The Amount should be 8');       
    
     }
     }
     
     private static Order createOrder(String orderNumber) {
         // Create Account
        
         
        Account account = new Account();
         account.Name = 'Create Account Test';
         insert account;
        
		
         // create order
         Order order = new Order();
         order.OrderNumber__c = orderNumber;
         order.EffectiveDate = Date.today();
         order.AccountId = account.Id;
         //order.AccountId = System.Label.ShadowApptParentRecordId;
         order.CurrencyIsoCode = 'USD';
         order.BUID__c = '11';
         order.Status = 'BK';
         order.Order_Status__c = 'EC';
         order.Pricebook2Id = Test.getStandardPricebookId();
         order.OCI_Order_Type__c = 'US Order';
         order.FF_Feed__c = true;
         insert order;
          
       return order;
         
     }
     
     private static OrderItem createOrderItem(
         Id orderId, Id projectId, String skuNumber, String itemClassDesc, 
         Integer quantity, Decimal skuCost, Decimal unitSellingPrice) {        

         // Order Product
         Product2 product = new Product2();
         product.Name='Product Test';
         insert product;

         PricebookEntry pricebookEntry = new PricebookEntry();
        pricebookEntry.Pricebook2Id = Test.getStandardPricebookId();
         pricebookEntry.Product2Id = product.Id;
         pricebookEntry.UseStandardPrice = false; 
         pricebookEntry.UnitPrice = 1;
         insert pricebookEntry;

         // Order Item
         OrderItem oi = new OrderItem();
         oi.SKU_Description__c = itemClassDesc;
         oi.SKU_Number__c = skuNumber;
         oi.Quantity = quantity;
         oi.UnitPrice = unitSellingPrice;
         oi.Item_Class_Description__c = itemClassDesc;
         oi.Tie_Number__c = '1';
         oi.OrderId = orderId;
         oi.PriceBookEntryId = pricebookEntry.Id;
         oi.SKU_Cost__c = skuCost;
         oi.SKU_Cost_Local__c = skuCost;
         oi.SKU_Cost_USD__c = skuCost;
         oi.Unit_Selling_Price_Local__c = unitSellingPrice;
         oi.Unit_Selling_Price_USD__c = unitSellingPrice;
         oi.Project__c = projectId;
         insert oi;

         return oi;
     }
}