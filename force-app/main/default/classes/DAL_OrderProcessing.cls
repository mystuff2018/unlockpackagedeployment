public with sharing class DAL_OrderProcessing {
    public static Map<Id, Order_Processing__c> getOrderProcessByOrderId(Set<Id> orderIds) {
        Map<Id, Order_Processing__c> result = new Map<Id, Order_Processing__c>();
        for(Order_Processing__c orderProcessing :  [SELECT Id, OrderId__c, ProcessStatus__c, RetryCount__c FROM Order_Processing__c WHERE OrderId__c IN :orderIds]) {
            result.put(orderProcessing.OrderId__c, orderProcessing);
        }

        return result;
    }
}