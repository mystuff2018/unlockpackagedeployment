/*
 * @test DAL_OrderItemSKUEffortMapTest
 * @authors Pablo Dunke and Romulo Spier
 * @date 04/29/2020
 * @description Data access layer for the OrderItem SKU Effort Map Object
 */

public with sharing class DAL_OrderItemSKUEffortMap 
{
    public static List<Order_Item_Sku_Effort_Map__c> getBySetOrderItemId(Set<Id> pSetOrderItemId)
    {
        List<Order_Item_Sku_Effort_Map__c> listOrderItemSKUEffortMap = [SELECT Id
                                                                                , Order_Product__c
                                                                                , Project_Task__c 
                                                                            FROM Order_Item_Sku_Effort_Map__c
                                                                            WHERE Order_Product__c IN: pSetOrderItemId
                                                                            AND Project_Task__c != NULL];


        return listOrderItemSKUEffortMap;
    }

    public static Map<Id, Order_Item_Sku_Effort_Map__c> getMapByProjectTaskSetId(Set<Id> pSetProjectTaskId)
    {
        Map<Id, Order_Item_Sku_Effort_Map__c> mapOrderItemSKUEffortMap = new Map<Id, Order_Item_Sku_Effort_Map__c>([
            SELECT Id 
                    , Order_Product__c
                    , Project_Task__c 
                FROM Order_Item_Sku_Effort_Map__c 
                WHERE Project_Task__c IN: pSetProjectTaskId]);

        return mapOrderItemSKUEffortMap;
    }
}