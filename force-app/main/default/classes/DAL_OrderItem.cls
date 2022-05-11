public class DAL_OrderItem {
   
    public static Map<Id, List<OrderItem>> getOrderItemByOrderId(Set<Id> ordersId){
        Map<Id, List<OrderItem>> orderItemsByOrderId = new Map<Id, List<OrderItem>>();
        for(OrderItem orderItem: [SELECT Id, 
                                  		 Item_Class_Description__c, 
                                  		 OrderId, 
                                  		 Project__c,
										 Project__r.pse__Is_Active__c, 
                                  		 Quantity, 
                                  		 SKU_Cost__c, 
                                  	     SKU_Cost_Local__c, 
                                  		 SKU_Cost_USD__c,
                                  		 SKU_Cost_USD_formula__c, 
                                  		 SKU_Number__c, Unit_Selling_Price_Local__c,
                                  		 Unit_Selling_Price_USD__c,
                                  		 Order.OrderNumber__c,
                                  		 Dell_Order_Number__c,
										 OrderItemToProjectApproval__c,
										 OrderItemToProjectApproval__r.Project__c,
										 OrderItemToProjectApproval__r.Approval_Status__c
                                  FROM OrderItem 
                                  WHERE OrderId = :ordersId]){

            if(!orderItemsByOrderId.containsKey(orderItem.OrderId)){
                orderItemsByOrderId.put(orderItem.OrderId, new List<OrderItem>());
            }
            List<OrderItem> orderItems = orderItemsByOrderId.get(orderItem.OrderId);
            orderItems.add(orderItem);
            orderItemsByOrderId.put(orderItem.OrderId, orderItems);
        }
        return orderItemsByOrderId;
    }

	public static List<OrderItem> getOrderItensByOderIdForRejectedProjects(Set<Id> ordersId){
		List<OrderItem> orderItensForRejectedProjects = [SELECT Id,
											Item_Class_Description__c,
											OrderId,
											Project__c,
											Quantity,
											SKU_Cost__c,
											SKU_Cost_Local__c,
											SKU_Cost_USD__c,
											SKU_Cost_USD_formula__c,
											SKU_Number__c, Unit_Selling_Price_Local__c,
											Unit_Selling_Price_USD__c,
											Order.OrderNumber__c,
											Dell_Order_Number__c,
											OrderItemToProjectApproval__c,
											OrderItemToProjectApproval__r.Project__c,
											OrderItemToProjectApproval__r.Approval_Status__c
									FROM OrderItem
									WHERE OrderId = :ordersId
									AND OrderItemToProjectApproval__r.Approval_Status__c = 'Rejected'
									AND Project__c = null];

		return orderItensForRejectedProjects;
	}
    
    public static Map<Id, OrderItem> getOrderItensByIds (Set<Id> orderItemId){

       	return new Map<Id,OrderItem>([
               SELECT Id, 
            		  OrderId, 
            		  OrderItemNumber,
            		  Project__c,
            		  Dell_Order_Number__c,
            		  Quantity,
            		  SKU_Description__c, 
            		  SKU_Number__c, 
            		  Item_Class_Description__c,
            		  SKU_Cost__c, 
            		  SKU_Cost_Local__c, 
            		  SKU_Cost_USD__c, 
            		  SKU_Cost_USD_formula__c,
            	 	  Unit_Selling_Price_Local__c, 
            		  Unit_Selling_Price_USD__c 
               FROM OrderItem 
               WHERE Id = :orderItemId
        ]);

    }

    public static Map<Id, List<OrderItem>> getOrderItensByProjectIds(Set<Id> projectIds){
        Map<Id, List<OrderItem>> orderItemsByProjectId = new Map<Id, List<OrderItem>>();
        for(OrderItem orderItem: [SELECT Id, 
                                  		 Item_Class_Description__c, 
                                  		 Project__c, 
                                  		 Quantity,
                                  		 SKU_Cost__c,
                                  		 SKU_Cost_Local__c, 
                                  		 SKU_Cost_USD__c,
                                  		 SKU_Cost_USD_formula__c, 
                                  		 SKU_Number__c,
                                  		 Unit_Selling_Price_Local__c, 
                                  		 Unit_Selling_Price_USD__c
                                  FROM OrderItem 
                                  WHERE Project__c = :projectIds]){

            if(!orderItemsByProjectId.containsKey(orderItem.Project__c)){
                orderItemsByProjectId.put(orderItem.Project__c, new List<OrderItem>());
            }
            List<OrderItem> orderItems = orderItemsByProjectId.get(orderItem.Project__c);
            orderItems.add(orderItem);
            orderItemsByProjectId.put(orderItem.Project__c, orderItems);
        }
        return orderItemsByProjectId;
     }
    
    public static Map<Id, List<OrderItem>> getOrderItemsByApprovalProcess(Set<Id> approvalIds){
        Map<Id, List<OrderItem>> mapApprovalIdOrderItems = new Map<Id, List<OrderItem>>();
        
        for(OrderItem orderItem : [SELECT Id, Order.OrderNumber__c, OrderId, OrderItemToProjectApproval__c FROM OrderItem WHERE OrderItemToProjectApproval__c = :approvalIds]){
            if(!mapApprovalIdOrderItems.containsKey(orderItem.OrderItemToProjectApproval__c)) {
                mapApprovalIdOrderItems.put(orderItem.OrderItemToProjectApproval__c, new List<OrderItem>());
            }
            List<OrderItem> orderItems = mapApprovalIdOrderItems.get(orderItem.OrderItemToProjectApproval__c);
            orderItems.add(orderItem);
            mapApprovalIdOrderItems.put(orderItem.OrderItemToProjectApproval__c, orderItems);
        }

        return mapApprovalIdOrderItems;
    }
}