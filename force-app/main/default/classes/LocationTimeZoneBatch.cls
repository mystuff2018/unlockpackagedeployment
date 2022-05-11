global class LocationTimeZoneBatch implements Database.Batchable<sObject>{
    global final String query;
    
    global LocationTimeZoneBatch(String q)
    {
        if(q != null && q != '')
            query = q;
        else
            query = 'SELECT Id FROM Location WHERE TimeZone = NULL';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Schema.Location> scope){
        Set<Id> setLocation = new Set<Id>();
        for(Schema.Location s : scope){
            setLocation.add(s.Id);
        }
        LocationTriggerHandler.updateTimezone(setLocation);
    }
    
    global void finish(Database.BatchableContext BC){
    }
    
    public static void ExecuteBatch()
    {
        LocationTimeZoneBatch tzBatch = new LocationTimeZoneBatch(NULL);
        Database.executeBatch(tzBatch, 200);
    }
 }