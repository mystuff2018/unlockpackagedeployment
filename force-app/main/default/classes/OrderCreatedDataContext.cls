/**
 * Created by Bruno_Frosi on 1/8/2020.
 * Last Modify by Elson_Paim and Marcelo_Acioli (Lines 18, 36) including orderImportmap in the context
 *
 * This class will be used on Order_Created event, to retrieve, store and save all the context data for the transaction.
 * We should retrieve every data that we need in the execution (controlling the number os SOQL) in the construction of the context.
 * The data can be refreshed by the method Refresh()
 * Then, on finishing execution, we should use the method Save(), using preferably UPSERTs
 */

public class OrderCreatedDataContext extends DataContext {
    public Map<Id, Order> orderMap {get;set;}
    public Map<Id, Contact> contactMap {get;set;}
    public List<ExceptionLogger__c> exceptionLoggers {get;set;}
    public Map<Id, pse__Proj__c> projectMap {get;set;}
	public Map<Id, Order> orderGroupingMap {get;set;}
    public Map<Id, Id> orderToProjectAssociate {get;set;}
    public List<Order> ordersToApprovalProcess {get;set;}
    public Map<String, List<Order>> installAtAddressOrdersMap{get;set;}
    public Map<String, List<Order>> shippingAddressOrdersMap{get;set;}
    public Map<String, Order_Import_Queue__c> orderImportMap {get;set;}
    public List<Order_Import_Queue__c> listUpdateImportQueue {get;set;}
    public List<String> listItemClassDescription {get;set;}
    public List<Order_Processing__c> listOrderProcessing {get;set;}
    public Set<Id> hardwareOrders{get;set;}
    public FFProcessExecutionControl executionControl;
    public List<Order> customOrdersToUpdate;

    //on constructing retrieve all order data necessary
    public OrderCreatedDataContext(Set<Id> orderIds) {
        refresh(orderIds);
    }

    public override void refresh(Set<Id> orderIds) {

        executionControl = new FFProcessExecutionControl(orderIds);

        System.debug('Refresh');
        orderMap = DAL_Order.getOrdersByIds(orderIds);
        contactMap = new Map<Id, Contact>();
        exceptionLoggers = new List<ExceptionLogger__c>();
        projectMap = new Map<Id, pse__Proj__c>();
        orderGroupingMap = new Map<Id, Order>();
        orderToProjectAssociate = new Map<Id, Id>();
        ordersToApprovalProcess = new List<Order>();
        installAtAddressOrdersMap = new Map<String, List<Order>>();
        shippingAddressOrdersMap = new Map<String, List<Order>>();
        orderImportMap = DAL_OrderImportQueue.getImportedOrdersById(orderMap);
        listUpdateImportQueue = new List<Order_Import_Queue__c>();
        listItemClassDescription = DAL_ItemClass.getListItemClassDescription();
        hardwareOrders = new Set<Id>();
        customOrdersToUpdate = new List<Order>();
    }

    public override void save() {
		//The FF Process Controls must be commited on Salesforce as first step
		executionControl.insertControls();

        //Commit all changes to Contact and ExceptionLogger object generated from OrderCreatedValidateCountryState.validateOrderCountryState
        List<Database.UpsertResult> contactMapResult = Database.upsert(contactMap.values(), false);
        exceptionLoggers.addAll(
            SaveResultExceptionLogger.saveResultsLog(contactMap.values(), contactMapResult, OrderCreatedDataContext.class.getName(), 'OrderCreatedDataContext.contactMap Upsert')
        );
        
        //ordersToApprovalProcess > Send the orders to Order_Association_Approval_Process
        saveOrderAssociation();
                
        sendToOrderItemGroupingEvent();
        
        //Save listUpdateImportQueue
        saveListUpdateImportQueue();
        
        //Updates the Order Processing status to Processed
        updateStatusOrderProcess();

        //Update custom order fields isCustomOrder and custom_Order_Status
        saveCustomOrders();

		//After raising the platform events we need to update the logs with additional values
        executionControl.insertControls();
        
        UPSERT exceptionLoggers;
    }

