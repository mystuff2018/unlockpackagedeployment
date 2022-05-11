/**
 * Created by Elson_paim and Marcelo_Acioli on 2/18/2020.
 *
 * Data access layer for OrderImportQueue Object.
 * This class should be used to concentrate avery SOQL query for Order OrderImportQueue Object.
 * Pay attention to implement reusable queries.
 */

public with sharing class DAL_OrderImportQueue{

    public static Map<String, Order_Import_Queue__c> getImportedOrdersById (Map<Id, Order> orderMap){
        system.debug('ImportedOrders');
        Set<String> setOrderNumber = new Set<String>();
        Set<String> setBUID = new Set<String>();

        for(Id orderId : orderMap.keySet()){
            Order order = orderMap.get(orderId);
            setOrderNumber.add(order.OrderNumber__c);
            setBUID.add(order.BUID__c);
        }
        
        Map<String, Order_Import_Queue__c> orderImportQueue = new Map<String, Order_Import_Queue__c>();

        for(Order_Import_Queue__c oiq :[SELECT Id, BUID__c, Order_Number__c, ProcessedDate__c, Project__c, Order_Import_Response_Status__c,
                                        FBE_Siebel_Integration_Message__c
                                       FROM Order_Import_Queue__c WHERE Order_Number__c IN :setOrderNumber AND BUID__c IN :setBUID]){
            orderImportQueue.put(oiq.Order_Number__c + '|' + oiq.BUID__c, oiq);
        }
       
        return orderImportQueue;
        
    }
}