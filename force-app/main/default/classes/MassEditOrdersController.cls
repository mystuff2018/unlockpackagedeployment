/**
 * Created by tdavis on 10/5/18.
 */


public with sharing class MassEditOrdersController
{
    public class OrderItemMilestoneInfo {
        public List<OrderItemMilestoneAssociation__c> orderItemMilestoneAssociationList { get; set; }
        public List<pse__Milestone__c> milestones { get; set; }
    }
    
    @AuraEnabled
    public static List<Order> getOrderList(List<Id> projectIds)
    {
        List<OrderItem> orderItensList = [SELECT Id, orderId FROM OrderItem WHERE Project__c IN :projectIds];
        
        Set<Id> orderId = new Set<Id>();
        
        for (OrderItem oi : orderItensList){
            orderId.add(oi.orderId);
        }
        
        List<Order> orderList = [SELECT OrderNumber, Milestone__c From Order WHERE Id IN :orderId];
        return orderList;
    }

    @AuraEnabled
    public static void doAllUpdate(List<Order> orderList, Id milestoneId)
    {
        for (Order o : orderList)
        {
            o.Milestone__c = milestoneId;
        }

        update orderList;
    }

    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> search(String searchTerm, List<String> selectedIds) 
    {
        System.debug('searchTerm: '+ searchTerm);
        System.debug('selectedIds: '+ selectedIds);

        List<String> searchTerms = searchTerm.split(';');
        List<LookupSearchResult> listReturn = new List<LookupSearchResult>();
        If(searchTerms != null && searchTerms.size() > 1){
            List<pse__Milestone__c> listMilestones = [SELECT Id, Name FROM pse__Milestone__c WHERE Name LIKE :'%'+searchTerms[0]+'%' AND pse__Project__c = :searchTerms[1]];
        
            System.debug('ListMilestones :'+listMilestones);
            for(pse__Milestone__c a : listMilestones)
            {
                listReturn.add(new LookupSearchResult(a.Id, a.getSObjectType().getDescribe().getName(), 'standard:orders', a.Name, a.Name));
            }
        }
        return listReturn;
    }
    
    public static String updateMilestonesToProject(Id projectId, Id milestoneId, List<Id> orderIdList) {
        System.debug('projectId: '+projectId);
        System.debug('milestoneId: '+milestoneId);

        List<OrderItemMilestoneAssociation__c> orderItemMilestoneAssociation = getOrderItemMilestoneAssociationByOrderList(projectId, milestoneId, orderIdList);
        OrderItemMilestoneInfo orderItemMilestoneInfo = updateMilestonesAmounts(projectId, milestoneId, orderItemMilestoneAssociation);
        system.debug('orderItemMilestoneAssociation '+orderItemMilestoneAssociation);
        try {
            UPDATE orderItemMilestoneInfo.milestones;
            UPDATE orderItemMilestoneInfo.orderItemMilestoneAssociationList;
            return 'ok';
        }
        
        catch (Exception e) {
            return e.getMessage();
        }
    }
    
    private static List<OrderItemMilestoneAssociation__c> getOrderItemMilestoneAssociationByOrderList(Id projectId, Id milestoneId, List<Id> orderIdList) {
        List<OrderItemMilestoneAssociation__c> orderItemMilestoneAssociation = null;

        if (orderIdList != null && !orderIdList.isEmpty()) {
            orderItemMilestoneAssociation = [SELECT Id, Name, Milestone__c, Milestone__r.Milestone_Cost_USD__c, Milestone__r.Milestone_Amount_USD__c,
                                             Order_Product__c,
                                             Order_Product__r.Quantity, 
                                             Order_Product__r.Unit_Selling_Price_Local__c, 
                                             Order_Product__r.Unit_Selling_Price_USD__c, 
                                             Order_Product__r.SKU_Cost_Local__c,
                                             Order_Product__r.SKU_Cost_USD__c 
                                             FROM OrderItemMilestoneAssociation__c
                                             WHERE Order_Product__r.Project__c = :projectId AND Milestone__c != null AND Order_Product__r.orderId IN :orderIdList AND Milestone__c != :milestoneId];
        system.debug('orderItemMilestoneAssociation '+orderItemMilestoneAssociation);
        }else {
            orderItemMilestoneAssociation = [SELECT Id, Name, Milestone__c, Milestone__r.Milestone_Cost_USD__c, Milestone__r.Milestone_Amount_USD__c,
                                             Order_Product__c,
                                             Order_Product__r.Quantity, 
                                             Order_Product__r.Unit_Selling_Price_Local__c, 
                                             Order_Product__r.Unit_Selling_Price_USD__c, 
                                             Order_Product__r.SKU_Cost_Local__c,
                                             Order_Product__r.SKU_Cost_USD__c 
                                             FROM OrderItemMilestoneAssociation__c
                                             WHERE Order_Product__r.Project__c = :projectId AND Milestone__c != null AND Milestone__c != :milestoneId];    
        system.debug('orderItemMilestoneAssociation '+orderItemMilestoneAssociation);
        }
        
        return orderItemMilestoneAssociation;
    }
    
    private static List<OrderItemMilestoneAssociation__c> getOrderItemMilestoneAssociationByOrderItemList(Id projectId, Id milestoneId, List<Id> orderItemIdList) {
        List<OrderItemMilestoneAssociation__c> orderItemMilestoneAssociation = null;

        if (orderItemIdList != null && !orderItemIdList.isEmpty()) {
            orderItemMilestoneAssociation = [SELECT Id, Name, Milestone__c, Milestone__r.Milestone_Cost_USD__c, Milestone__r.Milestone_Amount_USD__c,
                                             Order_Product__c,
                                             Order_Product__r.Quantity, 
                                             Order_Product__r.Unit_Selling_Price_Local__c, 
                                             Order_Product__r.Unit_Selling_Price_USD__c, 
                                             Order_Product__r.SKU_Cost_Local__c,
                                             Order_Product__r.SKU_Cost_USD__c 
                                             FROM OrderItemMilestoneAssociation__c
                                             WHERE Order_Product__r.Project__c = :projectId AND Milestone__c != null AND Order_Product__c IN :orderItemIdList AND Milestone__c != :milestoneId];
        }
        
        return orderItemMilestoneAssociation;
    }
    
    private static List<pse__Milestone__c> recalculateMilestoneAmountsBy(List<pse__Milestone__c> milestoneList, Map<Id, List<OrderItem>> projectIdToListOrderItem, Id milestoneId) {
        system.debug('milestoneList '+milestoneList);
        for(pse__Milestone__c milestone :milestoneList)
        {
			if(projectIdToListOrderItem.containsKey(milestone.pse__Project__c)) {
				Amounts amount = CalculationRulesUtils.amountCalculate(new Map<Id, OrderItem>(projectIdToListOrderItem.get(milestone.pse__Project__c)));
				
				if(milestone.Id == milestoneId)
				{
					//add 
					system.debug('ADD  '+milestoneList);
					milestone.Milestone_Amount_USD__c = (milestone.Milestone_Amount_USD__c != null? milestone.Milestone_Amount_USD__c : 0) + (amount.amountUSD != null ? amount.amountUSD : 0);
					milestone.pse__Milestone_Amount__c = (milestone.pse__Milestone_Amount__c != null? milestone.pse__Milestone_Amount__c : 0) + (amount.amount != null ? amount.amount : 0);
					milestone.Milestone_Cost_USD__c = (milestone.Milestone_Cost_USD__c != null? milestone.Milestone_Cost_USD__c : 0) + (amount.skuCostUSD != null ? amount.skuCostUSD : 0);
					milestone.pse__Milestone_Cost__c = (milestone.pse__Milestone_Cost__c != null? milestone.pse__Milestone_Cost__c : 0) + (amount.skuCost != null ? amount.skuCost : 0);
				}
				else
				{
					//subtract
					system.debug('subtract '+milestoneList);
                    milestone.Milestone_Amount_USD__c = (milestone.Milestone_Amount_USD__c != null? milestone.Milestone_Amount_USD__c : 0) - (amount.amountUSD != null ? amount.amountUSD : 0);
					milestone.pse__Milestone_Amount__c = (milestone.pse__Milestone_Amount__c != null? milestone.pse__Milestone_Amount__c : 0) - (amount.amount != null ? amount.amount : 0);
					milestone.Milestone_Cost_USD__c = (milestone.Milestone_Cost_USD__c != null? milestone.Milestone_Cost_USD__c : 0) - (amount.skuCostUSD != null ? amount.skuCostUSD : 0);
					milestone.pse__Milestone_Cost__c = (milestone.pse__Milestone_Cost__c != null? milestone.pse__Milestone_Cost__c : 0) - (amount.skuCost != null ? amount.skuCost : 0);
				}
			}
        }
        
        return milestoneList;
    }
	
    private static OrderItemMilestoneInfo updateMilestonesAmounts(Id projectId, Id milestoneId, List<OrderItemMilestoneAssociation__c> orderItemMilestoneAssociation) {
        
        Set<Id> milestoneIdSet = new Set<Id>();
        Set<Id> orderItemIdSet = new Set<Id>();
        OrderItemMilestoneInfo orderItemMilestoneInfo = new OrderItemMilestoneInfo();
        system.debug('orderItemMilestoneAssociation '+orderItemMilestoneAssociation);
        for (OrderItemMilestoneAssociation__c eachOrderMilestone : orderItemMilestoneAssociation)
        {
            if(eachOrderMilestone.Milestone__c != null)
                milestoneIdSet.add(eachOrderMilestone.Milestone__c);
            if(eachOrderMilestone.Order_Product__c != null)
                orderItemIdSet.add(eachOrderMilestone.Order_Product__c);
            
            eachOrderMilestone.Milestone__c = milestoneId;
        }
        milestoneIdSet.add(milestoneId);
        system.debug('milestoneIdSet '+milestoneIdSet);
        List<pse__Milestone__c> milestoneList = [SELECT Id, Milestone_Amount_USD__c, pse__Milestone_Amount__c, Milestone_Cost_USD__c, pse__Milestone_Cost__c, pse__Project__c 
                                            FROM pse__Milestone__c WHERE Id IN :milestoneIdSet AND pse__Project__c != null];
        List<OrderItem> orderItemList = [SELECT Id, Quantity, Unit_Selling_Price_Local__c, Unit_Selling_Price_USD__c, SKU_Cost_Local__c, SKU_Cost_USD__c, Project__c
                                         FROM OrderItem WHERE Id IN :orderItemIdSet AND Project__c != null];
        system.debug('orderItemList '+orderItemList);
        Map<Id, List<OrderItem>> projectIdToListOrderItem = new Map<Id, List<OrderItem>>();
        for(OrderItem oi :orderItemList)
        {
            if(!projectIdToListOrderItem.containsKey(oi.Project__c))
            {
                projectIdToListOrderItem.put(oi.Project__c, new List<OrderItem>());
            }
            List<OrderItem> listOI = projectIdToListOrderItem.get(oi.Project__c);
            listOI.add(oi);
            projectIdToListOrderItem.put(oi.Project__c, listOI);
        }
        
        milestoneList = recalculateMilestoneAmountsBy(milestoneList, projectIdToListOrderItem, milestoneId);

        orderItemMilestoneInfo.milestones = milestoneList;
        orderItemMilestoneInfo.orderItemMilestoneAssociationList = orderItemMilestoneAssociation;
        return orderItemMilestoneInfo;
    }
    
    public static OrderItemMilestoneInfo updateMilestonesToProjectByOrderItems(Id projectId, Id milestoneId, List<Id> orderItemIdList) {
        List<OrderItemMilestoneAssociation__c> orderItemMilestoneAssociation = getOrderItemMilestoneAssociationByOrderItemList(projectId, milestoneId, orderItemIdList);
        OrderItemMilestoneInfo orderItemMilestoneInfo = updateMilestonesAmounts(projectId, milestoneId, orderItemMilestoneAssociation);
        return orderItemMilestoneInfo;
    }

    @AuraEnabled
    public static String updateMilestonesToProject (Id projectId, Id milestoneId) {
        return updateMilestonesToProject(projectId, milestoneId, null);
    }

    @AuraEnabled
    public static List<Order> getOrdersToProject (Id projectId){
        List<Order> orderToProject = new List<Order>();
        Set<Id> orderId = new Set<Id>();
    
        for (OrderItemMilestoneAssociation__c eachOrderAssociated : [SELECT Id, Name, Order_Product__r.orderId, Order_Product__r.Order.orderNumber__c 
                                                        FROM OrderItemMilestoneAssociation__c
                                                        WHERE Order_Product__r.Project__c = :projectId]) {
            
           if(!orderId.contains(eachOrderAssociated.Order_Product__r.orderId)){
               Order order = new Order(
                   Id = eachOrderAssociated.Order_Product__r.orderId,
                   orderNumber__c = eachOrderAssociated.Order_Product__r.Order.orderNumber__c
               );
               orderToProject.add(order);
               orderId.add(order.Id);

           }                     
            
        }
        return orderToProject;
    }

    @AuraEnabled
    public static String saveSelectedOrders (Id projectId, Id milestoneId, List<Id> orderIdList){
        system.debug(projectId +'___'+milestoneId+'__'+orderIdList);
        return updateMilestonesToProject(projectId, milestoneId, orderIdList); 
    }  
}