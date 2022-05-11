/**
 * Created by Bruno_Frosi on 1/8/2020.
 */

public class OrderCreatedTriggerHandler extends TriggerHandler {
    public override void afterInsert() {
        try {
            List<Order_Processing__c> ordersToProcess = new List<Order_Processing__c>();

            Set<Id> setOrdersToProcess = new Set<Id>();
            for(Order_Created__e event :(List<Order_Created__e>)Trigger.new) {
                setOrdersToProcess.add(event.Order_ID__c);
            }
            
            List<Order_Processing__c> existingOrdersToProcess = [
                SELECT Id, ProcessStatus__c, OrderId__c 
                FROM Order_Processing__c 
                WHERE OrderId__C IN: setOrdersToProcess
            ];
            
            if(existingOrdersToProcess.size()>0){
                for(Order_Processing__c op : existingOrdersToProcess){
                    if(op.ProcessStatus__c == 'Processed'){
                        ordersToProcess.add(new Order_Processing__c(
                            Id = op.Id,
                            ProcessStatus__c = 'Pending'
                        ));
                    }
                    setOrdersToProcess.remove(op.OrderId__c);
                }
            }
            
            for(Id orderId: setOrdersToProcess) {
                ordersToProcess.add(new Order_Processing__c(
                    OrderId__c = orderId,
                    ProcessStatus__c = 'Pending',
                    RetryCount__c =  0
                ));
            }
            
            UPSERT ordersToProcess;
        }
        catch(Exception e) {
            insert SaveResultExceptionLogger.createExceptionLogger(e, OrderCreatedTriggerHandler.Class.getName(), 'Order Created');
        }
    }
}