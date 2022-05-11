/**
 * Created by Bruno_Frosi on 1/20/2020.
 */

public with sharing class DAL_Region {
    
    public static Map<String,List<pse__Region__c>> getBuidToRegionMap(Map<Id, Order> orderMap)
    {
        Set<String> setOrderBUID = createSetBUID(orderMap);
        return getBuidToRegionMap(setOrderBUID);
    }

    public static pse__Region__c getGlobalRegion()
    {
        List<pse__Region__c> listRegion = [SELECT Id, Name, pse__Parent_Region__c FROM pse__Region__c WHERE Name like 'Global%' LIMIT 1];
        if(listRegion.size() > 0)
            return listRegion[0];
        return null;
    }

    public static Map<String,List<pse__Region__c>> getBuidToRegionMap(Set<String> setOrderBUID)	
    {	
        Map<String,String> isoCodeToBuid = getIsoCountryCodeToBUID(setOrderBUID);	
        Map<String,List<pse__Region__c>> buidToRegion = new Map<String,List<pse__Region__c>>();        	
        Map<Id, pse__Region__c> regionsCountries = getRegionsCountries(isoCodeToBuid);     	
            	
        for(pse__Region__c region : regionsCountries.values()) {	
            String buid = isoCodeToBuid.get(region.ISO_Country_Code__c);	
            if(buid != null)	
            {	
                List<pse__Region__c> listRegions = buidToRegion.get(buid);	
                if (listRegions == null) {	
                    listRegions = new List<pse__Region__c>();	
                }	
                listRegions.add(region);	
                buidToRegion.put(buid, listRegions);	
            }	
        }	
        return buidToRegion;	
    }
    
    public static Map<Id, pse__Region__c> getStateRegions(Map<Id, Order> orderMap) {	
        Set<String> setOrderBUID = createSetBUID(orderMap);	
        System.debug('DALRegionsetOrderBUID'+setOrderBUID);
        Map<String,String> isoCodeToBuid = getIsoCountryCodeToBUID(setOrderBUID);	
        System.debug('DALRegionisoCodeToBuid'+isoCodeToBuid);
        Map<Id, pse__Region__c> regionsCountries = getRegionsCountries(isoCodeToBuid);
        System.debug('DALRegionregionsCountries'+regionsCountries);
        Map<Id, pse__Region__c> regionsStates = new Map<Id, pse__Region__c>([SELECT Id, Name, Is_State__c, Active__c, ISO_Country_Code__c, pse__Parent_Region__c, pse__Parent_Region__r.Name FROM pse__Region__c WHERE pse__Parent_Region__c IN :regionsCountries.keySet()]);	
        System.debug('DALRegionregionsStates'+regionsStates);
        return regionsStates;	
    }
    
    private static Map<String, String> getIsoCountryCodeToBUID(Set<String> setOrderBUID) {	
        Map<String,String> isoCodeToBuid = new Map<String,String>();	        	
        for(BUID_to_Country_Mapping__mdt buidMap :[SELECT BUID__c, ISO_Country_Code__c FROM BUID_to_Country_Mapping__mdt WHERE BUID__c IN :setOrderBUID]){	
            isoCodeToBuid.put(buidMap.ISO_Country_Code__c,buidMap.BUID__c);	
            System.debug('DALRegionisoCodeToBuid'+isoCodeToBuid);
        }	
        return isoCodeToBuid;	
    }
    
    private static Set<String> createSetBUID(Map<Id, Order> orderMap) {	
        Set<String> setOrderBUID = new Set<String>();	
        for (Id orderId : orderMap.keySet()) {	
            Order order = orderMap.get(orderId);	
            setOrderBUID.add(order.BUID__c);	
        }	
        System.debug('DALRegionsetOrderBUID'+setOrderBUID);
        return setOrderBUID;	
    }
    
    private static Map<Id, pse__Region__c> getRegionsCountries(Map<String, String> isoCodeToBuid) {	
        Map<Id, pse__Region__c> regionsCountries = new Map<ID, pse__Region__c>([SELECT Id, Name, Active__c, ISO_Country_Code__c, pse__Parent_Region__c, pse__Parent_Region__r.Name FROM pse__Region__c WHERE ISO_Country_Code__c IN :isoCodeToBuid.keySet()]);	
        System.debug('DALRegionregionsCountries'+regionsCountries);
        return regionsCountries;	
    }
}