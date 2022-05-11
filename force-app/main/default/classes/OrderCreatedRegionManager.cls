/**
 * Created by Bruno_Frosi on 1/14/2020.
 */

public with sharing class OrderCreatedRegionManager {
    public static Map<String,pse__Region__c> getBuidToRegionMap(Set<String> setOrderBUID)
    {
        Map<String,String> isoCodeToBuid = new Map<String,String>();
        Map<String,pse__Region__c> buidToRegion = new Map<String,pse__Region__c>();

        for(BUID_to_Country_Mapping__mdt buidMap :[SELECT BUID__c, ISO_Country_Code__c FROM BUID_to_Country_Mapping__mdt WHERE BUID__c IN :setOrderBUID]){
            isoCodeToBuid.put(buidMap.ISO_Country_Code__c,buidMap.BUID__c);
        }

        for(pse__Region__c region : [SELECT Id, Active__c, ISO_Country_Code__c, pse__Parent_Region__c, pse__Parent_Region__r.Name FROM pse__Region__c WHERE ISO_Country_Code__c IN :isoCodeToBuid.keySet()]) {
            String buid = isoCodeToBuid.get(region.ISO_Country_Code__c);
            if(buid != null)
            {
                buidToRegion.put(buid, region);
            }
        } 

        return buidToRegion;
    }

    public static void removeOrdersByRegion(OrderCreatedDataContext context)
    {
        Set<String> setOrderBUID = new Set<String>();

        for (Id orderId : context.orderMap.keySet()) {
            Order order = context.orderMap.get(orderId);
            setOrderBUID.add(order.BUID__c);
        }
        system.debug('setOrderBUID :' + setOrderBUID);

        Map<String,pse__Region__c> buidToRegion = getBuidToRegionMap(setOrderBUID);

        for (Id orderId : context.orderMap.keySet()) {
            Order order = context.orderMap.get(orderId);
            pse__Region__c orderRegion = buidToRegion.get(order.BUID__c);
            if(orderRegion == null) {
                //if no region is found
                context.orderMap.remove(orderId);
                system.debug('remove NO REGION :' + orderId);
            }
            else if(orderRegion != null && !orderRegion.Active__c) {
                //if region is found, but isn't active
                context.orderMap.remove(orderId);
                system.debug('remove REGION INACTIVE :' + orderId);
            }
            //every other order continue on the process
            system.debug('DO NOT REMOVE :' + orderId);
        }
    }
}