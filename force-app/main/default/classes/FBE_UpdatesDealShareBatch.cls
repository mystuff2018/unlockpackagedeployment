/**************
* @ Class Name        : FBE_UpdatesDealShareBatch
* @ Description       : This is a batch class written for one time fix for historical records for Deal Reg Trigger missing from Production under Defect#7877584.
* @ CreatedBy         : Dell
* @ CreatedOn         : 09-27-2020
* @ Modification Log  : 
*********/

public class FBE_UpdatesDealShareBatch implements Database.Batchable<sObject> {
    DateTime soqlRunDate;
    List<id> dealids = new List<id>();
    String dealSharingReason = Schema.Deal_Registration__Share.RowCause.Deal_Team_Sharing__c;
    Map<Id,Deal_Registration__Share> sharesToDelete= new Map<id,Deal_Registration__Share>();
    Map<id,list<string>> DealRegTeamMap = new Map<id,list<string>>();
    List<FBE_Deal_Registration_Team__c> sharesToAdd= new List<FBE_Deal_Registration_Team__c>();
    map<id,list<FBE_Deal_Registration_Team__c>> dealwithTeam = new map<id,list<FBE_Deal_Registration_Team__c>>();
    map<id,list<string>> dealwithShare = new map<id,list<string>>();
    Map<id,List<Deal_Registration__Share>> DealRegShareMap = new Map<id,List<Deal_Registration__Share>>();
    
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([Select Id from Deal_Registration__c]);
    }
    public void execute(Database.BatchableContext bc, List<Deal_Registration__c> scope) {
        List<FBE_Deal_Registration_Team__c> dtm = [Select Id,User__c,Access_level__c,Deal_Registration__c from FBE_Deal_Registration_Team__c where Deal_Registration__c in: scope];
        for(FBE_Deal_Registration_Team__c dt : dtm){
            if(!dealwithTeam.containsKey(dt.Deal_Registration__c)){
                system.debug('YES####');
                dealwithTeam.put(dt.Deal_Registration__c,new List<FBE_Deal_Registration_Team__c>{dt});
                DealRegTeamMap.put(dt.Deal_Registration__c,new List<string>{dt.User__c});
            }else{
                dealwithTeam.get(dt.Deal_Registration__c).add(dt);
                DealRegTeamMap.get(dt.Deal_Registration__c).add(dt.User__c);
            }
            
            
            
        }
        List<Deal_Registration__Share> drs = [SELECT id,UserOrGroupId,parentid FROM Deal_Registration__Share WHERE RowCause =:dealSharingReason and parentid in: dealwithTeam.Keyset()];
        for(Deal_Registration__Share ds : drs){
            
            if(!dealwithShare.containskey(ds.parentid)){
                DealRegShareMap.put(ds.parentid,new List<Deal_Registration__Share>{ds});
                dealwithShare.put(ds.parentid,new List<string>{ds.UserOrGroupId});
            }else{
                dealwithShare.get(ds.parentid).add(ds.UserOrGroupId);
                DealRegShareMap.get(ds.parentid).add(ds);
            }
        }
        if(dealwithTeam != null && !dealwithTeam.isEmpty()){
            for(id deals : dealwithTeam.Keyset()){
                for(FBE_Deal_Registration_Team__c dealteamRec : dealwithTeam.get(deals)){
                    List<string> shres = dealwithShare.get(deals);
                    if(shres != null && shres.size()>0){
                        if(!dealwithShare.get(deals).contains(dealteamRec.User__c)){
                            sharesToAdd.add(dealteamRec);
                        }
                    }else if(shres == null){
                        sharesToAdd.add(dealteamRec);
                    }
                    
                }
                if(DealRegShareMap != null && !DealRegShareMap.isEmpty() && DealRegShareMap.containsKey(deals)){
                    for(Deal_Registration__Share DRegShare:DealRegShareMap.get(deals)){ 
                        if(!DealRegTeamMap.get(deals).contains(DRegShare.UserOrGroupId)){                    
                            sharesToDelete.put(DRegShare.id,DRegShare);
                        }
                    }
                }
            }
        }
        
        try {
            if(sharesToDelete.values() != null && sharesToDelete.values().size()>0){
                delete (sharesToDelete.values());
            }
        }catch(Exception e){
            system.debug('Exception in deletion'+e);
        }
        if(sharesToAdd != null && sharesToAdd.size()>0){
            FBE_DealHelper dh = new FBE_DealHelper();
            dh.createDealTeamMemberShare(sharesToAdd);
        }
    }   
    public void finish(Database.BatchableContext bc) {
    }
}