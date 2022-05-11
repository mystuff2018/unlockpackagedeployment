public class FBE_FPRM_AccountAffilationStatusBatch implements database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([Select id,FBE_End_Date__c,FBE_FPRM_Transfer_Status__c from Account_Affiliation__c where FBE_End_Date__c = Today AND FBE_FPRM_Transfer_Status__c= ''
                                        AND (FBE_Relationship__c = 'Disty Managed' OR FBE_Relationship__c = 'Reseller')]);
    }
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        List<Account_Affiliation__c> accaff = new List<Account_Affiliation__c>();
        if(Scope.size() > 0){
            for(Account_Affiliation__c acc : (List<Account_Affiliation__c>)Scope){
                acc.FBE_FPRM_Transfer_Status__c = 'Ready For Transfer';
                accaff.add(acc);
            }
            if(accaff.size() > 0){
                update accaff;
            }
            
        }
        
    }
    public void finish(Database.BatchableContext BC){}
}