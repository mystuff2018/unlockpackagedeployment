/**
 * @File Name          : SKUEffortDataManager.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 12/12/2019 11:06:22
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    10/12/2019   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public class SKUEffortDataManager 
{
    private static final List<String> ITEM_CLASS_DESCRIPTION  = new List<String> { 'SVC EDT INSTLN', 'SVC EIS SVCs' };

    public static Map<Id, Boolean> mapOrderIdAllSkuMapped;

    public List<OrderItem> GetOrderItems (string orderId)
    {
        return [SELECT Id , OrderId , Quantity , SKU_Number__c FROM OrderItem WHERE OrderId =: orderId];
    }

    public List<Sku_Effort_Map__c> GetSKUEffortMaps (List<string> skus)
    {
        
        List<SKU_Number__c> skuNumbers = [
            SELECT SKU_to_Effort_Mapping__c
            FROM SKU_Number__c
            WHERE SKU_Number__c IN :SKUs
                 AND SKU_to_Effort_Mapping__r.active__c = true
        ];

        List<Id> skuEffortMappsList = new List<Id>();
        for(SKU_Number__c sku: skuNumbers){
            skuEffortMappsList.add(sku.SKU_to_Effort_Mapping__c);
        }

        List<Sku_Effort_Map__c> mapps = [
            SELECT Id , Name,
        		(SELECT Name__c, Project__c, Phase__r.Name, Role__c, SKU_Effort_Map__c, Estimated_Hours__c FROM SKU_Effort_Map_Entries__r)  // HERE WE CAN FILTER BY TEMPLATE ID IN THE FUTURE
        	FROM Sku_Effort_Map__c 
            WHERE Id IN :skuEffortMappsList
        ];

        return mapps;     
    }

	public List<SKU_Effort_Map_Entry__c> GetSKUEffortMapEntries (List<string> mapids)
    {
        SKU_Effort_Map_Entry__c[] mappEntries = [
            							SELECT Name__c, project__c, Phase__r.Name, Role__c, SKU_Effort_Map__c, Estimated_Hours__c
            							FROM SKU_Effort_Map_Entry__c 
            							WHERE SKU_Effort_Map__c IN :mapids
        							];
        return mappEntries;
        
    }

    public List<pse__Project_Task__c> GetProjectTasks (string projectId)
    {
        pse__Project_Task__c[] existingParentTasks = [SELECT Name From pse__Project_Task__c WHERE pse__Project__c =: projectId  and pse__Parent_Task__c = null];
        return existingParentTasks;
    }

    
    /**
    * Get map Order Id with list of SKU to Effort Mapping ( Fields: Id and Duration Days) 
    * @author Magaiver Oliveira | Tiago Ferreira 
    * @param lstOrderIds 
    * @return Map<Id, List<SKU_Effort_Map__c>> 
    **/
    public static Map<Id, List<SKU_Effort_Map__c>> getSKUEffortMapFromOrders(List<Id> lstOrderIds) {
        
        Map<Id,Set<String>> mapIdOrderSKUNumbers = getMapIdOrderSKUNumbers(lstOrderIds);
        
        List<String> lstSKUNumbers = new List<String>(); 
        for(Id orderId:lstOrderIds){
            if (!mapIdOrderSKUNumbers.isEmpty() && mapIdOrderSKUNumbers.containsKey(orderId))
                lstSKUNumbers.addAll(mapIdOrderSKUNumbers.get(orderId));
        }

        Map<String,SKU_Number__c> mapSKUNumber = getMapSKUNumber(lstSKUNumbers);
 
        Map<Id, List<SKU_Effort_Map__c>> mapOrderIdSKUMaps = new Map<Id, List<SKU_Effort_Map__c>>(); 
        for(Id orderId : mapIdOrderSKUNumbers.keySet()){
            if(!mapOrderIdSKUMaps.containsKey(orderId)){
                mapOrderIdSKUMaps.put(orderId, new List<SKU_Effort_Map__c>());
            }

            for(String strSKUNumber : mapIdOrderSKUNumbers.get(orderId)){
                if(mapSKUNumber.containsKey(strSKUNumber)){
                    SKU_Number__c SKUNumber = mapSKUNumber.get(strSKUNumber);
                    SKU_Effort_Map__c SKUMap = new SKU_Effort_Map__c(
                        Id = SKUNumber.SKU_to_Effort_Mapping__c,
                        Duration_Days__c = SKUNumber.SKU_to_Effort_Mapping__r.Duration_Days__c,
                        X30_Day_Support__c = SKUNumber.SKU_to_Effort_Mapping__r.X30_Day_Support__c
                    );
                    List<SKU_Effort_Map__c> lstSKUMap = mapOrderIdSKUMaps.get(orderId);
                    lstSKUMap.add(SKUMap);
                    mapOrderIdSKUMaps.put(orderId, lstSKUMap);
                }
            }
        }
        setMapOrderIdAllSkuMapped(mapOrderIdSKUMaps,mapIdOrderSKUNumbers);
        return mapOrderIdSKUMaps;

    }

    /**
    * @description 
    * @author Magaiver Oliveira | Tiago Ferreira  | 13/12/2019 
    * @param lstOrderIds 
    * @return Map<Id, Set<String>> 
    **/
    private static Map<Id,Set<String>> getMapIdOrderSKUNumbers(List<Id> lstOrderIds){
        Map<Id,Set<String>> mapIdOrderSKUNumbers = new Map<Id,Set<String>>();         
        for(OrderItem item : [SELECT Id , OrderId , Quantity , SKU_Number__c FROM OrderItem WHERE OrderId IN: lstOrderIds AND Item_Class_Description__c IN :ITEM_CLASS_DESCRIPTION]){
            if(!mapIdOrderSKUNumbers.containsKey(item.OrderId)){
                mapIdOrderSKUNumbers.put(item.OrderId, new Set<String>());
            }
            Set<String> setSKUNumbers = mapIdOrderSKUNumbers.get(item.OrderId);
            setSKUNumbers.add(item.SKU_Number__c);
            mapIdOrderSKUNumbers.put(item.OrderId, setSKUNumbers);
        }
        return mapIdOrderSKUNumbers;
    }

    /**
    * @description 
    * @author Magaiver Oliveira | Tiago Ferreira  | 13/12/2019 
    * @param lstSKUNumbers 
    * @return Map<String, SKU_Number__c> 
    **/
    private static Map<String,SKU_Number__c> getMapSKUNumber(List<String> lstSKUNumbers){
        Map<String,SKU_Number__c> mapSKUNumber = new Map<String,SKU_Number__c>(); 
        for(SKU_Number__c item : [SELECT Id, SKU_Number__c, SKU_to_Effort_Mapping__c, SKU_to_Effort_Mapping__r.Duration_Days__c, SKU_to_Effort_Mapping__r.X30_Day_Support__c 
                                    FROM SKU_Number__c WHERE SKU_Number__c IN : lstSKUNumbers AND SKU_to_Effort_Mapping__r.active__c = true]){
            mapSKUNumber.put(item.SKU_Number__c, item);
        }
        return mapSKUNumber;   
    }
    
    /**
    * @description 
    * @author Magaiver Oliveira | Tiago Ferreira  | 13/12/2019 
    * @param mapOrderIdSKUMaps 
    * @param mapIdOrderSKUNumbers 
    * @return void 
    **/
    private static void setMapOrderIdAllSkuMapped(Map<Id, List<SKU_Effort_Map__c>> mapOrderIdSKUMaps, Map<Id,Set<String>> mapIdOrderSKUNumbers){
        mapOrderIdAllSkuMapped = new Map<Id, Boolean>();
        for (Id orderId : mapOrderIdSKUMaps.keySet()) {
            List<SKU_Effort_Map__c> lstSkuEffortMaps = mapOrderIdSKUMaps.get(orderId);
            Set<String> setSKUNumbers = mapIdOrderSKUNumbers.get(orderId);
            Boolean allSkuNumber = lstSkuEffortMaps != null && setSKUNumbers != null && setSKUNumbers.size() == lstSkuEffortMaps.size();
            mapOrderIdAllSkuMapped.put(orderId, allSkuNumber);
        }
    }
}