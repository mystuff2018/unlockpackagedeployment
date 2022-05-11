/**
 * Created by Bruno_Frosi on 2/28/2020.
 */

public class RecordTypeHelper {
    // Get a set of ids for a given list of recordtype names
    public static Set<Id> getRecordTypeIds(List<String> recordTypeNames)
    {
        Set<Id> ffRecordTypes = new Set<Id>();
        if(recordTypeNames == null)
            return ffRecordTypes;

        Map<String, Schema.RecordTypeInfo> recordTypeMap = Schema.SObjectType.WorkOrder.getRecordTypeInfosByName();

        for(String recordTypeName :recordTypeNames)
        {
            Id recordTypeId = getRecordTypeId(recordTypeName, recordTypeMap);
            if(recordTypeId != null)
                ffRecordTypes.add(recordTypeId);
        }

        return ffRecordTypes;
    }
    
    public static Set<Id> getRecordTypeIds(List<String> recordTypeNames,Map<String, Schema.RecordTypeInfo> recordTypeMap)
    {
        Set<Id> ffRecordTypes = new Set<Id>();
        if(recordTypeNames == null)
            return ffRecordTypes;
        
        for(String recordTypeName :recordTypeNames)
        {
            Id recordTypeId = getRecordTypeId(recordTypeName, recordTypeMap);
            if(recordTypeId != null)
                ffRecordTypes.add(recordTypeId);
        }
        
        return ffRecordTypes;
    }

    private static Id getRecordTypeId(String name, Map<String, Schema.RecordTypeInfo> recordTypeMap)
    {
        Schema.RecordTypeInfo recordTypeInfo = recordTypeMap.get(name);
        if(recordTypeInfo != null)
        {
            return recordTypeInfo.getRecordTypeId();
        }

        return null;
    }

    public static List<String> getTriggerHandlerConfig(String APIName, String HandlerName) { 
        List<String> listRecordTypeNames = new List<String>();
        for(Trigger_Handler_Configuration__mdt config :[SELECT Id, Record_Type_Name__c FROM Trigger_Handler_Configuration__mdt
        WHERE
        Object_API_Name__c = :APIName AND
        Handler_Class_Name__c = :HandlerName])
        {
            listRecordTypeNames.add(config.Record_Type_Name__c);
        }
        if(listRecordTypeNames.size() > 0)
            return listRecordTypeNames;
        return null;
    }
}