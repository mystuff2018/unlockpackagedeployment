public class FBE_onLeaveBatch implements Database.Batchable < sObject > {
    String query;
    public Database.querylocator start(Database.BatchableContext BC) {
        query = 'Select Id, FBE_End_Date__c, FBE_Delegated_User__c from User where FBE_Delegated_User__c!=null';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List < sObject > scope) {
        List < User > usrs = new List < User > ();
        for (sObject s: scope) {
            User u = (User) s;
            if (u.FBE_End_Date__c < date.today()) {
                u.FBE_Delegated_User__c = null;
                usrs.add(u);
            }
        }
        update usrs;
    }
    public void finish(Database.BatchableContext BC) {}
}