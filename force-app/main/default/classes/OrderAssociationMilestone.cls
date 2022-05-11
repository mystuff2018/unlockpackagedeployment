/**
 * Created by Bruno_Frosi on 1/30/2020.
 * Edited by Christopher Michel and Magaiver Oliveira on 4/13/2020
 */

public with sharing class OrderAssociationMilestone {
    
    /**
 	* The relationship between milestone and orderItem occurs through a junction object called OrderItemMilestoneAssociation__c. Then, it was necessary to save the new milestones before saving the context, allowing only the junction objects to be saved in the context with milestones information already filled.
 	*/
    public static void updateMilestonesInformation(OrderAssociationDataContext context) {
        
        Set<Id> orderItemsFromRegularProject = new Set<Id>();
    	Set<Id> orderItemsFromDistinctProject = new Set<Id>();

        filterDistinctAndRegularProjects(context, orderItemsFromRegularProject, orderItemsFromDistinctProject);
        updateMilestoneToRegularProject(context, orderItemsFromRegularProject);
        updateMilestoneToDistinctProject(context, orderItemsFromDistinctProject);
    }

    private static void filterDistinctAndRegularProjects(OrderAssociationDataContext context, Set<Id> orderItemsFromRegularProject, Set<Id> orderItemsFromDistinctProject) {   
        for(Id orderItemId : context.orderItemsToBeAssociated.keySet()) {
            Id projectId = context.orderItemsToBeAssociated.get(orderItemId);
            system.debug('projectId----'+projectId);
            pse__Proj__c project = context.projectMap.get(projectId);
            system.debug('orderItemId----'+orderItemId);
            
            if(project.Distinct_Project__c) {
                orderItemsFromDistinctProject.add(orderItemId);
            }
            else {
                orderItemsFromRegularProject.add(orderItemId);
            }
        }
    }
    
    private static void updateMilestoneToRegularProject(OrderAssociationDataContext context, Set<Id> orderItemsFromRegularProject) {
        
        Map<Id, pse__Milestone__c> orderItemToMilestoneMap = new Map<Id, pse__Milestone__c>();
        system.debug('orderItemsFromRegularProject---'+orderItemsFromRegularProject);
        for(Id orderItemId : orderItemsFromRegularProject) {
            
            pse__Milestone__c currentMilestone;
            Id projectId = context.orderItemsToBeAssociated.get(orderItemId);
            List<pse__Milestone__c> milestones = context.projectIdToMilestoneListMap.get(projectId);
            OrderItem orderItem = context.orderItemMap.get(orderItemId);
            
            for(pse__Milestone__c milestone :milestones) {
                if(milestone.Current__c == true && milestone.pse__Status__c !='Approved' && milestone.pse__Status__c != 'Canceled') {
                    currentMilestone = milestone;
                }
            } 
            
            if(currentMilestone == null) {
                pse__Milestone__c newMilestone = createMilestone(context, projectId, orderItemId, true, null);
                milestones.add(newMilestone);
                context.projectIdToMilestoneListMap.put(projectId, milestones);
                context.newMilestones.add(newMilestone);
                currentMilestone = newMilestone;
            }
            fillAmountInformationRegular(context, currentMilestone, projectId);
            orderItemToMilestoneMap.put(orderItemId, currentMilestone);
        }
        system.debug('orderItemToMilestoneMap---'+orderItemToMilestoneMap);
        List<pse__Milestone__c> upsertMilestones = new List<pse__Milestone__c>();
        system.debug('context.projectIdToMilestoneListMap---'+context.projectIdToMilestoneListMap);
        for(Id projectId : context.projectIdToMilestoneListMap.keySet()) { 
        	upsertMilestones.addAll(context.projectIdToMilestoneListMap.get(projectId));
        
        }
        
        saveMilestones(context, upsertMilestones);
        createJunctionObjectRegularProjects(context, orderItemToMilestoneMap);
    }
    
	private static void updateMilestoneToDistinctProject(OrderAssociationDataContext context, Set<Id> orderItemsFromDistinctProject) {
		
        List<OrderItemMilestone> orderItemsMilestone = new List<OrderItemMilestone>();
        if(orderItemsFromDistinctProject.size()>0){
		for(Id orderItemId : orderItemsFromDistinctProject) {
            
            Map<Id, OrderItem> orderItems = new Map<Id, OrderItem>();
            Id projectId = context.orderItemsToBeAssociated.get(orderItemId);
            List<pse__Milestone__c> milestones = context.projectIdToMilestoneListMap.get(projectId);
            OrderItem orderItem = context.orderItemMap.get(orderItemId);   
            orderItems.put(orderItemId, orderItem);
            
            Decimal sign;
            if(orderItem.quantity!=null){
                sign = Math.signum(orderItem.quantity);
            for(integer i = 1; i <= Math.abs(orderItem.quantity); i++) {
                pse__Milestone__c newMilestone = createMilestone(context, projectId, orderItemId, false, String.valueOf(i));
                if(orderItem.Unit_Selling_Price_Local__c!=null &&  sign!=null)
                	newMilestone.pse__Milestone_Amount__c = orderItem.Unit_Selling_Price_Local__c * sign;
                if( orderItem.Unit_Selling_Price_USD__c!=null && sign!=null)
        			newMilestone.Milestone_Amount_USD__c = orderItem.Unit_Selling_Price_USD__c * sign;
                if(orderItem.SKU_Cost_Local__c!=null && sign!=null)
        			newMilestone.pse__Milestone_Cost__c = orderItem.SKU_Cost_Local__c * sign;
                if(orderItem.SKU_Cost_USD__c!=null && sign!=null)
        			newMilestone.Milestone_Cost_USD__c = orderItem.SKU_Cost_USD__c * sign;
                
            	milestones.add(newMilestone);
            	context.projectIdToMilestoneListMap.put(projectId, milestones);
            	context.newMilestones.add(newMilestone);
                
                OrderItemMilestone orderItemMilestone = new OrderItemMilestone();
                orderItemMilestone.milestone = newMilestone;
                orderItemMilestone.orderItems.add(orderItem);
                orderItemsMilestone.add(orderItemMilestone);
            
            }
            }
        }
        }
        saveMilestones(context, context.newMilestones);
        createJunctionObjectDistinctProjects(context, orderItemsMilestone);
    }
    
    private static void createJunctionObjectRegularProjects(OrderAssociationDataContext context, Map<Id, pse__Milestone__c> orderItemToMilestoneMap) { 
    
        for(Id orderItemId : orderItemToMilestoneMap.keySet()) {
            pse__Milestone__c milestone = orderItemToMilestoneMap.get(orderItemId);
            
        	OrderItemMilestoneAssociation__c orderItemToMilestone = new OrderItemMilestoneAssociation__c();
        	orderItemToMilestone.Milestone__c = milestone.Id;
        	orderItemToMilestone.Order_Product__c = orderItemId;
        	context.newOrderItemsToMilestoneRelationship.add(orderItemToMilestone);
        }
    }
    
    private static void createJunctionObjectDistinctProjects(OrderAssociationDataContext context, List<OrderItemMilestone> orderItemsMilestone) { 
    
        for(OrderItemMilestone orderItemMilestone : orderItemsMilestone) { 
            for(OrderItem orderItem : orderItemMilestone.orderItems) { 
            	OrderItemMilestoneAssociation__c orderItemToMilestone = new OrderItemMilestoneAssociation__c();
        		orderItemToMilestone.Milestone__c = orderItemMilestone.Milestone.Id;
        		orderItemToMilestone.Order_Product__c = orderItem.Id;
        		context.newOrderItemsToMilestoneRelationship.add(orderItemToMilestone);
            }
		}
    }
    
    private static void saveMilestones(OrderAssociationDataContext context, List<pse__Milestone__c> milestones) {
         List<Database.UpsertResult> milestonesResults = Database.upsert(milestones);
        context.exceptionLoggers.addAll(SaveResultExceptionLogger.saveResultsLog(context.orderMap.keySet(), milestonesResults, OrderAssociationDataContext.class.getName())); 
    }

    private static pse__Milestone__c createMilestone(OrderAssociationDataContext context, Id projectId, Id orderItemId, boolean current, string sufixo) {
        
        pse__Proj__c project = context.projectMap.get(projectId);
        pse__Milestone__c newMilestone = new pse__Milestone__c();
        OrderItem orderItem = context.orderItemMap.get(orderItemId);
        Order order = context.orderMap.get(orderItem.OrderId);
        newMilestone.pse__Project__c = project.Id;
        
        if(sufixo != null) {
        	newMilestone.Name = order.OrderNumber__c  + ' - Milestone ' + sufixo;
        }
        else {
            newMilestone.Name = 'Milestone';
        }
        
        if (project.pse__End_Date__c != null) {
        	newMilestone.pse__Target_Date__c = project.pse__End_Date__c;
        }
        else {
            newMilestone.pse__Target_Date__c = Date.today();
        }
        newMilestone.Current__c = current;
		return newMilestone;
    }
    
    private static void fillAmountInformationRegular(OrderAssociationDataContext context, pse__Milestone__c milestone, Id projectId) {
        
        Map<Id, OrderItem> orderItems = new Map<Id, OrderItem>();
        
        for(OrderItem orderItem : context.projectWithAllOrderItems.get(projectId)) {
            orderItems.put(orderItem.Id, orderItem);
        }
        
		Amounts amounts = CalculationRulesUtils.amountCalculate(orderItems);
        milestone.pse__Milestone_Amount__c = amounts.amount;
        milestone.Milestone_Amount_USD__c = amounts.amountUSD;
        milestone.pse__Milestone_Cost__c = amounts.skuCost;
        milestone.Milestone_Cost_USD__c = amounts.skuCostUSD;
    }

    /*public static void updateMilestonesInformation_old(OrderAssociationDataContext context)
    {
        createProjectMilestones(context);
        saveProjectMilestones(context);
        updateOrdersWithCurrentMilestone(context);
    }

    public static void updateOrdersWithCurrentMilestone(OrderAssociationDataContext context)
    {
        //public Map<Id, Set<Id>> projectWithOrdersMap

        for(Id projectId :context.projectWithOrdersMap.keySet())
        {
            Set<Id> orderIds = context.projectWithOrdersMap.get(projectId);
            List<pse__Milestone__c> milestoneList = context.projectIdToMilestoneListMap.get(projectId);
            
            if(milestoneList == null){
                continue;
            }

            if(orderIds.size() > 0)
            {
                for(Id orderId :orderIds)
                {
                    for(pse__Milestone__c milestone :milestoneList)
                    {
                        if(milestone.Current__c)
                        {
                            Order ordr = context.orderMap.get(orderId);
                            ordr.Milestone__c = milestone.Id;
                            context.orderMap.put(orderId, ordr);
                        }
                    }
                }
            }
        }
    }

    //Every insertion ou update of information should be done on DataContext.save()
    //BUT, I need the Ids for every milestone, to be able to link it to the orders, so I'm UPSERT them all here
    public static void saveProjectMilestones(OrderAssociationDataContext context)
    {
        List<pse__Milestone__c> everyMilestones = new List<pse__Milestone__c>();
        for(Id projectId :context.projectIdToMilestoneListMap.keySet())
        {
            everyMilestones.addAll(context.projectIdToMilestoneListMap.get(projectId));
        }
        UPSERT everyMilestones;

        //Instead of iterate over every milestone again, I'm just refreshing the projectIdToMilestoneListMap with values from DAL_Milestone
        context.projectIdToMilestoneListMap = DAL_Milestone.getMilestonesByProjectId(context.projectMap);
    }

    public static void createProjectMilestones(OrderAssociationDataContext context)
    {
        for(Id projectId :context.projectIdToMilestoneListMap.keySet())
        {
            List<pse__Milestone__c> milestoneList = context.projectIdToMilestoneListMap.get(projectId);
            Id idMilestoneCurrent = null;
            Integer nameComplement = 0;

            for(pse__Milestone__c milestone :milestoneList)
            {
                if(milestone.Current__c == true && milestone.pse__Status__c !='Approved' && milestone.pse__Status__c != 'Canceled')
                {
                    idMilestoneCurrent = milestone.Id;
                }
                nameComplement++;
            }

            if(idMilestoneCurrent == null)
            {
                pse__Proj__c project = context.projectMap.get(projectId);

                if(project != null)
                {
                    pse__Milestone__c newMilestone = new pse__Milestone__c();
                    newMilestone.pse__Project__c = project.Id;
                    newMilestone.Name = project.pse__Account__r.Name + ' - Milestone ' + (nameComplement + 1);
                    if (project.pse__End_Date__c != null)
                    {
                        newMilestone.pse__Target_Date__c = project.pse__End_Date__c;
                    }//true when associated a order to an existing project
                    else
                    {
                        newMilestone.pse__Target_Date__c = Date.today();
                    } //used to default case, when the project is being created
                    newMilestone.Current__c = true;

                    milestoneList.add(newMilestone);
                    context.projectIdToMilestoneListMap.put(projectId, milestoneList);
                }
            }
        }
    }
    */
    
    private class OrderItemMilestone{
        private List<OrderItem> orderItems;
        private pse__Milestone__c milestone;

        private OrderItemMilestone(){
            orderItems = new List<OrderItem>();
        }
    }
}