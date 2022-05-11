public with sharing class OrderDisassociationMilestone {
    
    public static void validateMilestones(OrderDisassociationDataContext context) { 
        
        Set<Id> ordersToBeRemoved = new Set<Id>();
        
        for(Id orderItemMilestoneId : context.orderItemApprovedMilestoneAssociationMap.KeySet()) { 
            OrderItemMilestoneAssociation__c orderItemMilestone = context.orderItemApprovedMilestoneAssociationMap.get(orderItemMilestoneId);
            ordersToBeRemoved.add(orderItemMilestone.Order_Product__r.OrderId);
        }
         
        for(Id orderId : ordersToBeRemoved) {
            
            if(!context.orderIdToPreventReason.containsKey(orderId)) {
                context.orderIdToPreventReason.put(orderId, new List<String>());
            }
            
            List<String> orderMessages = context.orderIdToPreventReason.get(orderId);
            orderMessages.add('This order has some approved Milestones.');
            
            context.orderIdToPreventReason.put(orderId, orderMessages);
        }
    }
    
    public static void recalculate(OrderDisassociationDataContext context) { 
    	Map<Id, Id> orderItemIdToMilestoneId = new Map<Id, Id>();
        Map<Id, Set<Id>> milestoneIdToOrderItemMilestoneAssociationId = new Map<Id, Set<Id>>();
        Map<Id, pse__Milestone__c> allMilestones = new Map<Id, pse__Milestone__c>();
        for(Id oimaId :context.orderItemMilestoneAssociationMap.keySet()) {
            OrderItemMilestoneAssociation__c oima = context.orderItemMilestoneAssociationMap.get(oimaId);
            orderItemIdToMilestoneId.put(oima.Order_Product__c, oima.Milestone__c);
            system.debug('orderItemIdToMilestoneId '+orderItemIdToMilestoneId);
            if(!milestoneIdToOrderItemMilestoneAssociationId.containsKey(oima.Milestone__c)) {
                milestoneIdToOrderItemMilestoneAssociationId.put(oima.Milestone__c, new Set<Id>());
            }
            
            Set<Id> oimaSet = milestoneIdToOrderItemMilestoneAssociationId.get(oima.Milestone__c);
            oimaSet.add(oimaId);
            milestoneIdToOrderItemMilestoneAssociationId.put(oima.Milestone__c, oimaSet);
            allMilestones.put(oima.Milestone__c, oima.Milestone__r);
        }
        
        for(Id projectId : context.projectWithAllOrderItemsMap.keySet()) {  
            pse__Proj__c project = context.projectMap.get(projectId);
            if(project != null && project.Distinct_Project__c) {
                system.debug('Delete Milestone Distinct');
                if(context.projectOrderItemsToBeDissociateMap.containsKey(projectId)) {
                    DeleteMilestones(context, projectId);
                }
            }
            else {
                List<OrderItem> orderItems = new List<OrderItem>(context.projectWithRemainingOrderItemsMap.get(projectId));
                
                for(Integer i = 0; i < orderItems.size(); i++) {
                    OrderItem orderItem = orderItems[i];
                    Id milestoneId = orderItemIdToMilestoneId.get(orderItem.Id);
                    if(allMilestones.containsKey(milestoneId)) {
                        pse__Milestone__c milestone = allMilestones.get(milestoneId);
                        if(milestone.pse__Status__c == 'Approved' || milestone.pse__Status__c == 'Canceled') {
                            orderItems.remove(i);
                        }
                    }
                }
                
                if(orderItems != null && orderItems.size() > 0) { 
                    system.debug('Recalculate Milestone Regular');
                    //Recalculate Milestone amounts
                    Amounts amounts = CalculationRulesUtils.amountCalculate(new Map<Id, OrderItem>(orderItems));
                    Id milestoneToUpdateId = orderItemIdToMilestoneId.get(orderItems[0].Id);
                    if(milestoneToUpdateId != null) {
                        pse__Milestone__c milestoneToUpdate = new pse__Milestone__c(Id = milestoneToUpdateId);
                        milestoneToUpdate.pse__Milestone_Amount__c = amounts.amount;
                        milestoneToUpdate.Milestone_Amount_USD__c = amounts.amountUSD;
                        milestoneToUpdate.pse__Milestone_Cost__c = amounts.skuCost;
                        milestoneToUpdate.Milestone_Cost_USD__c = amounts.skuCostUSD;
                        context.milestonesToUpdate.put(milestoneToUpdateId, milestoneToUpdate);
                        
                        for(Id oimaId : milestoneIdToOrderItemMilestoneAssociationId.get(milestoneToUpdateId)) {
                            OrderItemMilestoneAssociation__c orderItemMilestoneAssociationCurrent = context.orderItemMilestoneAssociationMap.get(oimaId);
                            boolean orderItemFound = false;
                            for(OrderItem orderItem : orderItems) {
                                if(orderItem.Id == orderItemMilestoneAssociationCurrent.Order_Product__c) {
                                    orderItemFound = true;
                                }
                            }
                            if(!orderItemFound) {
                            	context.milestoneOrderItemAssociationToDelete.put(oimaId, new OrderItemMilestoneAssociation__c(Id = oimaId));
                            }
                        }
                    }
                }
                //The same projects can be in both maps, if it occurs in projectWithRemainingOrderItemsMap cannot be deleted
                else {
                    system.debug('Delete Milestone Regular');
                    List<OrderItem> orderItemsDis = context.projectOrderItemsToBeDissociateMap.get(projectId);
                    if(orderItemsDis != null && orderItemsDis.size() > 0) { 
                        Id milestoneToDeleteId = orderItemIdToMilestoneId.get(orderItemsDis[0].Id);
                        if(milestoneToDeleteId != null) {
                            pse__Milestone__c milestoneToDelete = new pse__Milestone__c(Id = milestoneToDeleteId);
                            context.milestonesToDelete.put(milestoneToDeleteId, milestoneToDelete);
                            
                            for(Id oimaId : milestoneIdToOrderItemMilestoneAssociationId.get(milestoneToDeleteId)) {
                                context.milestoneOrderItemAssociationToDelete.put(oimaId, new OrderItemMilestoneAssociation__c(Id = oimaId));
                            }
                        }
                    }
                }
            }
        }
    }
    
    public static void DeleteMilestones(OrderDisassociationDataContext context, Id projectId) {
    	Map<Id, OrderItem> orderItems = new Map<Id, OrderItem>(context.projectOrderItemsToBeDissociateMap.get(projectId));
        system.debug('orderItems -- ' + orderItems);
        for(Id orderItemMilestoneId : context.orderItemMilestoneAssociationMap.keySet()) {
            OrderItemMilestoneAssociation__c orderItemMilestone = context.orderItemMilestoneAssociationMap.get(orderItemMilestoneId);
            if(orderItems.containsKey(orderItemMilestone.Order_Product__c)) {
                context.milestoneOrderItemAssociationToDelete.put(orderItemMilestoneId, new OrderItemMilestoneAssociation__c(Id = orderItemMilestoneId));
                context.milestonesToDelete.put(orderItemMilestone.Milestone__c, new pse__Milestone__c(Id = orderItemMilestone.Milestone__c));
            }
        }
    
    }
}