public class LocationTriggerHandler {   
     static boolean isRunning = false;
    
     public static void updateTimezone(Set<Id> newRecords)
     {
         if(!isRunning)
         {
             isRunning = true; 
             List<Schema.Location> recs = [SELECT Id, 
                                           (SELECT Id, Country, CountryCode, Latitude, Longitude, State, StateCode, City
                                            FROM Addresses), (SELECT Id, Site_TimeZone__c, Original_Location_Timezone__c FROM Project_Locations__r)
                                           FROM Location 
                                           WHERE Id IN :newRecords];
             List<Schema.Location> forUpdate = new List<Schema.Location>();
            
             for(Schema.Location l : recs)
             {
                 if(l.Addresses.size() > 0)
                 {
                     System.debug('Location > Address :' +l);
                     String tz = tz.LocalTime.getOffset(l.Addresses[0].Country, l.Addresses[0].State, l.Addresses[0].City);
                     system.debug('tz: ' + tz);
                     TimeZoneOffset offset = (TimeZoneOffset)JSON.deserialize(tz, TimeZoneOffset.class);
                     system.debug('Id: ' + l.Addresses[0].Id + 
                                  ' Country: ' + l.Addresses[0].Country + 
                                  ' State: ' + l.Addresses[0].State + 
                                  ' City: ' + l.Addresses[0].City + 
                                  ' - ' + offset.tz_sfdc);
                   if(offset != null && offset.tz_sfdc != 'N/A')
                     {
                         Schema.Location loc = new Schema.Location();
                         loc.id = String.escapeSingleQuotes(l.Id);			//loc.id = l.Id; checkmarks update
                         loc.TimeZone = String.escapeSingleQuotes(offset.tz_sfdc);			//loc.TimeZone = offset.tz_sfdc; checkmarks update
                         forUpdate.add(loc);
                     }
                 }
             }
             UPDATE forUpdate;
            
             List<Project_Location__c> LocList = new List<Project_Location__c>();
             for(Schema.Location l : recs)
             {
                 if(l.Project_Locations__r.size() > 0)
                 {
                     system.debug('l.Project_Locations__r: ' + l.Project_Locations__r);
                     LocList.addAll(l.Project_Locations__r); 
                 }
             }
             system.debug('LocList: ' + LocList);
             ProjectLocationTriggerHandler.updateTimezone(LocList, true);
         }
     } 
 }