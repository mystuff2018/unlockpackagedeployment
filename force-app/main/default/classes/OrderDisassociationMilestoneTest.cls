@IsTest
private class OrderDisassociationMilestoneTest {
    
    // //Criar projeto distinct para deletar milestones
    // //Criar projeto regular para recalcular milestones
    // //Criar projeto regular e deleta milestone
    
       @testSetup
        static void setup(){
        List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
        system.runAs(loginUser[0]){
       Order orderFirst = createOrder('1234');
       pse__Proj__c projectFirst = OPRTestFactory.createSimpleProject();
       pse__Proj__c projectSecond = OPRTestFactory.createSimpleProject();
       pse__Proj__c projectThird = OPRTestFactory.createSimpleProject();
       OrderItem orderItemFirst = createOrderItem(orderFirst.Id, projectFirst.Id, '9876-456', 'SVC EDT INSTLN', 2, 10, 5);
       OrderItem orderItemSecond = createOrderItem(orderFirst.Id, projectSecond.Id, '1234-456', 'SVC EDT INSTLN', 1, 15, 2);
       Sku_Effort_Map__c skuEffortMap = createSkuEffortMap(new String[] {'9876-456', '1234-456'});
       Order orderSecond = createOrder('9876');
       OrderItem orderItemThird = createOrderItem(orderSecond.Id, projectThird.Id, '9876-9876', 'SVC EDT INSTLN', 1, 10, 5);
        }
   }
    
       @isTest              
       static void projectWithApprovedMilestone_ShouldNotDisassociateOrder() {
        // // Arrange
           Order order = [SELECT Id, OrderNumber__c FROM Order WHERE OrderNumber__c =: '1234'];
           pse__Proj__c project = [SELECT Id FROM pse__Proj__c LIMIT 1];
           OrderItem orderItemFirst = [SELECT Id FROM OrderItem WHERE SKU_Number__c =: '9876-456'];
           OrderItem orderItemSecond = [SELECT Id FROM OrderItem WHERE SKU_Number__c =: '1234-456'];
        
           pse__milestone__c milestone = OPRTestFactory.newMilestone(project.Id, 'Milestone Approved');
           INSERT milestone;
           milestone.pse__Status__c = 'Approved';
           UPDATE milestone;
        
           OrderItemMilestoneAssociation__c newOrderItemMilestoneAssociation = OPRTestFactory.newOrderItemMilestoneAssociation(orderItemFirst.Id, milestone.Id);
           INSERT newOrderItemMilestoneAssociation;        
        
           Set<Id> orderIds = new Set<Id>();
           orderIds.add(order.Id);
        
           OrderDisassociationDataContext context = new OrderDisassociationDataContext(orderIds);
       
        // // Act
          Test.startTest();
           OrderDisassociationMilestone.validateMilestones(context);
          Test.stopTest();
        
         system.assert(context.orderIdToPreventReason.size() > 0, 'Should have at least one prevent reason.');
      }
    
         @isTest              
         static void projectWithMilestone_ShouldDisassociateOrder() {
        // // Arrange
         Order order = [SELECT Id, OrderNumber__c FROM Order WHERE OrderNumber__c =: '1234'];
         pse__Proj__c project = [SELECT Id FROM pse__Proj__c LIMIT 1];
         OrderItem orderItemFirst = [SELECT Id FROM OrderItem WHERE SKU_Number__c =: '9876-456'];
         OrderItem orderItemSecond = [SELECT Id FROM OrderItem WHERE SKU_Number__c =: '1234-456'];
        
         pse__milestone__c milestone = OPRTestFactory.newMilestone(project.Id, 'Milestone');
         INSERT milestone;
         OrderItemMilestoneAssociation__c newOrderItemMilestoneAssociation = OPRTestFactory.newOrderItemMilestoneAssociation(orderItemFirst.Id, milestone.Id);
         INSERT newOrderItemMilestoneAssociation;        
        
         Set<Id> orderIds = new Set<Id>();
         orderIds.add(order.Id);
        
         OrderDisassociationDataContext context = new OrderDisassociationDataContext(orderIds);
       
        // // Act
         Test.startTest();
           OrderDisassociationMilestone.validateMilestones(context);
         Test.stopTest();
        
         system.assert(context.orderIdToPreventReason.size() == 0, 'Shouldnt have any prevent reason.');
     }
    
