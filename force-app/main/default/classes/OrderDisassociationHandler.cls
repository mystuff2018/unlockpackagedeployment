public with sharing class OrderDisassociationHandler {
    public OrderDisassociationDataContext context;
    
    public OrderDisassociationHandler(Set<Id> orderIds) {
        context = new OrderDisassociationDataContext(orderIds); 
    }
    
    public void run() {
        OrderDisassociationMilestone.validateMilestones(context);
        cleanUpInvalidOrders();

        context.orderItemsToBeDissociateList = getOrderItemsToBeDissociateList();
        context.ordersToBeDissociateList = getOrdersToBeDissociateList();
        removeApprovalProcess();

        context.save();
        sendNotification();

        System.enqueueJob(new OrderDisassociationQueueable(context, UserInfo.getUserId()));
    }
    
   		private void sendNotification(){
        List<OrderItem> orderItems = new List<OrderItem>();
        Map<Id, List<OrderItem>> projectIdByOrderItemList = context.projectOrderItemsToBeDissociateMap;
        Map<Id, List<OrderItem>> inactiveProjectToOrderItems = context.inactiveProjectToOrderItems;
        system.debug('Project Order Items'+projectIdByOrderItemList);
        Map<Id, pse__Proj__c> projectMap = context.projectMap;
        Map<Id, pse__Proj__c> inactiveProjectMap = context.inactiveProjectMap;
        system.debug('Project Map Values'+projectMap);
        if (projectIdByOrderItemList != null) {    
            Set<String> recipientIds = new Set<String>();
            Map<Id, String> notificationListByProjectMap = new Map<Id, String>();
            
            for (Id projectId : projectIdByOrderItemList.keySet()) {
                Set<String> projectOwnerIdSet = new set<String>();
                pse__Proj__c project = projectMap.get(projectId);
                if(project.Owner.Type != String.valueOf(User.SObjectType))
                    continue;

                projectOwnerIdSet.add(project.OwnerId);
                
                for(OrderItem oi : projectIdByOrderItemList.get(projectId)){
                	notificationListByProjectMap.put(projectId, 'Order ' + oi.Dell_Order_Number__c + ' removed from the Project' );
                	                    
                }
              
                FFNotificationHelper.buildFFNotification('Order was disassociated', notificationListByProjectMap.get(projectId), projectId, projectOwnerIdSet);
                
            }
            //Added as a part of story 10466018
            for (Id projectId : inactiveProjectToOrderItems.keyset()) {
                Set<String> projectOwnerIdSet = new set<String>();
                pse__Proj__c project = inactiveProjectMap != null ? inactiveProjectMap.get(projectId) : null;
                if(project == null || project.Owner.Type != String.valueOf(User.SObjectType))
                    continue;
                
                projectOwnerIdSet.add(project.OwnerId);
                
                for(OrderItem oi : inactiveProjectToOrderItems.get(projectId)){
                    notificationListByProjectMap.put(projectId, 'Order Number'+ oi.Dell_Order_Number__c  );
                    
                }
                
                FFNotificationHelper.buildFFNotification('Order was Cancelled', notificationListByProjectMap.get(projectId), projectId, projectOwnerIdSet);
                
            }
           // FFNotificationHelper.postChatter(notificationListByProjectMap);
        }
    }
    private List<OrderItem> getOrderItemsToBeDissociateList() {
        List<OrderItem> orderItems = new List<OrderItem>();
        if (context.projectOrderItemsToBeDissociateMap != null) {    
            for (Id projectId : context.projectOrderItemsToBeDissociateMap.keySet()) {
                string payload = 'Project ' + projectId + '. OrderItems: ';
                Id orderId;
                for (Orderitem item : context.projectOrderItemsToBeDissociateMap.get(projectId)) {
                    OrderItem newOrderItem = new OrderItem();
                    newOrderItem.Id = item.Id;
                    newOrderItem.Project__c = null;
                    orderItems.add(newOrderItem);
                    
                    orderId = item.OrderId;
                    payload+= '(' + item.SKU_Number__c + ') ';
                }
                
                context.executionControl.setProcessLog(orderId, payload, 'Disassociating OrderItems');
            }
        }
        return orderItems;
    }
    
    private List<Order> getOrdersToBeDissociateList() {
        List<Order> ordersToRemoveFromEngagement = new List<Order>();
        
        if(context.ordersByIds != null && context.ordersByIds.size() > 0) {
            for (Id orderId : context.ordersByIds.keySet()) {
                
                Order order = context.ordersByIds.get(orderId);
                
                if(order.Status != 'Cancelled' && order.Status != 'CL'){
                    Order newOrder = new Order();
                    newOrder.Project__c = null;
                    newOrder.Unassociated__c = true;
                    newOrder.Id = orderId;
                    ordersToRemoveFromEngagement.add(newOrder);
                }
            }
        }
        return ordersToRemoveFromEngagement;
    }
    
    private void cleanUpInvalidOrders() {
        Boolean shouldRefresh = false;
        if(context.ordersByIds != null) { 
            for (Id orderId : context.orderIdToPreventReason.keySet()) {
                
                if(context.ordersByIds.containsKey(orderId)) {
                    shouldRefresh = true;
                    context.ordersByIds.remove(orderId);
                }
            }
            //We call the context.refresh to avoid removing manually records from the context.
            //using this way we just reset everything without the records we don't need.
            //If SOQL limits comes too close, we need to revisit this.
            if(shouldRefresh){
                context.refresh(context.ordersByIds.KeySet());
            }
        }
        else {
            context.refresh(new Set<Id>());
        }
    }

    private void removeApprovalProcess(){
        List<Approval.ProcessWorkitemRequest> approvalProcessRequests = new List<Approval.ProcessWorkitemRequest>();
        for(Id orderId : context?.orderIdToOrderItems.keyset()){
            for(OrderItem orderItem : context?.orderIdToOrderItems.get(orderId)){
                if(orderItem.OrderItemToProjectApproval__r != null && orderItem.OrderItemToProjectApproval__r.Approval_Status__c == 'Pending'){
                    Id approvalProcessId = context.approvalProcessByOrderItemToProjectApproval?.get(orderItem.OrderItemToProjectApproval__c);
                    if(approvalProcessId != null && !context.orderItemToProjectApprovalToRemove.contains(orderItem.OrderItemToProjectApproval__r)){
                        Approval.ProcessWorkitemRequest approvalProcessToRemove = new Approval.ProcessWorkitemRequest();
                        approvalProcessToRemove.setWorkitemId(approvalProcessId);
                        approvalProcessToRemove.setAction('Removed');
                        approvalProcessToRemove.setComments('Approval process removed by Order Disassociation');

                        approvalProcessRequests.add(approvalProcessToRemove); 

                        context.orderItemToProjectApprovalToRemove.add(orderItem.OrderItemToProjectApproval__r);
                    }
                }
            }
                       
        }
        Approval.ProcessResult[] processResults = Approval.process(approvalProcessRequests);

    }
    
}