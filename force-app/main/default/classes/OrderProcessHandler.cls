global with sharing class OrderProcessHandler implements Database.Batchable<sObject> {    //Added With Sharing as a part of checkMarx
    
    private FFProcessControlSettings__c executionSettings = FFProcessControlSettings__c.getOrgDefaults();
    
    global Database.Querylocator start(Database.BatchableContext BC) {   
        
        Integer numberOfRetries = Integer.valueOf(executionSettings.NumberOfRetries__c);
        String query = 'SELECT Id, OrderId__c, ProcessStatus__c, EventToRetry__c FROM Order_Processing__c WHERE ProcessStatus__c = \'Pending\' AND RetryCount__c <= ' + numberOfRetries + ' ORDER BY OrderId__r.AccountId ASC';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Order_Processing__c> scope){
        try {
            
            Set<Id> orderIds = new Set<Id>();
            List<Order_Processing__c> orderToProcess = new List<Order_Processing__c>();
            
            for(Order_Processing__c op : scope){
                
                orderIds.add(op.OrderId__c);
                orderToProcess.add(op);
                
                op.ProcessStatus__c = 'Processing';
            }
            update scope;
            
            if(!orderIds.isEmpty()){
                orderCreatedProcess(orderIds, orderToProcess);
            }
        }
        catch(Exception e) {
            insert SaveResultExceptionLogger.createExceptionLogger(e, OrderCreatedTriggerHandler.Class.getName(), 'Order Created (After Insert)');
        }
    }
    
    global void finish(Database.BatchableContext BC){}
    
    private void orderCreatedProcess(Set<Id> orderIds, List<Order_Processing__c> orderToProcess){
        
        OrderCreatedDataContext context = new OrderCreatedDataContext(orderIds);
        context.listOrderProcessing = orderToProcess;
        
        System.debug('OrderCreatedDataContext Run');
        
        if(context.orderMap.size() > 0) {
            OrderCreatedClassification.removeNonFFOrder(context);
            OrderCreatedClassification.removeOrdersWithoutOrderItems(context);
            //OrderCreatedValidateCountryState.validateOrderCountryState(context);
            OrderCreatedClassification.verifyOrderImportQueue(context);
            OrderCreatedRegionManager.removeOrdersByRegion(context);
            OrderCreatedClassification.ClassificateOrders(context);
            
            // This will split orderMap in two maps, one to create engagement and another to associate
            OrderCreatedGroupingRules.associateOrderToEngagement(context);
            
            // The orders that are still listed on context.orderMap at this point on process should create engagement
            // The orders on context.orderToProjectAssociate will associate to engagement
            // This process will be executed on OrderCreatedDataContext.save();
            // https://ljdchost.com/039/1qynF4c.gif
            EngagementCreation.createEngagementBySetOrderId(context);
        }
        
        context.save();
    }
}