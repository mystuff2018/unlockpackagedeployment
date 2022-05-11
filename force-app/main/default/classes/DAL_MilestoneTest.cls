/**
 * Created by Bruno_Frosi on 2/10/2020.
 
Version    DevName     Comments
1.1        Yamini      Added 2 methods for coverage
*/
@IsTest
private class DAL_MilestoneTest {
     @IsTest
     static void testBehavior() {
         List<User> loginUser =  [Select Id from User where FBE_Integration_User__c = true];
         List<Account> listAcc = new List<Account>();
         listAcc.add(OPRTestFactory.newAccount('Account for testing', '111', '11', '12'));
         listAcc.add(OPRTestFactory.newAccount('Account for testing', '123'));
         listAcc.add(OPRTestFactory.newAccount('Account for testing', '234'));
         listAcc.add(OPRTestFactory.newAccount('Account for testing', '345'));
         listAcc.add(OPRTestFactory.newAccount('Account for testing', '456'));
           system.runAs(loginUser[0]){
             INSERT listAcc;
           }

         Contact contact = OPRTestFactory.newContact('firstName','lastName','United States','Texas','1234567890');
         INSERT contact;

         Order ordr = OPRTestFactory.newOrderWithItem('123123', listAcc[0].Id, contact.Id, 'United States', 'Texas', 'United States', 'Texas', '111', '222', '333',
                 listAcc[1].Id,
                 listAcc[2].Id,
                 listAcc[3].Id,
                listAcc[4].Id,  
                null, 'NOT IDS');

        pse__Proj__c project = OPRTestFactory.createProject(listAcc[1].Id, '111', '222', '333');
         INSERT project;

        pse__Milestone__c newMilestone = new pse__Milestone__c();
        newMilestone.pse__Project__c = project.Id;
        newMilestone.Name = 'Milestone';
         newMilestone.Current__c = false;
         newMilestone.pse__Target_Date__c = Date.today();
         INSERT newMilestone;
        
         List<Order> orders = [SELECT Id, (Select Id From OrderItems) FROM Order];
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
         Map<Id, List<pse__Milestone__c>> mapMilestone = DAL_Milestone.getMilestonesByProjectId(context.projectMap);
         Test.stopTest();

         system.assert(mapMilestone != null);
         system.assert(mapMilestone.size() > 0);
         for(Id milestoneId :mapMilestone.keySet()) {
             List<pse__Milestone__c> listMilestones = mapMilestone.get(milestoneId);
             system.assert(listMilestones != null);
             system.assert(listMilestones.size() > 0);
         }
     }
     //V1.1 Started
     @isTest
    static void testBehavior1() {
        Order order1 = OPRTestFactory.createSimpleOrder();
        Order order2 = OPRTestFactory.createSimpleOrder();
        
       pse__Proj__c project = OPRTestFactory.createSimpleProject();
        
        List<String> skuNumbersToMap = new List<String>{'123-456','CUSTOM SKU'};
        Map<String, String> phaseByTask = new Map<String, String>();
        phaseByTask.put('Scoping', 'Initiate');
        phaseByTask.put('Configuration', 'Execute');
        phaseByTask.put('Planning', 'Plan');
        SKU_Effort_Map__c skuEffort2 = OPRTestFactory.createSkuEffortMap(skuNumbersToMap, 10, false, phaseByTask);
        List<Order> orders = [SELECT Id, (Select Id From OrderItems) FROM Order];
        List<OrderItem> items = new List<OrderItem>();
        for(Order ord: orders){
            OrderItem item = ord.OrderItems[0];
            item.SKU_Number__c='123-456';
            items.add(item);
        }
        update items;
        
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
        
        Test.startTest();
        Set<Id> orderIdToDesassociate = new Set<Id>();
        orderIdToDesassociate.add(orders[0].Id);
        OrderDisassociationHandler handler = new OrderDisassociationHandler(orderIdToDesassociate);
        handler.run();
        Test.stopTest();

    }
    @isTest 
    static void testgetApprovedMilestonesByIds(){
        String milestonename='Milestonename';
         pse__Proj__c project = OPRTestFactory.createSimpleProject();
        pse__Milestone__c milestone = OPRTestFactory.newMilestone(project.Id, milestonename);
        milestone.pse__Status__c='Approved';
        Map<id,pse__Milestone__c> mapMilestoneids = new Map<id,pse__Milestone__c>([Select Id From pse__Milestone__c WHERE pse__Status__c = 'Approved']);
        set<Id> MilestoneIds = mapMilestoneids.keySet();
        Map<Id, pse__Milestone__c> mapMilestone = DAL_Milestone.getApprovedMilestonesByIds( MilestoneIds);
        system.assert(mapMilestone != null);
         
         
      
    }
    //v1.1 ended
    
}