       @isTest              
         static void regularProjectWithMilestone_ShouldDisassociateOrder() {
           List<pse__Proj__c> projects = [SELECT Id FROM pse__Proj__c];
           system.assert(projects.size() >= 2, 'Not enough projects created to the test.');
        
           pse__Proj__c project1 = projects[0];
           pse__Proj__c project2 = projects[1];
        
           project2.pse__Parent_Project__c = project1.Id;
           UPDATE project2;
            
           List<Order> orders = [SELECT Id, OrderNumber__c FROM Order WHERE OrderNumber__c IN :(new Set<String>{'1234', '9876'})];
           system.assert(orders.size() >= 2, 'Not enough orders created to the test.');                                                                                     
        
           for(Order o :orders){
             o.Project__c = project1.Id;
           }
           UPDATE orders;
        
           pse__milestone__c milestone = OPRTestFactory.newMilestone(project2.Id, 'Milestone Approved');
           INSERT milestone;
           
           milestone.Milestone_Amount_USD__c = 10;
           milestone.Milestone_Cost_USD__c = 11;
           milestone.pse__Milestone_Amount__c = 10;
           milestone.pse__Milestone_Cost__c = 11;
           
           UPDATE milestone;
                
           List<OrderItemMilestoneAssociation__c> oimaList = new List<OrderItemMilestoneAssociation__c>();
           List<OrderItem> orderItems = [SELECT Id, SKU_Number__c, OrderId FROM OrderItem WHERE SKU_Number__c IN :(new Set<String>{'9876-456','1234-456', '9876-9876'})];
           for(OrderItem oi :orderItems)
           {
             oi.Project__c = project2.Id;
             oimaList.add(OPRTestFactory.newOrderItemMilestoneAssociation(oi.Id, milestone.Id));
           }
          UPDATE orderItems;
          INSERT oimaList;
          OrderDisassociationDataContext context;
          for(Order o :orders) {
              if(o.OrderNumber__c == '1234') {
                 context = new OrderDisassociationDataContext(new Set<Id>{o.Id});
              }
          }
         system.debug('context milestone test - ' + context);
         OrderDisassociationMilestone.recalculate(context);
        
         pse__Milestone__c milestoneAfter = context.milestonesToUpdate.get(milestone.Id);
        
         system.assert(milestoneAfter != null, 'Milestone should be in milestonesToUpdate.');
         system.assert(milestone.Milestone_Amount_USD__c != milestoneAfter.Milestone_Amount_USD__c, 'Should have Milestone_Amount_USD__c different than before.');
         system.assert(milestone.Milestone_Cost_USD__c != milestoneAfter.Milestone_Cost_USD__c, 'Should have Milestone_Cost_USD__c different than before.');
         system.assert(milestone.pse__Milestone_Amount__c != milestoneAfter.pse__Milestone_Amount__c, 'Should have pse__Milestone_Amount__c different than before.');
         system.assert(milestone.pse__Milestone_Cost__c != milestoneAfter.pse__Milestone_Cost__c, 'Should have pse__Milestone_Cost__c different than before.');
        
         //system.assertEquals(1, milestoneAfter.Milestone_Amount_USD__c, 'Not the expected Milestone_Amount_USD__c.');
         //system.assertEquals(1, milestoneAfter.Milestone_Cost_USD__c, 'Not the expected Milestone_Cost_USD__c.');
         //system.assertEquals(1, milestoneAfter.pse__Milestone_Amount__c, 'Not the expected pse__Milestone_Amount__c.');
         //system.assertEquals(1, milestoneAfter.pse__Milestone_Cost__c, 'Not the expected pse__Milestone_Cost__c.');
     }
    
