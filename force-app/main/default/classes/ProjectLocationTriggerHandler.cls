public class ProjectLocationTriggerHandler {
     static boolean isRunning = false;
    
     public static void updateTimezone(List<Project_Location__c> newRecords)
     {
       // overload
         updateTimezone(newRecords, false);
     }
     public static void updateTimezone(List<Project_Location__c> newRecords, boolean hasDML)
     {
         system.debug('Início');
         if(!isRunning)
         {
             Set<String> timezones = new Set<String>();
             for(Project_Location__c rec :newRecords)
             {
                 if(rec.Original_Location_Timezone__c != NULL)
                	 timezones.add(rec.Original_Location_Timezone__c);
             }
             system.debug('timezones: ' + timezones);

             Map<String, String> timezoneMap = getTimezoneMap(timezones);
             system.debug('timezoneMap: ' + timezoneMap);
            
             for(Project_Location__c rec :newRecords)
             {
                 if(rec.Site_TimeZone__c == NULL)
                	 rec.Site_TimeZone__c = timezoneMap.get(rec.Original_Location_Timezone__c);
             }
             if(hasDML)
                 UPDATE newRecords;
         }
     }
    
     public static Map<String, String> getTimezoneMap(Set<String> timezones)
     {
         Map<String, String> mapTimezone = new Map<String, String>();
        
         for(TimezoneJavaMapping__mdt tz :[SELECT Id, Label, DeveloperName, SitePicklistAPI__c 
                                           FROM TimezoneJavaMapping__mdt 
                                           WHERE Label IN :timezones])
         {
             mapTimezone.put(tz.Label, tz.SitePicklistAPI__c );
         }
        
         return mapTimezone;
     }
}