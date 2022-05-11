/**
 * Created by Romulo_Spier and Tiago_Ferreira on 5/22/2020.
 *
 * Data Context for OrderItemToProjectApprovalTriggerHandler
 */

public class OrderItemToProjectApprovalDataContext extends DataContext {
    Map<Id, OrderItemToProjectApproval__c> orderItemsApproval {get;set;}
    Map<Id, List<OrderItem>> mapOrderItems {get;set;}
    public List<Create_Project__e> createProjectEventList{get;set;}
    public List<Order_Association__e> orderItemAssociationEventList{get;set;}
    public Map<Id, pse__Proj__c> projectMap {get;set;}
	public List<ExceptionLogger__c> exceptionLoggers {get;set;}
    public List<Order_Item_Grouping__e> createOrderItemGrouping {get;set;}

    public Set<Id> orderFromProjectApproval { get; set; }
    public Map<Id, Order_Processing__c> orderProcessingMap { get;set; }
    public Set<Order_Processing__c> orderProcessingToBeReprocess {get;set;}

    public OrderItemToProjectApprovalDataContext(Map<Id, OrderItemToProjectApproval__c> orderItemsApproval) {
        this.orderItemsApproval = orderItemsApproval;
        refresh();
    }
    
    public override void refresh() {
        exceptionLoggers = new List<ExceptionLogger__c>();
        createProjectEventList = new List<Create_Project__e>();
        orderItemAssociationEventList = new List<Order_Association__e>();
        createOrderItemGrouping = new List<Order_Item_Grouping__e>();
        mapOrderItems = DAL_OrderItem.getOrderItemsByApprovalProcess(this.orderItemsApproval.keyset());
        projectMap = DAL_Project.getProjectByIds(getProjectIds());

        orderProcessingToBeReprocess = new Set<Order_Processing__c>();
        orderFromProjectApproval = getOrdersFromProjectApproval();
        orderProcessingMap = DAL_OrderProcessing.getOrderProcessByOrderId(orderFromProjectApproval);
     
        splitOrderItemApprovalByStatus();
    }
    
    public override void save() {
        sendOrderItemsToAssociate();
        updateOrderProcessToReprocess();

        INSERT exceptionLoggers;
    }

    private Set<Id> getOrdersFromProjectApproval() {
        Set<Id> orders = new Set<Id>();
        if(mapOrderItems.size() > 0){
            for (List<OrderItem> orderItemList : mapOrderItems.values()) {
                for(OrderItem orderItem : orderItemList) {
                    orders.add(orderItem.OrderId);
                }
            }
        }

        return orders;
    }
    
    private void splitOrderItemApprovalByStatus(){
        Map<Id, String> orderOrderItems = new Map<Id, String>();
        
        //Data have to be splitted by the OrderItemToProject status (either Approved or Rejected)
        //For Approved, it raises an Order_Association__e platform event for associating the OrderItems to the Project
        //For Rejected, it raises a Create_Project__e platform event for creating a new project for the OrderItems 
        for(OrderItemToProjectApproval__c orderItemToProj : this.orderItemsApproval.values()) {
            
            if(orderItemToProj.Approval_Status__c == 'Approved') {
                if(mapOrderItems.containsKey(orderItemToProj.Id)){
                    for(OrderItem oi : mapOrderItems.get(orderItemToProj.Id)){
            			orderItemAssociationEventList.add(
                            new Order_Association__e(
                                                            Project_ID__c = orderItemToProj.Project__c,
                                                            Order_Item_Id__c = oi.Id, 
                                                            Order_ID__c = oi.OrderId
                            )
                        );
                    }
                }
            }
            else if (orderItemToProj.Approval_Status__c == 'Rejected') {

                for(OrderItem orderItem : mapOrderItems.get(orderItemToProj.Id))  {
                    if(orderProcessingMap.containsKey(orderItem.OrderId)) {
                        Order_Processing__c orderProcessing = orderProcessingMap.get(orderItem.OrderId);
                        orderProcessing.ProcessStatus__c = 'Pending';
                        orderProcessing.RetryCount__c = 0;

                        orderProcessingToBeReprocess.add(orderProcessing);
                    }
                }
            }
        }
    }

    private Set<Id> getProjectIds(){
        Set<Id> projectIds = new Set<Id>();
        for(OrderItemToProjectApproval__c orderItemToApproval: orderItemsApproval.values()){
            projectIds.add(orderItemToApproval.Project__c);
        }
        return projectIds;
    }
    
    private void sendOrderItemsToAssociate(){
        System.debug(orderItemAssociationEventList);
        if(orderItemAssociationEventList.size() > 0){
        List<Database.SaveResult> srList = Eventbus.publish(orderItemAssociationEventList);
        exceptionLoggers.addAll(SaveResultExceptionLogger.saveResultsLog(orderItemAssociationEventList, srList, OrderItemToProjectApprovalDataContext.class.getName(), 'Sending project association event'));
    	}
    }

    private void updateOrderProcessToReprocess(){
        if(orderProcessingToBeReprocess.size() > 0) {
            List<Database.SaveResult> orderProcessUpdateResult = Database.update(new List<Order_Processing__c>(orderProcessingToBeReprocess));
            exceptionLoggers.addAll(SaveResultExceptionLogger.saveResultsLog(orderFromProjectApproval, null, orderProcessUpdateResult, OrderItemToProjectApprovalDataContext.class.getName()));
        }
    }
}