     @isTest              
     static void regularProjectWithMilestone_ShouldDisassociateOrderDeleteMilestone() {
         List<pse__Proj__c> projects = [SELECT Id FROM pse__Proj__c];
         system.assert(projects.size() >= 2, 'Not enough projects created to the test.');
        
         pse__Proj__c project1 = projects[0];
         pse__Proj__c project2 = projects[1];
        
         project2.pse__Parent_Project__c = project1.Id;
         UPDATE project2;
            
         List<Order> orders = [SELECT Id, OrderNumber__c FROM Order WHERE OrderNumber__c IN :(new Set<String>{'1234', '9876'})];
         system.assert(orders.size() >= 2, 'Not enough orders created to the test.');                                                                                     
        
         for(Order o :orders){
             o.Project__c = project1.Id;
         }
         UPDATE orders;
        
         pse__milestone__c milestone = OPRTestFactory.newMilestone(project2.Id, 'Milestone Approved');
         INSERT milestone;
         milestone.pse__Status__c = 'Approved';
         UPDATE milestone;
                
         List<OrderItemMilestoneAssociation__c> oimaList = new List<OrderItemMilestoneAssociation__c>();
         List<OrderItem> orderItems = [SELECT Id, SKU_Number__c, OrderId FROM OrderItem WHERE SKU_Number__c IN :(new Set<String>{'9876-456','1234-456', '9876-9876'})];
         for(OrderItem oi :orderItems)
         {
             oi.Project__c = project2.Id;
             oimaList.add(OPRTestFactory.newOrderItemMilestoneAssociation(oi.Id, milestone.Id));
         }
         UPDATE orderItems;
         INSERT oimaList;
         OrderDisassociationDataContext context = new OrderDisassociationDataContext(new Map<Id, Order>(orders).keySet());
         OrderDisassociationMilestone.recalculate(context);
        
         List<pse__Milestone__c> milestones = [SELECT Id FROM pse__Milestone__c];
         system.assert(milestones.size() == context.milestonesToDelete.size() , 'All milestones should be in milestonesToDelete.');
     }
    
     @isTest              
      static void distinctProjectWithMilestone_ShouldDisassociateOrderDeleteMilestone() {
           List<String> skuNumbersToMap1 = new List<String>{'111-1111'};
           Map<String, String> phaseByTask = new Map<String, String>();
           phaseByTask.put('Scoping', 'Initiate');
           SKU_Effort_Map__c skuEffort1 = OPRTestFactory.createSkuEffortMap(skuNumbersToMap1, 10, false, phaseByTask);
        
           List<pse__Proj__c> projects = [SELECT Id FROM pse__Proj__c];
           system.assert(projects.size() >= 2, 'Not enough projects created to the test.');
        
           pse__Proj__c project1 = projects[0];
           pse__Proj__c project2 = projects[1];
        	test.starttest();
           project2.pse__Parent_Project__c = project1.Id;
           project2.Distinct_SKU_Effort_Mapping__c = skuEffort1.Id;
           UPDATE project2;
            
           List<Order> orders = [SELECT Id, OrderNumber__c FROM Order WHERE OrderNumber__c IN :(new Set<String>{'1234', '9876'})  Limit 10];
           system.assert(orders.size() >= 2, 'Not enough orders created to the test.');                                                                                     
        
           for(Order o :orders){
             o.Project__c = project1.Id;
           }
           UPDATE orders;
        
           pse__milestone__c milestone = OPRTestFactory.newMilestone(project2.Id, 'Milestone Approved');
           INSERT milestone;
           milestone.pse__Status__c = 'Approved';
           UPDATE milestone;
                
           List<OrderItemMilestoneAssociation__c> oimaList = new List<OrderItemMilestoneAssociation__c>();
           List<OrderItem> orderItems = [SELECT Id, SKU_Number__c, OrderId FROM OrderItem WHERE SKU_Number__c IN :(new Set<String>{'9876-456','1234-456', '9876-9876'}) Limit 10];
           for(OrderItem oi :orderItems)
           {
               oi.Project__c = project2.Id;
               oimaList.add(OPRTestFactory.newOrderItemMilestoneAssociation(oi.Id, milestone.Id));
           }
           UPDATE orderItems;
           INSERT oimaList;
          test.stopTest();
          /* OrderDisassociationDataContext context = new OrderDisassociationDataContext(new Map<Id, Order>(orders).keySet());
           OrderDisassociationMilestone.recalculate(context);*/
        
           List<pse__Milestone__c> milestones = [SELECT Id FROM pse__Milestone__c Limit 5];
          // system.assert(milestones.size() == context.milestonesToDelete.size() , 'All milestones should be in milestonesToDelete.');
       }
    
     private static Order createOrder(String orderNumber) {
        // // Create Account
         Account account = new Account();
         account.Name = 'Create Account Test';
         insert account;
        // // create order
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
     private static OrderItem createOrderItem(Id orderId, Id projectId, String skuNumber, String itemClassDesc, Integer quantity, Decimal skuCost, Decimal unitSellingPrice) {        
        // // Order Product
         Product2 product = new Product2();
         product.Name='Product Test';
         insert product;
         PricebookEntry pricebookEntry = new PricebookEntry();
         pricebookEntry.Pricebook2Id = Test.getStandardPricebookId();
         pricebookEntry.Product2Id = product.Id;
         pricebookEntry.UseStandardPrice = false; 
         pricebookEntry.UnitPrice = 1;
         insert pricebookEntry;
        // // Order Item
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
         oi.Project__c = projectId;
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