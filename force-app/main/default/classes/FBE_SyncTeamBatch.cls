/**************
 *@ Class Name        : FBE_SyncTeamBatch
 *@ Description       : This Batch Apex class invokes comparator class (FBE_SyncTeamComparator) for every Account. 
 *@ CreatedBy         : Deloitte Consulting
 *@ CreatedOn         : 04-09-2019
 *@ Modification Log  : Version 1.0 - [Abhishek Kawle] : Initially created Batch Class to invoke comparator class for Accounts.
***************/
public class FBE_SyncTeamBatch implements Database.Batchable<sObject> {
    public String query;
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        System.debug('inside start method');
        return Database.getQueryLocator(query);
        //return Database.getQueryLocator([Select id from Account where id IN ('001r000000MKKLTAA5','001r000000MKKJRAA5','001r000000MKKLoAAP','001r000000MKKLnAAP','001r000000MKKMSAA5')]);
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> scope){
        set<Id> accountSet = new set<Id>();
        for(Account acc : (list<Account>) scope){
            accountSet.add(acc.Id);
        }
        
        //System.debug('Set Size: ' + accountSet.size());
        if(!accountSet.isEmpty()){
            //System.debug('Invoke Comparator');
            FBE_SyncTeamComparator comparator = new FBE_SyncTeamComparator();
            comparator.compareTeamMembers(accountSet);
        }
    }
    
    public void finish(Database.BatchableContext BC){
    system.debug('In finish');
        FBE_UpdateDealShareBatch fb = new FBE_UpdateDealShareBatch();
        database.executeBatch(fb,10);
    }
}