    public void saveCustomOrders(){
        List<Database.SaveResult> customOrdersToUpdateResults = Database.update(customOrdersToUpdate);
        exceptionLoggers.addAll(SaveResultExceptionLogger.saveResultsLog(customOrdersToUpdate, customOrdersToUpdateResults, OrderCreatedDataContext.class.getName(), 'OrderCreatedDataContext.saveCustomOrders'));
    }

    public void saveListUpdateImportQueue(){
        for(Order_Import_Queue__c oiq :listUpdateImportQueue){
            oiq.ProcessedDate__c = DateTime.now();
        }
        List<Database.SaveResult> orderImportQueueUpdateResults = Database.update(listUpdateImportQueue);
        exceptionLoggers.addAll(SaveResultExceptionLogger.saveResultsLog(listUpdateImportQueue, orderImportQueueUpdateResults, OrderCreatedDataContext.class.getName(), 'OrderCreatedDataContext.sendToOrderItemGroupingEvent'));
    }

    public void saveOrderAssociation(){

        List<Order> ordersToUpdate = new List<Order>();
        
        if(orderToProjectAssociate.size() > 0) {
            for (Id orderId : orderToProjectAssociate.keySet()) {
                Id engagementId = orderToProjectAssociate.get(orderId);
                
                if (engagementId != null) {
                    Order order = orderMap.get(orderId);
                    if(order == null){
                        order = new Order(Id = orderId);    
                    }
                    
                    order.Project__c = engagementId;
                    order.Custom_Order_Status__c = null;
                    ordersToUpdate.add(order);
                }

                String payload = 'Associating Order to Engagement Process: \n';
                payload = payload + 'OrderId: ' + orderId + 'Engagement Id: ' + engagementId; 
                
                executionControl.setProcessLog(string.valueOf(orderId), payload, 'OrderCreatedDataContext: associate order to engagement');
            }
        }

        List<Database.SaveResult> ordersToUpdateResult = Database.update(ordersToUpdate, false);
        executionControl.verifyDmlAndSendToReprocessing(ordersToUpdateResult, null, ordersToUpdate, Schema.Order.Id);
        exceptionLoggers.addAll(
            SaveResultExceptionLogger.saveResultsLog(ordersToUpdateResult, null, executionControl.ordersFailed, OrderCreatedDataContext.class.getName(), 'OrderCreatedDataContext: Associate order to engagement upsert')
        );
    }
    
    public void sendToOrderItemGroupingEvent(){

        List<Order_Item_Grouping__e> eventList = new List<Order_Item_Grouping__e>();
        for (Id orderId : orderToProjectAssociate.keySet()) {

            // Don't send failed order to next proccess
            if(executionControl.ordersFailed.contains(orderId)){
               continue; 
            }

            Order_Item_Grouping__e event = new Order_Item_Grouping__e(
                Order_ID__c = orderId,
                Engagement_ID__c = orderToProjectAssociate.get(orderId)
            );

            String payload = 'sendToOrderItemGroupingEvent process: \n' +  String.valueOf(event);
            executionControl.setProcessLog(string.valueOf(orderId), payload, 'OrderCreatedDataContext: send to OrderItemGrouping event');

            eventList.add(event);
        }

        if(!Test.isRunningTest()){
            List<Database.SaveResult> eventPublishResults = Eventbus.publish(eventList);
            exceptionLoggers.addAll(
                SaveResultExceptionLogger.saveResultsLog((List<sObject>)orderMap.values(), eventPublishResults, OrderCreatedDataContext.class.getName(), 'OrderCreatedDataContext: send to OrderItemGrouping event upsert')
            );
        }
    }
    
    public void updateStatusOrderProcess(){
        List<Order_Processing__c> processingToUpdate = new List<Order_Processing__c>();
        for(Order_Processing__c op : listOrderProcessing){

            if(!executionControl.processingUpdated.contains(op.Id)){
                op.ProcessStatus__c = 'Processed';
                processingToUpdate.add(op);
            }

        }
       
       UPDATE processingToUpdate;
    }
}