/**
* Created by Bruno_Frosi on 1/31/2020.
*/

@IsTest
private class OrderAssociationMilestoneTest {
   
   @testSetup
   static void setup(){
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){
       Order orderFirst = createOrder('1234');
       pse__Proj__c projectFirst = OPRTestFactory.createSimpleProject();
       OrderItem orderItemFirst = createOrderItem(orderFirst.Id, '9876-456', 'SVC EDT INSTLN', 2, 10, 5);
       OrderItem orderItemSecond = createOrderItem(orderFirst.Id, '1234-456', 'SVC EDT INSTLN', 1, 15, 2);
       Sku_Effort_Map__c skuEffortMap = createSkuEffortMap(new String[] {'9876-456', '1234-456'});
       Order orderSecond = createOrder('9876');
       OrderItem orderItemThird = createOrderItem(orderSecond.Id, '9876-9876', 'SVC EDT INSTLN', 1, 10, 5);
        }
   }

   @isTest              
   static void createMilestoneToRegularProjectFromOneOrder() {
       // Arrange
       Order order = [SELECT Id, OrderNumber__c FROM Order WHERE OrderNumber__c =: '1234'];
       pse__Proj__c project = [SELECT Id FROM pse__Proj__c LIMIT 1];
       OrderItem orderItemFirst = [SELECT Id FROM OrderItem WHERE SKU_Number__c =: '9876-456'];
       OrderItem orderItemSecond = [SELECT Id FROM OrderItem WHERE SKU_Number__c =: '1234-456'];
       
       List<Order_Association__e> eventList = new List<Order_Association__e>();        
       eventList.add(new Order_Association__e(
           Order_ID__c = order.Id, Project_ID__c = project.Id, Order_Item_Id__c = orderItemFirst.Id));
       eventList.add(new Order_Association__e(
           Order_ID__c = order.Id, Project_ID__c = project.Id, Order_Item_Id__c = orderItemSecond.Id));
       
       OrderAssociationDataContext context = new OrderAssociationDataContext(eventList);
      
       // Act
       Test.startTest();
       OrderAssociationMilestone.updateMilestonesInformation(context);
       Test.stopTest();

       // Assert
       List<pse__Milestone__c> milestones = [SELECT Id, 
                                                   Name,
                                                   Current__c, 
                                                   pse__Target_Date__c,
                                                   pse__Milestone_Amount__c,
                                                   Milestone_Amount_USD__c, 
                                                   pse__Milestone_Cost__c,
                                                   Milestone_Cost_USD__c
                                           FROM pse__Milestone__c];

       System.assertEquals(1, milestones.size(), 'It should have only one milestone');
       System.assertEquals('Milestone', milestones[0].Name, 'The Mileston Name should "Milestone".');    
       System.assertEquals(Date.today(), milestones[0].pse__Target_Date__c, 'The Current property should be true.');
       System.assertEquals(true, milestones[0].Current__c, 'The Current property should be true.');
       System.assertEquals(2, context.newOrderItemsToMilestoneRelationship.size(), 'The Junction Object should have 2 item.');
       System.assertEquals(12, milestones[0].pse__Milestone_Amount__c, 'The Amount field should be 12.');
       System.assertEquals(12, milestones[0].Milestone_Amount_USD__c, 'The Amount USD field should be 12.');
       System.assertEquals(35, milestones[0].pse__Milestone_Cost__c, 'The Cost field should be 35.');
       System.assertEquals(35, milestones[0].Milestone_Cost_USD__c, 'The Cost USD field should be 35'); 
   }

   @isTest              
   static void createMilestoneToRegularProjectWithEndDate() {
       // Arrange
       Order order = [SELECT Id, OrderNumber__c FROM Order WHERE OrderNumber__c =: '1234'];        
       OrderItem orderItemFirst = [SELECT Id FROM OrderItem WHERE SKU_Number__c =: '9876-456'];
       pse__Proj__c project = [SELECT Id FROM pse__Proj__c LIMIT 1];
       project.pse__End_Date__c = Date.today().addDays(30);
       update project;

       List<Order_Association__e> eventList = new List<Order_Association__e>();        
       eventList.add(new Order_Association__e(
           Order_ID__c = order.Id, Project_ID__c = project.Id, Order_Item_Id__c = orderItemFirst.Id));
       
       OrderAssociationDataContext context = new OrderAssociationDataContext(eventList);
      
       // Act
       Test.startTest();
       OrderAssociationMilestone.updateMilestonesInformation(context);
       Test.stopTest();

       // Assert
       List<pse__Milestone__c> milestones = [SELECT Id, Name, Current__c, pse__Target_Date__c FROM pse__Milestone__c];

       System.assertEquals(1, milestones.size(), 'It should have only one milestone');
       System.assertEquals('Milestone', milestones[0].Name, 'The Mileston Name should "Milestone".');    
       System.assertEquals(project.pse__End_Date__c, milestones[0].pse__Target_Date__c, 'The Target Date property should be equal of the Project End Date.');
       System.assertEquals(true, milestones[0].Current__c, 'The Current property should be true.');
       System.assertEquals(1, context.newOrderItemsToMilestoneRelationship.size(), 'The Junction Object should have 1 item.');
   }

   @isTest              
   static void createMilestoneToDistinctProjectFromOneOrder() {
       // Arrange
       Order order = [SELECT Id, OrderNumber__c FROM Order WHERE OrderNumber__c =: '1234'];
       Sku_Effort_Map__c skuEffortMap = [SELECT Id FROM SKU_Effort_Map__c];
       pse__Proj__c project = [SELECT Id FROM pse__Proj__c LIMIT 1];
       project.Distinct_SKU_Effort_Mapping__c = skuEffortMap.Id;

       update project;

       OrderItem orderItemFirst = [SELECT Id FROM OrderItem WHERE SKU_Number__c =: '9876-456'];
       OrderItem orderItemSecond = [SELECT Id FROM OrderItem WHERE SKU_Number__c =: '1234-456'];
       
       List<Order_Association__e> eventList = new List<Order_Association__e>();
       
       eventList.add(new Order_Association__e(
           Order_ID__c = order.Id, Project_ID__c = project.Id, Order_Item_Id__c = orderItemFirst.Id));
       eventList.add(new Order_Association__e(
           Order_ID__c = order.Id, Project_ID__c = project.Id, Order_Item_Id__c = orderItemSecond.Id));
       
       OrderAssociationDataContext context = new OrderAssociationDataContext(eventList);
      
       // Act
       Test.startTest();
       OrderAssociationMilestone.updateMilestonesInformation(context);
       Test.stopTest();

       // Assert
       Map<Id, pse__Milestone__c> milestones = new Map<Id, pse__Milestone__c>([SELECT Id,
                                                                                       Name, 
                                                                                       Current__c, 
                                                                                       pse__Target_Date__c,
                                                                                       pse__Milestone_Amount__c,
                                                                                       Milestone_Amount_USD__c, 
                                                                                       pse__Milestone_Cost__c,
                                                                                       Milestone_Cost_USD__c
                                                                                   FROM pse__Milestone__c]);

       System.assertEquals(3, milestones.size(), 'It should have three milestones.');  
       System.assertEquals(3, context.newOrderItemsToMilestoneRelationship.size(), 'The Junction Object should have 3 item.'); 

       for (OrderItemMilestoneAssociation__c association : context.newOrderItemsToMilestoneRelationship) {
           pse__Milestone__c milestone = milestones.get(association.Milestone__c);
           OrderItem orderItem = context.orderItemMap.get(association.Order_Product__c);
           Order orderCreated = context.orderMap.get(orderItem.OrderId);

           System.assertEquals(orderItem.Unit_Selling_Price_Local__c, milestone.pse__Milestone_Amount__c, 'The Amount field should be equal orderItem.Unit_Selling_Price_Local__c.');
           System.assertEquals(orderItem.Unit_Selling_Price_USD__c, milestone.Milestone_Amount_USD__c, 'The Amount USD field should be equal OrderItem.Unit_Selling_Price_USD__c.');
           System.assertEquals(orderItem.SKU_Cost_Local__c, milestone.pse__Milestone_Cost__c, 'The Cost field should be equal orderItem.SKU_Cost_Local__c.');
           System.assertEquals(orderItem.SKU_Cost_USD__c, milestone.Milestone_Cost_USD__c, 'The Cost USD field should be equal orderItem.SKU_Cost_USD__c'); 
           System.assertEquals(Date.today(), milestone.pse__Target_Date__c, 'The Current property should be true.');
           System.assertEquals(false, milestone.Current__c, 'The Current property should be false.');  
           System.assert(milestone.Name.contains(orderCreated.OrderNumber__c + ' - Milestone'), 'The Milestone Name should have the "Order.OrderNumber__c - Milestone"');
       }  
   }

   @isTest              
   static void updateMilestoneToRegularProjectWithMilestone() {
       // Arrange
       Order orderFirst = [SELECT Id FROM Order WHERE OrderNumber__c =: '9876'];
       pse__Proj__c project = [SELECT Id FROM pse__Proj__c LIMIT 1];
       OrderItem orderItemFirst = [SELECT Id FROM OrderItem WHERE SKU_Number__c =: '9876-9876'];

       pse__Milestone__c milestone = new pse__Milestone__c();
       orderFirst.Milestone__c = milestone.Id;
       update orderFirst;

       Order orderSecond = [SELECT Id FROM Order WHERE OrderNumber__c =: '1234'];
       OrderItem orderItemSecond = [SELECT Id FROM OrderItem WHERE SKU_Number__c =: '1234-456'];
       
       List<Order_Association__e> eventList = new List<Order_Association__e>();
       
       eventList.add(new Order_Association__e(
           Order_ID__c = orderFirst.Id, Project_ID__c = project.Id, Order_Item_Id__c = orderItemFirst.Id));
       eventList.add(new Order_Association__e(
           Order_ID__c = orderSecond.Id, Project_ID__c = project.Id, Order_Item_Id__c = orderItemSecond.Id));
       
       OrderAssociationDataContext context = new OrderAssociationDataContext(eventList);
      
       // Act
       Test.startTest();
       OrderAssociationMilestone.updateMilestonesInformation(context);
       Test.stopTest();

       // Assert
       List<pse__Milestone__c> milestones = [SELECT Id, 
                                                   Name,
                                                   Current__c, 
                                                   pse__Target_Date__c,
                                                   pse__Milestone_Amount__c,
                                                   Milestone_Amount_USD__c, 
                                                   pse__Milestone_Cost__c,
                                                   Milestone_Cost_USD__c
                                           FROM pse__Milestone__c];

       System.assertEquals(1, milestones.size(), 'It should have only one milestone');
       System.assertEquals('Milestone', milestones[0].Name, 'The Mileston Name should "Milestone".');        
       System.assertEquals(Date.today(), milestones[0].pse__Target_Date__c, 'The Current property should be true.');
       System.assertEquals(true, milestones[0].Current__c, 'The Current property should be true.');
       System.assertEquals(7, milestones[0].pse__Milestone_Amount__c, 'The Amount field should be 7.');
       System.assertEquals(7, milestones[0].Milestone_Amount_USD__c, 'The Amount USD field should be 7.');
       System.assertEquals(25, milestones[0].pse__Milestone_Cost__c, 'The Cost field should be 25.');
       System.assertEquals(25, milestones[0].Milestone_Cost_USD__c, 'The Cost USD field should be 25'); 
       System.assertEquals(2, context.newOrderItemsToMilestoneRelationship.size(), 'The Junction Object should have 2 item.');
   }    

   @isTest              
   static void createMilestoneToDistinctAndRegularProject() {
       // Arrange

       // distinct
       Order order = [SELECT Id, OrderNumber__c FROM Order WHERE OrderNumber__c =: '1234'];
       Sku_Effort_Map__c skuEffortMap = [SELECT Id FROM SKU_Effort_Map__c];
       pse__Proj__c projectDistinct = [SELECT Id FROM pse__Proj__c LIMIT 1];
       projectDistinct.Distinct_SKU_Effort_Mapping__c = skuEffortMap.Id;

       update projectDistinct;

       OrderItem orderItemFirst = [SELECT Id FROM OrderItem WHERE SKU_Number__c =: '9876-456'];
       OrderItem orderItemSecond = [SELECT Id FROM OrderItem WHERE SKU_Number__c =: '1234-456'];

       // regular
       pse__Proj__c projectRegular = OPRTestFactory.createSimpleProject();
       OrderItem orderItemThird = createOrderItem(order.Id, '9876-098', 'SVC EDT INSTLN', 2, 10, 5);        
       
       List<Order_Association__e> eventList = new List<Order_Association__e>();
       
       eventList.add(new Order_Association__e(
           Order_ID__c = order.Id, Project_ID__c = projectDistinct.Id, Order_Item_Id__c = orderItemFirst.Id));
       eventList.add(new Order_Association__e(
           Order_ID__c = order.Id, Project_ID__c = projectDistinct.Id, Order_Item_Id__c = orderItemSecond.Id));
       eventList.add(new Order_Association__e(
           Order_ID__c = order.Id, Project_ID__c = projectRegular.Id, Order_Item_Id__c = orderItemThird.Id));
       
       OrderAssociationDataContext context = new OrderAssociationDataContext(eventList);
      
       // Act
       Test.startTest();
       OrderAssociationMilestone.updateMilestonesInformation(context);
       Test.stopTest();

       // Assert
       List<pse__Milestone__c> milestones = [SELECT Id, Name, Current__c, pse__Target_Date__c, pse__Project__c FROM pse__Milestone__c ORDER BY Name DESC];

       System.assertEquals(4, milestones.size(), 'It should have four milestones.');
       System.assertEquals(4, context.newOrderItemsToMilestoneRelationship.size(), 'The Junction Object should have 4 item.'); 
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
       Id orderId, String skuNumber, String itemClassDesc, 
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
       oi.Item_Class_Description__c = 'SVC EDT INSTLN';
       oi.Tie_Number__c = '1';
       oi.OrderId = orderId;
       oi.PriceBookEntryId = priceBookEntry.Id;
       oi.SKU_Cost__c = skuCost;
       oi.SKU_Cost_Local__c = skuCost;
       oi.SKU_Cost_USD__c = skuCost;
       oi.Unit_Selling_Price_Local__c = unitSellingPrice;
       oi.Unit_Selling_Price_USD__c = unitSellingPrice;
       insert oi;

       return oi;
   }

   private static SKU_Effort_Map__c createSkuEffortMap(string[] skuNumbers) {
       SKU_Effort_Map__c skuEffortMap = new SKU_Effort_Map__c();
       skuEffortMap.Distinct_Project__c = true;
       skuEffortMap.Description__c = 'Test';
       skuEffortMap.Active__c = true;

       insert skuEffortMap;

       List<SKU_Number__c> skus = new List<SKU_Number__c>();
       for (String skuNumber : skuNumbers) {
           SKU_Number__c sku = new SKU_Number__c();
           sku.SKU_Number__c = skuNumber;
           sku.SKU_to_Effort_Mapping__c = skuEffortMap.Id;
           skus.add(sku);            
       }
       insert skus;

       return skuEffortMap;
   }
}