public class IdsOrderUpdateHandler {

     private static final List<String> cancelStatusList = new List<String>{'Cancelled', 'CL'};

     public static void handleOrderUpdate(List<Order> newOrders, List<Order> oldOrders) {
        
         List<Id> updatedProjects = new List<Id>(); 
         Map<Id,Order> mapOldOrders = new Map<Id,Order>(oldOrders);
         Set<Id> ordersToDesassociate = new Set<Id>();

         for(Order newOrder : newOrders){
             Order oldOrder = mapOldOrders.get(newOrder.Id);

             if(oldOrder != null) {
       
                 Boolean isChangingStatusToCancelled = (newOrder.Status != oldOrder.Status) && cancelStatusList.contains(newOrder.Status);

                 // When the order is cancelled
                 if(isChangingStatusToCancelled) {
                     if(newOrder.Project__c != null) { // && !updatedProjects.Contains(newOrder.Project__c)) {
                         ordersToDesassociate.add(newOrder.Id);
                     }
                 }
                
             }
         }
       
         // Fires the disassociation process
         if(ordersToDesassociate.size() > 0)
         new OrderDisassociationHandler(ordersToDesassociate).run();
      
     }

     public static void handleStatusUpdate(List<Order> newOrders, List<Order> oldOrders, List<Custom_Order_Status_to_Order_Status_Map__mdt> maps){
        
         Map<String, Custom_Order_Status_to_Order_Status_Map__mdt> statusByNameMap = new Map<String, Custom_Order_Status_to_Order_Status_Map__mdt>();
         Map<String, Custom_Order_Status_to_Order_Status_Map__mdt> statusByCustomNameMap = new Map<String, Custom_Order_Status_to_Order_Status_Map__mdt>();
        
         Map<Id,Order> mapOldOrders = new Map<Id,Order>(oldOrders);
       
         for(Custom_Order_Status_to_Order_Status_Map__mdt mapping : maps){
             statusByCustomNameMap.put(mapping.Custom_Status__c, mapping);
             statusByNameMap.put(mapping.Order_Status__c, mapping);
         }

         Map<Id, Boolean> ordertWithOrderItemMap = new Map<Id, Boolean>();
         List<OrderItem> orderItemsFromOrders = [SELECT Id, OrderId FROM OrderItem WHERE OrderId IN :newOrders];
         for(Order order : newOrders){
             for(OrderItem orderItem: orderItemsFromOrders){
                 if(orderItem.OrderId == order.Id){
                     ordertWithOrderItemMap.put(order.Id, true);
                 }
             }

             if(!ordertWithOrderItemMap.containsKey(order.Id)){
                 ordertWithOrderItemMap.put(order.Id, false);
             }
         }
        
         for(Order newOrder : newOrders){

             Order oldOrder = mapOldOrders.get(newOrder.Id);
             Boolean isChangingStatus = newOrder.Order_Status__c != oldOrder.Order_Status__c;

             if(oldOrder != null && isChangingStatus) {  
                
                 Boolean orderHasOrderItem = ordertWithOrderItemMap.get(newOrder.Id);

                 if(orderHasOrderItem) {

                     switch on newOrder.Order_Status__c {
                         when 'POD'{
                             if(newOrder.Delivered_Date__c == null){
                                 newOrder.Delivered_Date__c = newOrder.Status_Date_Time__c;
                             }
                         }
                         when 'RDD' {
                             newOrder.Estimated_Delivery_Date__c = newOrder.RDD_Date__c;
                         }
                         when else {
                            
                             Custom_Order_Status_to_Order_Status_Map__mdt orderStatusUpdate = statusByCustomNameMap.get(newOrder.Order_Status__c);
                             Custom_Order_Status_to_Order_Status_Map__mdt oldOrderStatus = statusByNameMap.get(oldOrder.Status);
                            
                             if(orderStatusUpdate != null && 
                                 newOrder.Order_Status__c == orderStatusUpdate.Custom_Status__c && 
                                 orderStatusUpdate.Status_Order__c > oldOrderStatus.Status_Order__c) {
                                     newOrder.Status = orderStatusUpdate.Order_Status__c;
                             }
                             else { 
                                 newOrder.Order_Status__c = oldOrder.Order_Status__c; 
                             }
                         }
                     }
                 }
             }
         }
     }
    
}