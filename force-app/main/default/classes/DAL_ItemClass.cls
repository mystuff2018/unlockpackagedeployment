public with sharing class DAL_ItemClass {
    public static Map<Id,List<Item_Class__c>> getItemClassByPractice(Set<Id> practiceList){

        List<Item_Class__c> itemClassList = [
            SELECT Id, Item_Class_Description__c, Practice__c
            FROM Item_Class__c 
            WHERE Practice__c = :practiceList 
                AND Key_Practice__c = true
        ];

        Map<Id,List<Item_Class__c>> itemClassByPracticeMap = new Map<Id,List<Item_Class__c>>(); 

        for(Item_Class__c itemClass: itemClassList){

            List<Item_Class__c> itemClasses;
            if(itemClassByPracticeMap.get(itemClass.Practice__c) == null){
                itemClasses = new List<Item_Class__c>();
            }
            else{
                itemClasses = itemClassByPracticeMap.get(itemClass.Practice__c);
            }

            itemClasses.add(itemClass);

            itemClassByPracticeMap.put(itemClass.Practice__c, itemClasses);
        }

        return itemClassByPracticeMap;

    }

    public static Map<String, pse__Practice__c> getPracticeByDescription(Set<String> descriptions){

        Map<String, pse__Practice__c> mapPracticeByDescription = new Map<String, pse__Practice__c>();

        for(Item_Class__c itemClass: [
            SELECT Id, Item_Class_Description__c, Practice__c, Practice__r.pse__Practice_ID_Chain__c, Practice__r.pse__Parent_Practice__c, Practice__r.pse__Hierarchy_Depth__c,
            Practice__r.Order_Association_Approval_Phase_Number__c
            FROM Item_Class__c
            WHERE Item_Class_Description__c = :descriptions
                AND Key_Practice__c = true
        ]){

            mapPracticeByDescription.put(itemClass.Item_Class_Description__c, itemClass.Practice__r);
        }

        return mapPracticeByDescription;

    }

    public static Map<Id, pse__Practice__c> getAllPractices(){
        Map<Id, pse__Practice__c> mapAllPractices = new Map<Id, pse__Practice__c>([
                SELECT Id, pse__Practice_ID_Chain__c, pse__Parent_Practice__c, pse__Hierarchy_Depth__c, Order_Association_Approval_Phase_Number__c
                FROM pse__Practice__c]);

        return mapAllPractices;

    }

    public static List<String> getListItemClassDescription()
    {
        List<Item_Class__c> listItemClass = [SELECT id, Item_Class_Description__c FROM Item_Class__c WHERE Key_Practice__c = TRUE];

        List<String> listItemClassDescription = new List<String>();
        for(Item_Class__c forItemClass: listItemClass)
        {
            listItemClassDescription.add(forItemClass.Item_Class_Description__c);
        }

        return listItemClassDescription;
    }
}