/**
 * @File Name          : DAL_Sku.cls
 * @Description        : Data access layer for Sku effort mapping related objects.
 * @Author             : Leonardo Santos | 2/18/2020
**/

public with sharing class DAL_Sku {

    public static final String CUSTOM_SKU_NUMBER = 'CUSTOM SKU';

    private static SkuMap getSkuMapBySkuNumberSet(Set<String> skus) {
        Map<String,Id> mapSkuNumberEffortId = new Map<String,Id>();
        Map<String,Sku_Effort_Map__c> skuEffortMap = new Map<String,Sku_Effort_Map__c>();
        Id customSkuId;
        Sku_Effort_Map__c customSku;

        List<SKU_Number__c> skuNumbers = [
            SELECT Id, SKU_Number__c, SKU_to_Effort_Mapping__c 
            FROM SKU_Number__c
            WHERE (SKU_Number__c IN :skus 
                OR SKU_Number__c = :CUSTOM_SKU_NUMBER) 
                AND SKU_to_Effort_Mapping__r.Active__c = true 
        ];

        for(SKU_Number__c skuNum : skuNumbers){
            mapSkuNumberEffortId.put(skuNum.SKU_Number__c, skuNum.SKU_to_Effort_Mapping__c);
            if (skuNum.SKU_Number__c == CUSTOM_SKU_NUMBER) {
                customSkuId = skuNum.SKU_to_Effort_Mapping__c;
            }
        }
        

        Map<Id,Sku_Effort_Map__c> mapps = new Map<Id,Sku_Effort_Map__c>(
            [
                SELECT Id , Name, Description__c, Distinct_Project__c, Residency__c,
                    (SELECT Name__c, Project__c, Phase__r.Name, Role__c, SKU_Effort_Map__c, Estimated_Hours__c, toLabel(Project_Complexity_Tier__c) 
                    FROM SKU_Effort_Map_Entries__r)  // HERE WE CAN FILTER BY TEMPLATE ID IN THE FUTURE
                FROM Sku_Effort_Map__c 
                WHERE 
                Id IN :mapSkuNumberEffortId.values() 
                    AND Active__c = true
            ]
        );

        customSku = mapps.get(customSkuId);

        // Iterate to skus list and for a custom sku put into map the custom sku effort map
        for(String sku: skus){
            String currentSku = sku;

            if(mapSkuNumberEffortId.get(sku) == null){
                currentSku = CUSTOM_SKU_NUMBER;
            }

            skuEffortMap.put(sku, mapps.get(mapSkuNumberEffortId.get(currentSku)));
        }

        return new SkuMap(skuEffortMap, customSku);
    } 

    public static SkuMap getSkuEffortByOrderItens(Map<Id, List<OrderItem>> orderItensByProject){
        Set<String> skus = new Set<String>();
        
        for (Id projectId : orderItensByProject.keySet()) {
            List<OrderItem> orderItens = orderItensByProject.get(projectId);
            for(OrderItem item: orderItens){
                skus.add(item.SKU_Number__c);
            }
        }
        
        return getSkuMapBySkuNumberSet(skus);
    }

    public static Map<String,Sku_Effort_Map__c> getSkuEffortBySkuNumber(Map<Id, Order> orderMap){
        return getSkuMapBySkuNumber(orderMap).skuNumberToSkuEffortMap;
    }

    public static SkuMap getSkuMapBySkuNumber(Map<Id, Order> orderMap){
        Set<String> skus = new Set<String>();
        
        if(orderMap != null){
            for(Order ord: orderMap.values()){
                for(OrderItem item: ord.OrderItems){
                    skus.add(item.SKU_Number__c);
                }
            }
        }

        return getSkuMapBySkuNumberSet(skus);
    }

    public static Map<Id, List<Skill_SKU_Effort_Map_Entry__c>> getSkillSkuEffortMapEntry(Map<Id, List<SKU_Effort_Map_Entry__c>> allEntries){

        /* Parameter Map:
        { ProjectId : List<SKU_Effort_Map_Entry__c> }
        */

        Map<Id, List<Skill_SKU_Effort_Map_Entry__c>> skillSkuByEntryId = new Map<Id, List<Skill_SKU_Effort_Map_Entry__c>>();

        Set<Id> entriesId = new Set<Id>();
        
        for(Id projectId: allEntries.keySet()){
            List<SKU_Effort_Map_Entry__c> entryList = allEntries.get(projectId);
            
            for(SKU_Effort_Map_Entry__c entry: entryList){
                entriesId.add(entry.Id);
            }
        }

        if(entriesId.size() > 0){

            List<Skill_SKU_Effort_Map_Entry__c> skills = [
                SELECT SKU_Effort_Map_Entry__c, Skill_Certification__c, Minimum_Rate__c
                FROM Skill_SKU_Effort_Map_Entry__c
                WHERE SKU_Effort_Map_Entry__c IN :entriesId
            ];

            for(Skill_SKU_Effort_Map_Entry__c skill: skills){

                List<Skill_SKU_Effort_Map_Entry__c> skillList = skillSkuByEntryId.get(skill.SKU_Effort_Map_Entry__c);

                if(skillList == null){
                    skillList = new List<Skill_SKU_Effort_Map_Entry__c>();
                }

                skillList.add(skill);

                skillSkuByEntryId.put(skill.SKU_Effort_Map_Entry__c, skillList);
            }
        }

        return skillSkuByEntryId;
    }

    public static Map<Id, List<Skill_SKU_Effort_Map_Entry__c>> getSkillSkuBySkuEntry(List<Sku_Effort_Map__c> skuEffortMapList){

        Map<Id, List<Skill_SKU_Effort_Map_Entry__c>> skillSkuListByEntryId = new Map<Id, List<Skill_SKU_Effort_Map_Entry__c>>();
        List<SKU_Effort_Map_Entry__c> entryList = [
            SELECT Id, (SELECT Id, Skill_Certification__c, Minimum_Rate__c 
                        FROM Skill_SKU_Effort_Map_Entries__r) 
            FROM SKU_Effort_Map_Entry__c 
            WHERE SKU_Effort_Map__c IN :skuEffortMapList
        ];

        for(SKU_Effort_Map_Entry__c entry: entryList){
            skillSkuListByEntryId.put(entry.Id, entry.Skill_SKU_Effort_Map_Entries__r);
        }

        return skillSkuListByEntryId;
    }

    public class SkuMap {
        public Map<String,Sku_Effort_Map__c> skuNumberToSkuEffortMap {get;set;}
        public Sku_Effort_Map__c customSku {get;set;}

        public SkuMap(Map<String,Sku_Effort_Map__c> pSkuNumberToSkuEffortMap, Sku_Effort_Map__c pCustomSku) {
            skuNumberToSkuEffortMap = pSkuNumberToSkuEffortMap;
            customSku = pCustomSku;
        }
    }
}